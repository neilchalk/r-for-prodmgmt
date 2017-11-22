#If you haven't already install packages
#install.packages("googleAnalyticsR")

#run these three lines next to get the value you need for ga_id
# this will be the View ID in the account_list 
library(googleAnalyticsR)
ga_auth()
account_list <- ga_account_list()

## pick a profile with data to query
ga_id <- 1

#Configure variables for the date range to analyse

start_date <- as.Date("2017-01-01") 
end_date <- Sys.Date() - 1

#Session Query for browser stats
sessions <- google_analytics_4(ga_id, 
                               date_range = c(start_date, end_date),
                               metrics = c("hits"),
                               dimensions = c("browser","browserVersion", "screenResolution", "browserSize", "country"),
                               anti_sample = T)
write.csv(sessions, file="data/sessions_browser_stats.csv")

#Session Query for source and method
sessions <- google_analytics_4(ga_id, 
                                    date_range = c(start_date, end_date),
                                    metrics = c("sessions"),
                                    dimensions = c("date","hour", "source", "medium"))
write.csv(sessions, file="data/sessions.csv")

#Session Query for hourly stats

sessions_per_hour <- google_analytics_4(ga_id, 
                                    date_range = c(start_date, end_date),
                                    metrics = c("sessions"),
                                    dimensions = c("date", "hour"),
                                    anti_sample = T)
write.csv(sessions, file="data/sessions_per_hour.csv")
