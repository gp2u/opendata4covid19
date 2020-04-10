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
gnl_cd_mapping = read_excel("./Korean_Codes/GNL_CD-all-codes-drug.xlsx", sheet=1)

# SEX_TP_CD to sex
sex_tp_cd_mapping = read_excel("./Korean_Codes/SEX_TP_CD.xlsx", sheet=1)

# DGRSLT_TP_CD to outcome
dgrslt_tp_cd_mapping = read_excel("./Korean_Codes/DGRSLT_TP_CD.xlsx", sheet=1)

# DGSBJT_CD to hospital department name
dgsbjt_cd_mapping = read_excel("./Korean_Codes/DGSBJT_CD.xlsx", sheet=1)

# CL_CD to clinic (hospital) type
cl_cd_mapping = read_excel("./Korean_Codes/CL_CD.xlsx", sheet=1)

# FOM_TP_CD to event type
fom_tp_cd_mapping = read_excel("./Korean_Codes/FOM_TP_CD.xlsx", sheet=1)

# MAIN_SICK to KCD-7 string diagnosis
main_sick_mapping = read_excel("./Korean_Codes/MAIN_SICK_KCD-7.xlsx", sheet=1)

#--------------------------------------
# 3. Create relevant tables from data
#--------------------------------------

#--------------------------------------
# 3.i. Table 1 - Demographic data
#--------------------------------------

demographic_data = co19_t200_trans_dn[,c(
  "MID", "SEX_TP_CD", "PAT_AGE"
)]

# Get only the unique entries
# there may be some individuals with >1 hospital record
demographic_data = unique(demographic_data)



#--------------------------------------
# 3.ii. Table 2 - Care information - COVID
#--------------------------------------


care_info_covid = co19_t200_trans_dn[,c(
  "MID", "CL_CD","FOM_TP_CD","MAIN_SICK","SUB_SICK","DGSBJT_CD",
  "RECU_FR_DD","RECU_TO_DD","FST_DD","VST_DDCNT","RECU_DDCNT",
  "DGRSLT_TP_CD"
)]

# get only the medical records which match with table 1 demographic data
care_info_covid = care_info_covid[which(care_info_covid$MID %in% demographic_data$MID),]


#--------------------------------------
# 3.iii. Table 3 - Care information - PAST HISTORY
#--------------------------------------


care_info_past_history = co19_t200_twjhe_dn[,c(
  "MID", "CL_CD","FOM_TP_CD","MAIN_SICK","SUB_SICK","DGSBJT_CD",
  "RECU_FR_DD","RECU_TO_DD","FST_DD","VST_DDCNT","RECU_DDCNT",
  "DGRSLT_TP_CD"
)]

# get only the medical records which match with table 1 demographic data
care_info_past_history = care_info_past_history[which(care_info_past_history$MID %in% demographic_data$MID),]


#--------------------------------------
# 3.iv. Table 4 - Medication information - COVID
#--------------------------------------

medication_info_covid = co19_t530_trans_dn[,c(
  "MID", "PRSCP_GRANT_NO","TOT_INJC_DDCNT_EXEC_FQ", "GNL_CD"
)]

# get only the medical records which match with table 1 demographic data
medication_info_covid = medication_info_covid[which(medication_info_covid$MID %in% demographic_data$MID),]

# Get the number of characters in the number/string
nch = nchar(medication_info_covid$PRSCP_GRANT_NO[1])

# separate PRSCP_GRANT_NO by year, month, day
medication_info_covid$YYYYMMDD  = substring(medication_info_covid$PRSCP_GRANT_NO, 1, 8)
medication_info_covid$PRSCP_YEAR  = substring(medication_info_covid$PRSCP_GRANT_NO, 1, 4)
medication_info_covid$PRSCP_MONTH  = substring(medication_info_covid$PRSCP_GRANT_NO, 5, 6)
medication_info_covid$PRSCP_DAY  = substring(medication_info_covid$PRSCP_GRANT_NO, 7, 8)


#--------------------------------------
# 3.v. Table 5 - Medication information - PAST HISTORY
#--------------------------------------

medication_info_past_history = co19_t530_twjhe_dn[,c(
  "MID", "PRSCP_GRANT_NO","TOT_INJC_DDCNT_EXEC_FQ", "GNL_CD"
)]

# get only the medical records which match with table 1 demographic data
# we expect there to be no records or overlap for the saple dataset
medication_info_past_history = medication_info_past_history[which(medication_info_past_history$MID %in% demographic_data$MID),]

# Get the number of characters in the number/string
nch = nchar(medication_info_past_history$PRSCP_GRANT_NO[1])

# separate PRSCP_GRANT_NO by year, month, day
medication_info_past_history$YYYYMMDD       = substring(medication_info_past_history$PRSCP_GRANT_NO, 1, 8)
medication_info_past_history$PRSCP_YEAR   = substring(medication_info_past_history$PRSCP_GRANT_NO, 1, 4)
medication_info_past_history$PRSCP_MONTH  = substring(medication_info_past_history$PRSCP_GRANT_NO, 5, 6)
medication_info_past_history$PRSCP_DAY    = substring(medication_info_past_history$PRSCP_GRANT_NO, 7, 8)


#--------------------------------------
# 4. Merge datasets
#--------------------------------------

# The all.x=T component forces the fuction to keep all records in the first merged file,
# even if there are no matches in the second file.
# We are using GNL_CD the merge the files.

demographic_data = merge(demographic_data, sex_tp_cd_mapping, by="SEX_TP_CD", all.x=T)
care_info_covid  = merge(care_info_covid, dgrslt_tp_cd_mapping, by="DGRSLT_TP_CD", all.x=T)
care_info_covid  = merge(care_info_covid, dgsbjt_cd_mapping, by="DGSBJT_CD", all.x=T)
care_info_covid  = merge(care_info_covid, cl_cd_mapping, by="CL_CD", all.x=T)
care_info_covid  = merge(care_info_covid, fom_tp_cd_mapping, by="FOM_TP_CD", all.x=T)
care_info_covid  = merge(care_info_covid, main_sick_mapping, by="MAIN_SICK", all.x=T)
care_info_past_history  = merge(care_info_past_history, dgrslt_tp_cd_mapping, by="DGRSLT_TP_CD", all.x=T)
care_info_past_history  = merge(care_info_past_history, dgsbjt_cd_mapping, by="DGSBJT_CD", all.x=T)
care_info_past_history  = merge(care_info_past_history, cl_cd_mapping, by="CL_CD", all.x=T)
care_info_past_history  = merge(care_info_past_history, fom_tp_cd_mapping, by="FOM_TP_CD", all.x=T)
care_info_past_history  = merge(care_info_past_history, main_sick_mapping, by="MAIN_SICK", all.x=T)
medication_info_covid = merge(medication_info_covid, gnl_cd_mapping, by="GNL_CD", all.x=T)
medication_info_past_history = merge(medication_info_past_history, gnl_cd_mapping, by="GNL_CD", all.x=T)

# modify names in main_sick_mapping to reuse on SUB_SICK and merge
names(main_sick_mapping)[names(main_sick_mapping) == "MAIN_SICK"] <- "SUB_SICK"
names(main_sick_mapping)[names(main_sick_mapping) == "MAIN_DX"] <- "SUB_DX"
care_info_covid  = merge(care_info_covid, main_sick_mapping, by="SUB_SICK", all.x=T)
care_info_past_history  = merge(care_info_past_history, main_sick_mapping, by="SUB_SICK", all.x=T)


#--------------------------------------
# 5. Rename colums
#--------------------------------------

names(demographic_data)[names(demographic_data) == "PAT_AGE"] <- "AGE"
names(medication_info_covid)[names(medication_info_covid) == "TOT_INJC_DDCNT_EXEC_FQ"] <- "DAYS_RX"
names(medication_info_past_history)[names(medication_info_past_history) == "TOT_INJC_DDCNT_EXEC_FQ"] <- "DAYS_RX"

#--------------------------------------
# 5. Set output data
#--------------------------------------

demographic_data = demographic_data[,c(
  "MID","SEX","AGE"
)]
care_info_covid = care_info_covid[,c(
  "MID","MAIN_SICK","MAIN_DX","SUB_SICK","SUB_DX","RECU_FR_DD","RECU_TO_DD","FST_DD","VST_DDCNT","RECU_DDCNT","CLINIC_TYPE","EVENT_TYPE","DEPARTMENT","OUTCOME"
)]
care_info_past_history = care_info_past_history[,c(
  "MID","MAIN_SICK","MAIN_DX","SUB_SICK","SUB_DX","RECU_FR_DD","RECU_TO_DD","FST_DD","VST_DDCNT","RECU_DDCNT","CLINIC_TYPE","EVENT_TYPE","DEPARTMENT","OUTCOME"
)]
medication_info_covid = medication_info_covid[,c(
  "MID","YYYYMMDD","PRSCP_YEAR","PRSCP_MONTH","PRSCP_DAY","DAYS_RX","GNL_CD","GEN_SHORT","GEN_LONG"
)]
medication_info_past_history = medication_info_past_history[,c(
  "MID","YYYYMMDD","PRSCP_YEAR","PRSCP_MONTH","PRSCP_DAY","DAYS_RX","GNL_CD","GEN_SHORT","GEN_LONG"
)]

#--------------------------------------
# 5. Write the output file
#--------------------------------------

# This section outpute the data into new .csv files which we can open and use.

write.csv(demographic_data, "./Results/demographic_data.csv", row.names = F)
write.csv(care_info_covid, "./Results/care_info_covid.csv", row.names = F)
write.csv(care_info_past_history, "./Results/care_info_past_history.csv", row.names = F)
write.csv(medication_info_covid, "./Results/medication_info_covid.csv", row.names = F)
write.csv(medication_info_past_history, "./Results/medication_info_past_history.csv", row.names = F)
