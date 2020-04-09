#!/usr/local/bin/Rscript

#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Short script to extract relevant data from COVID-19 database
# v 0.1.1
# 09-Apr-2020
# Katie Heath: katie.heath@burnet.edu.au
# Dr James Freeman: james@gp2u.com.au
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

# separate PRSCP_GRANT_NO by year, month, day, remaining, etc
medication_info_covid$PRSCP_YEAR  = substring(medication_info_covid$PRSCP_GRANT_NO, 1, 4)
medication_info_covid$PRSCP_MONTH  = substring(medication_info_covid$PRSCP_GRANT_NO, 5, 6)
medication_info_covid$PRSCP_DAY  = substring(medication_info_covid$PRSCP_GRANT_NO, 7, 8)
medication_info_covid$PRSCP_REM  = substring(medication_info_covid$PRSCP_GRANT_NO, 9, nch)


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

# separate PRSCP_GRANT_NO by year, month, day, remaining, etc
medication_info_past_history$PRSCP_YEAR  = substring(medication_info_past_history$PRSCP_GRANT_NO, 1, 4)
medication_info_past_history$PRSCP_MONTH  = substring(medication_info_past_history$PRSCP_GRANT_NO, 5, 6)
medication_info_past_history$PRSCP_DAY  = substring(medication_info_past_history$PRSCP_GRANT_NO, 7, 8)
medication_info_past_history$PRSCP_REM  = substring(medication_info_past_history$PRSCP_GRANT_NO, 9, nch)



#--------------------------------------
# 5. Write the output file
#--------------------------------------

# This section outpute the data into new .csv files which we can open and use.

write.csv(demographic_data, "./Results/demographic_data.csv", row.names = F)
write.csv(care_info_covid, "./Results/care_info_covid.csv", row.names = F)
write.csv(care_info_past_history, "./Results/care_info_past_history.csv", row.names = F)
write.csv(medication_info_covid, "./Results/medication_info_covid.csv", row.names = F)
write.csv(medication_info_past_history, "./Results/medication_info_past_history.csv", row.names = F)
