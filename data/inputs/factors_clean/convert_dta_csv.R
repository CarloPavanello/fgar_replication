# Prepare Firm Level Risk

#remove previous objects
rm(list = ls(all.names = T))

# libraries
library(haven) #to open dta file
library(here)  # to get a global directory
library(data.table) # for data tables
library(zoo)        # for the dates

# load
data <- setDT(read_dta('../factors/firmquarter_2022q1.dta'))
# only firms with headquarters in the US
data <- data[hqcountrycode == 'US']

# we want an aggregate measure of the PRisk, NPRisk, and Risk. Take the mean as they do in the validation
PRisk_agg  <- data[!is.na(PRisk),  .(PRisk_avg = mean(PRisk)),   by = date]
NPRisk_agg <- data[!is.na(NPRisk), .(NPRisk_avg = mean(NPRisk)), by = date]
Risk_agg   <- data[!is.na(Risk),   .(Risk_avg = mean(Risk)),     by = date]

#merge
agg_data <- merge(PRisk_agg, NPRisk_agg, by = "date")
agg_data <- merge(agg_data, Risk_agg, by = "date")

# repeat each data three times to have monthly frequency and remove dates
agg_data_rep <- agg_data[rep(1:.N, each = 3)][,date:=NULL]

# get the monthly dates in the yyyy - MM format

# Define the start and end dates
start_date <- as.Date("2002-01-01")
end_date <- as.Date("2022-03-31")

# Generate a sequence of dates for the end of each quarter
quarter_dates <- seq(from = start_date, to = end_date, by = "month")

# Extract year and month in yyyy-MM format
formatted_dates <- format(quarter_dates, "%Y-%m")

# Convert to a data.table
dates_table <- data.table(date = formatted_dates)

# add the dates to the agg_data_rep
agg_data_month <- agg_data_rep[,date := dates_table$date][,.(date,PRisk_avg,NPRisk_avg,Risk_avg)]

# save the data
fwrite(agg_data_month[,.(date,PRisk_avg)], "PRisk.csv", col.names = FALSE)
fwrite(agg_data_month[,.(date,NPRisk_avg)], "NPRisk.csv", col.names = FALSE)
fwrite(agg_data_month[,.(date,Risk_avg)], "Risk.csv", col.names = FALSE)






