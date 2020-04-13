#!/usr/local/bin/Rscript

#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
#
# opendata4covid19
#
# extract.R
#
# A short script to extract relevant data from COVID-19 database with relevant ancillary files
# v 0.1.2
# 09-Apr-2020
# Dr Katie Heath: katie.heath@burnet.edu.au
# Dr James Freeman: james@gp2u.com.au
#
# To the extent possible under law, the authors have dedicated all copyright and related and 
# neighboring rights to this software to the public domain worldwide. 
#
# This software is distributed without any warranty.
#
# You should have received a copy of the CC0 Public Domain Dedication along with this software. 
# If not, please see <http://creativecommons.org/publicdomain/zero/1.0/>.
#
# Please do not feed the dragon
#
#            <>=======()
#           (/\___   /|\\          ()==========<>_
#                 \_/ | \\        //|\   ______/ \)
#                   \_|  \\      // | \_/
#                     \|\/|\_   //  /\/
#                      (oo)\ \_//  /
#                     //_/\_\/ /  |
#                    @@/  |=\  \  |
#                         \_=\_ \ |
#                           \==\ \|\_ snd
#                        __(\===\(  )\
#                       (((~) __(_/   |
#                            (((~) \  /
#                            ______/ /
#                            '------'
#
# Don't let his cuteness fool you, he bites. I once saw him consume a quad
# processor CPU, every byte of swap, and an entire SAN. Didn't even flinch.
#
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------

#--------------------------------------
# 1. Install and load packages to read excel files
#--------------------------------------

# This package allows us to easily read and modify excel files

if (! require("readxl")) install.packages("readxl")
library(readxl)

# This package allows us to easily manipulate tables

if (! require("data.table")) install.packages("data.table")
library(data.table)

#--------------------------------------
# 2. Read test data, sheet by sheet
#--------------------------------------

# We read each sheet of the excel files as a separate object in our workspace

# Corona claim data
co19_t200_trans_dn = read_excel("./Data/HIRA COVID-19 Sample Data_20200325.xlsx", sheet=2)
co19_t300_trans_dn = read_excel("./Data/HIRA COVID-19 Sample Data_20200325.xlsx", sheet=3)
co19_t400_trans_dn = read_excel("./Data/HIRA COVID-19 Sample Data_20200325.xlsx", sheet=4)
co19_t530_trans_dn = read_excel("./Data/HIRA COVID-19 Sample Data_20200325.xlsx", sheet=5)

# Medical use history data
co19_t200_twjhe_dn = read_excel("./Data/HIRA COVID-19 Sample Data_20200325.xlsx", sheet=6)
co19_t300_twjhe_dn = read_excel("./Data/HIRA COVID-19 Sample Data_20200325.xlsx", sheet=7)
co19_t400_twjhe_dn = read_excel("./Data/HIRA COVID-19 Sample Data_20200325.xlsx", sheet=8)
co19_t530_twjhe_dn = read_excel("./Data/HIRA COVID-19 Sample Data_20200325.xlsx", sheet=9)

# GNL_CD mapping to generic name
gnl_cd_map = read_excel("./Korean_Codes/GNL_CD-all-codes-drug.xlsx", sheet=1)

# SEX_TP_CD to sex
sex_tp_cd_map = read_excel("./Korean_Codes/SEX_TP_CD.xlsx", sheet=1)

# DGRSLT_TP_CD to outcome
dgrslt_tp_cd_map = read_excel("./Korean_Codes/DGRSLT_TP_CD.xlsx", sheet=1)

# DGSBJT_CD to hospital department name
dgsbjt_cd_map = read_excel("./Korean_Codes/DGSBJT_CD.xlsx", sheet=1)

# CL_CD to clinic (hospital) type
cl_cd_map = read_excel("./Korean_Codes/CL_CD.xlsx", sheet=1)

# FOM_TP_CD to event type
fom_tp_cd_map = read_excel("./Korean_Codes/FOM_TP_CD.xlsx", sheet=1)

# MAIN_SICK to KCD-7 string diagnosis
main_sick_map = read_excel("./Korean_Codes/MAIN_SICK_KCD-7.xlsx", sheet=1)

# Remove the duplicate values from KCD-7
main_sick_map = main_sick_map[!duplicated(main_sick_map$MAIN_SICK),]


#--------------------------------------
# 3. Create relevant tables from data
#--------------------------------------

#--------------------------------------
# 3.i. Table 1 - Demographic data
#--------------------------------------

demographics = co19_t200_trans_dn[,c(
  "MID", "SEX_TP_CD", "PAT_AGE"
)]

# Get only the unique entries
# there may be some individuals with >1 hospital record
demographics = unique(demographics)

#--------------------------------------
# 3.ii. Table 2 - Care information - COVID
#--------------------------------------

care_info_covid = co19_t200_trans_dn[,c(
  "MID", "CL_CD","FOM_TP_CD","MAIN_SICK","SUB_SICK","DGSBJT_CD",
  "RECU_FR_DD","RECU_TO_DD","FST_DD","VST_DDCNT","RECU_DDCNT",
  "DGRSLT_TP_CD"
)]

# get only the medical records which match with table 1 demographic data
care_info_covid = care_info_covid[which(care_info_covid$MID %in% demographics$MID),]

#--------------------------------------
# 3.iii. Table 3 - Care information - PAST HISTORY
#--------------------------------------

care_info_phx = co19_t200_twjhe_dn[,c(
  "MID", "CL_CD","FOM_TP_CD","MAIN_SICK","SUB_SICK","DGSBJT_CD",
  "RECU_FR_DD","RECU_TO_DD","FST_DD","VST_DDCNT","RECU_DDCNT",
  "DGRSLT_TP_CD"
)]

# get only the medical records which match with table 1 demographic data
care_info_phx = care_info_phx[which(care_info_phx$MID %in% demographics$MID),]

#--------------------------------------
# 3.iv. Table 4 - Medication information - COVID
#--------------------------------------

med_info_covid = co19_t530_trans_dn[,c(
  "MID", "PRSCP_GRANT_NO","TOT_INJC_DDCNT_EXEC_FQ", "GNL_CD"
)]

# get only the medical records which match with table 1 demographic data
med_info_covid = med_info_covid[which(med_info_covid$MID %in% demographics$MID),]

# Get the number of characters in the number/string
nch = nchar(med_info_covid$PRSCP_GRANT_NO[1])

# separate PRSCP_GRANT_NO by YYMMDD, year, month, day
med_info_covid$YYMMDD  = substring(med_info_covid$PRSCP_GRANT_NO, 3, 8)
#med_info_covid$PRSCP_YEAR  = substring(med_info_covid$PRSCP_GRANT_NO, 1, 4)
#med_info_covid$PRSCP_MONTH  = substring(med_info_covid$PRSCP_GRANT_NO, 5, 6)
#med_info_covid$PRSCP_DAY  = substring(med_info_covid$PRSCP_GRANT_NO, 7, 8)

#--------------------------------------
# 3.v. Table 5 - Medication information - PAST HISTORY
#--------------------------------------

med_info_phx = co19_t530_twjhe_dn[,c(
  "MID", "PRSCP_GRANT_NO","TOT_INJC_DDCNT_EXEC_FQ", "GNL_CD"
)]

# get only the medical records which match with table 1 demographic data
# we expect there to be no records or overlap for the saple dataset
med_info_phx = med_info_phx[which(med_info_phx$MID %in% demographics$MID),]

# Get the number of characters in the number/string
nch = nchar(med_info_phx$PRSCP_GRANT_NO[1])

# separate PRSCP_GRANT_NO by year, month, day
med_info_phx$YYMMDD       = substring(med_info_phx$PRSCP_GRANT_NO, 3, 8)
med_info_phx$PRSCP_YEAR   = substring(med_info_phx$PRSCP_GRANT_NO, 1, 4)
med_info_phx$PRSCP_MONTH  = substring(med_info_phx$PRSCP_GRANT_NO, 5, 6)
med_info_phx$PRSCP_DAY    = substring(med_info_phx$PRSCP_GRANT_NO, 7, 8)

#--------------------------------------
# 4. Merge datasets
#--------------------------------------

# The all.x=T component forces the fuction to keep all records in the first merged file,
# even if there are no matches in the second file.
# We are using GNL_CD the merge the files.

demographics = merge(demographics, sex_tp_cd_map, by="SEX_TP_CD", all.x=T)
care_info_covid  = merge(care_info_covid, dgrslt_tp_cd_map, by="DGRSLT_TP_CD", all.x=T)
care_info_covid  = merge(care_info_covid, dgsbjt_cd_map, by="DGSBJT_CD", all.x=T)
care_info_covid  = merge(care_info_covid, cl_cd_map, by="CL_CD", all.x=T)
care_info_covid  = merge(care_info_covid, fom_tp_cd_map, by="FOM_TP_CD", all.x=T)
care_info_covid  = merge(care_info_covid, main_sick_map, by="MAIN_SICK", all.x=T)
care_info_phx  = merge(care_info_phx, dgrslt_tp_cd_map, by="DGRSLT_TP_CD", all.x=T)
care_info_phx  = merge(care_info_phx, dgsbjt_cd_map, by="DGSBJT_CD", all.x=T)
care_info_phx  = merge(care_info_phx, cl_cd_map, by="CL_CD", all.x=T)
care_info_phx  = merge(care_info_phx, fom_tp_cd_map, by="FOM_TP_CD", all.x=T)
care_info_phx  = merge(care_info_phx, main_sick_map, by="MAIN_SICK", all.x=T)
med_info_covid = merge(med_info_covid, gnl_cd_map, by="GNL_CD", all.x=T)
med_info_phx = merge(med_info_phx, gnl_cd_map, by="GNL_CD", all.x=T)

# modify names in main_sick_map to reuse on SUB_SICK and merge
names(main_sick_map)[names(main_sick_map) == "MAIN_SICK"] <- "SUB_SICK"
names(main_sick_map)[names(main_sick_map) == "MAIN_DX"] <- "SUB_DX"
care_info_covid  = merge(care_info_covid, main_sick_map, by="SUB_SICK", all.x=T)
care_info_phx  = merge(care_info_phx, main_sick_map, by="SUB_SICK",  all.x=T)


#--------------------------------------
# 5. Rename columns
#--------------------------------------

names(demographics)[names(demographics) == "PAT_AGE"] <- "AGE"
names(med_info_covid)[names(med_info_covid) == "TOT_INJC_DDCNT_EXEC_FQ"] <- "DAYS_RX"
names(med_info_phx)[names(med_info_phx) == "TOT_INJC_DDCNT_EXEC_FQ"] <- "DAYS_RX"

#--------------------------------------
# 6. Get the age range breakdown
#--------------------------------------

agebreaks <- c(0,20,30,40,50,60,70,80,500)
agelabels <- c("0-19","20-29","30-39","40-49","50-59","60-69","70-79","80+")

setDT(demographics)[, AGE_RANGE := cut(AGE,
                                breaks = agebreaks, 
                                right = FALSE, 
                                labels = agelabels)]
#print(demographics)

#--------------------------------------
# 7. Set output data
#--------------------------------------

demographics = demographics[,c(
  "MID","AGE_RANGE","SEX"
)]
care_info_covid = care_info_covid[,c(
  "MID","MAIN_SICK","MAIN_DX","SUB_SICK","SUB_DX","RECU_FR_DD","RECU_TO_DD","FST_DD","VST_DDCNT","RECU_DDCNT","CLINIC_TYPE","EVENT_TYPE","DEPARTMENT","OUTCOME"
)]
care_info_phx = care_info_phx[,c(
  "MID","MAIN_SICK","MAIN_DX","SUB_SICK","SUB_DX","RECU_FR_DD","RECU_TO_DD","FST_DD","VST_DDCNT","RECU_DDCNT","CLINIC_TYPE","EVENT_TYPE","DEPARTMENT","OUTCOME"
)]
med_info_covid = med_info_covid[,c(
  "MID","YYMMDD","DAYS_RX","GNL_CD","GEN_SHORT","GEN_LONG"
)]
med_info_phx = med_info_phx[,c(
  "MID","YYMMDD","DAYS_RX","GNL_CD","GEN_SHORT","GEN_LONG"
)]

#--------------------------------------
# 7. Schema of output data
#--------------------------------------

# Null values are either $ or NA
# 
# Korean code mappings are in Korean_Codes/*.xlsx but have already been merged
#
#  "MID","AGE_RANGE","SEX"
#
# MID - unique ID for a patient
# AGE_RANGE - patient age expressing anonymous 10 year groupings (stings like "20-29")
# SEX - male, female, other
#
# "MID","MAIN_SICK","MAIN_DX","SUB_SICK","SUB_DX","RECU_FR_DD","RECU_TO_DD","FST_DD","VST_DDCNT","RECU_DDCNT","CLINIC_TYPE","EVENT_TYPE","DEPARTMENT","OUTCOME"
#
# MID - unique ID for a patient
# MAIN_SICK - the principal diagnosis code from KCD7 (Korean Classification Diseases v7)
# MAIN_DX - the corresponding string for MAIN_SICK see MAIN_SICK_KCD-7.xlsx
# SUB_SICK - the secondary diagnosis code from KDC7, may be null
# SUB_DX - the corresponding string for SUB_SICK from KCD7
# RECU_FR_DD - the YYMMDD date the patient started receiving medical treatment
# RECU_TO_DD - the YYMMDD date the patient finished receiving medical treatment
# FST_DD - the YYMMDD date of the FIRST admission
# VST_DDCNT - the integer Visit Day Count - ie the number of days recieving inpatient (hospital) treatment
# RECU_DDCNT - the integer Recuperating Day Count - ie the number of days recieving treatment (including outpatient medication)
# CLINIC_TYPE - a sting from the CL_CD.xlsx file with options shown below
#    CL_CD    CLINIC_TYPE
#    01    Advanced General Hospital
#    11    General Hospital
#    21    Hospital
#    28    Yo Yang Hospital
#    29    Mental Health Hospital
#    31    Clinic
#    41    Dental Hospital Won
#    51    Dental Clinic
#    61    Midwifery
#    71    Health Center
#    72    Bo Guernsey
#    73    Health Clinic
#    74    Mother and Child Health Center
#    75    Health Medical Center
#    81    Pharmacy
#    92    Oriental Hospital
#    93    Oriental Medicine
#    $     $
# EVENT_TYPE - where this episode of care happened as outlined below
#    FOM_TP_CD    EVENT_TYPE
#    021    Medical hospitalization
#    031    Medical outpatient
#    041    Dental hospitalization
#    051    Dental outpatient
#    061    Midwifery admission
#    071    Health institution inpatient department
#    072    Health institution inpatient dentistry
#    073    Health institution hospitalization
#    081    Health institution outpatient department
#    082    Outpatient Department of Health
#    083    Health institution outpatient oriental medicine
#    091    Mind and day ward
#    101    Psychiatric hospitalization
#    111    Psychiatry
#    121    Oriental hospitalization
#    131    Oriental medicine
#    151    Hemodialysis
#    201    Direct preparation
#    211    Prescription drugs
#    991    Midwifery Outpatient
#    $      $
# DEPARTMENT - for what looks like only admitted patients one of these options
#    DGSBJT_CD    DEPARTMENT
#    00    General
#    01    Internal Medicine
#    02    Neurology
#    03    Psychiatry
#    04    Surgery
#    05    Orthopedic Surgery
#    06    Neurosurgery
#    07    Thoracic Surgery
#    08    Plastic Surgery
#    09    Anesthesia and Pain Medicine
#    10    Obstetrics Causality
#    11    Pediatrics
#    12    Ophthalmology
#    13    Otolaryngology
#    14    Dermatology
#    15    Urology
#    16    Radiology
#    17    Radiation Oncology
#    18    Pathology
#    19    Diagnostics Department
#    20    Tuberculosis
#    21    Rehabilitation Medicine
#    22    Nuclear Medicine
#    23    Family Medicine
#    24    Emergency Medicine
#    25    Industrial Medicine
#    26    Preventive Medicine
#    27    Dentistry
#    28    Herbal
#    40    Pharmacy
#    41    Health
#    42    Health Institution Department
#    43    Health Intitution Dentistry
#    44    Health Institution Oriental Medicine
#    49    Dentistry
#    50    Oral and Maxillofacial Surgery
#    51    Dental Prosthodontics
#    52    Dental Orthodontics
#    53    Pediatric Dentistry
#    54    Periodontal
#    55    Dental Preservation
#    56    Oral Internal Medicine
#    57    Oral and Maxillofacial Radiology
#    58    Oral Pathology
#    59    Prevantive Dentistry
#    60    Dental Office
#    61    Integrated Dentistry
#    80    Oriental Internal Medicine
#    81    Oriental Gynecology
#    82    Oriental Medicine Pediatrics
#    83    Oriental Medicine Otorhinolaryngology Dermatology
#    84    OrientalPsychiatry
#    85    Acupuncture Department
#    86    Oriental Rehabilitation Medicine
#    87    Sasang Constitution
#    88    Oriental Emergency
#    89    Oriental Emergency
#    90    Oriental Subtotal
#    99    Other
#    $     $
# OUTCOME - the outcome of this care event selected from these options
#    DGRSLT_TP_CD    OUTCOME
#    1   Continued
#    2   Transfer
#    3   Return
#    4   Death
#    5   Other
#    8   Previous
#    9   Discharge
#    $   $
#
#  "MID","YYMMDD","DAYS_RX","GNL_CD","GEN_SHORT","GEN_LONG"
#
# MID - unique ID for a patient
# YYMMDD - date of prescription YYMMDD
# DAYS_RX - the number of days treatment supplied
# GNL_CD - the unique code for the medication
# GEN_SHORT - the GNL_CD converted to a simplified generic name (medication grouping format)
# GEN_LONG - the GNL_CD converted to the full generic name with dose/formulation


#--------------------------------------
# 7. Write the output files
#--------------------------------------

# This section outputs the data into new .csv files which we can open and use.
dir.create("./Results", showWarning = FALSE)
write.csv(demographics, "./Results/demographics.csv", row.names = F)
write.csv(care_info_covid, "./Results/care_info_covid.csv", row.names = F)
write.csv(care_info_phx, "./Results/care_info_phx.csv", row.names = F)
write.csv(med_info_covid, "./Results/med_info_covid.csv", row.names = F)
write.csv(med_info_phx, "./Results/med_info_phx.csv", row.names = F)

#--------------------------------------
# 8. Start analytics
#--------------------------------------

demographicsDT = setDT(demographics)
summary_demographics = demographicsDT[, .(n = .N), keyby = .(AGE_RANGE, SEX)]
summary_sex = demographicsDT[, .(n = .N), keyby = .(SEX)]
summary_age_range = demographicsDT[, .(n = .N), keyby = .(AGE_RANGE)]

care_info_covidDT = setDT(care_info_covid)
summary_outcome = care_info_covidDT[, .(n = .N), keyby = .(CLINIC_TYPE, OUTCOME)]

med_info_covidDT = setDT(med_info_covid)
summary_med_info_covid = med_info_covidDT[, .(days_rx=sum(DAYS_RX), n = .N), keyby = .(GNL_CD, GEN_SHORT)]


med_info_phxDT = setDT(med_info_phx)
summary_med_info_phx = med_info_phxDT[, .(days_rx=sum(DAYS_RX), n = .N), keyby = .(GNL_CD, GEN_SHORT)]

write.csv(summary_demographics, "./Results/summary_demographics.csv", row.names = F)
write.csv(summary_sex, "./Results/summary_sex.csv", row.names = F)
write.csv(summary_age_range, "./Results/summary_age_range.csv", row.names = F)
write.csv(summary_outcome, "./Results/summary_outcome.csv", row.names = F)
write.csv(summary_med_info_phx, "./Results/summary_med_info_phx.csv", row.names = F)
write.csv(summary_med_info_covid, "./Results/summary_med_info_covid.csv", row.names = F)
