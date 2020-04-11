#!/usr/local/bin/Rscript

#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
#
# opendata4covid19
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

# separate PRSCP_GRANT_NO by YYYYMMDD, year, month, day
med_info_covid$YYYYMMDD  = substring(med_info_covid$PRSCP_GRANT_NO, 1, 8)
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
med_info_phx$YYYYMMDD       = substring(med_info_phx$PRSCP_GRANT_NO, 1, 8)
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
# 5. Rename colums
#--------------------------------------

names(demographics)[names(demographics) == "PAT_AGE"] <- "AGE"
names(med_info_covid)[names(med_info_covid) == "TOT_INJC_DDCNT_EXEC_FQ"] <- "DAYS_RX"
names(med_info_phx)[names(med_info_phx) == "TOT_INJC_DDCNT_EXEC_FQ"] <- "DAYS_RX"

#--------------------------------------
# 5. Set output data
#--------------------------------------

demographics = demographics[,c(
  "MID","SEX","AGE"
)]
care_info_covid = care_info_covid[,c(
  "MID","MAIN_SICK","MAIN_DX","SUB_SICK","SUB_DX","RECU_FR_DD","RECU_TO_DD","FST_DD","VST_DDCNT","RECU_DDCNT","CLINIC_TYPE","EVENT_TYPE","DEPARTMENT","OUTCOME"
)]
care_info_phx = care_info_phx[,c(
  "MID","MAIN_SICK","MAIN_DX","SUB_SICK","SUB_DX","RECU_FR_DD","RECU_TO_DD","FST_DD","VST_DDCNT","RECU_DDCNT","CLINIC_TYPE","EVENT_TYPE","DEPARTMENT","OUTCOME"
)]
med_info_covid = med_info_covid[,c(
  "MID","YYYYMMDD","DAYS_RX","GNL_CD","GEN_SHORT","GEN_LONG"
)]
med_info_phx = med_info_phx[,c(
  "MID","YYYYMMDD","DAYS_RX","GNL_CD","GEN_SHORT","GEN_LONG"
)]

#--------------------------------------
# 5. Write the output file
#--------------------------------------

# This section outputs the data into new .csv files which we can open and use.
dir.create("./Results", showWarning = FALSE)
write.csv(demographics, "./Results/demographics.csv", row.names = F)
write.csv(care_info_covid, "./Results/care_info_covid.csv", row.names = F)
write.csv(care_info_phx, "./Results/care_info_phx.csv", row.names = F)
write.csv(med_info_covid, "./Results/med_info_covid.csv", row.names = F)
write.csv(med_info_phx, "./Results/med_info_phx.csv", row.names = F)
