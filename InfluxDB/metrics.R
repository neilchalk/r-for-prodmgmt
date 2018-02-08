library(xts)
library(influxdbr)
library(rmarkdown)

#Make sure that you are in the correct working directory
#setwd("C:/Temp/R/InfluxDB")

# Create the InfluxDB connection, you need to set the host, user and password (also check the port)

con <- influxdbr::influx_connection(scheme = c("http", "https"), host = "",
                                    port = 8086, user = "", pass = "")

# get the timeseries to work on - example 1 API response times
# Here is an example for my product's DB, which is saved so that you can see the kind of output
# https://docs.influxdata.com/influxdb/v1.3/query_language/data_exploration/ has more info 
mean_response_time <- influx_query(con, 
                                   db = "metrics", 
                                   query = "select mean(\"value\") from \"application http_request_elapsed_ms\" where time >= '2017-11-15T00:00:00Z' group by time(1h)",
                                   timestamp_format = c("n", "u", "ms", "s", "m", "h"), return_xts = TRUE,
                                  chunked = FALSE, simplifyList = TRUE)
write.csv(mean_response_time, file="data-in/influx-reponses.csv") 

# To see how we can use it, first convert to a time series with a daily frequency 
# (the Influx query grouped means by hours for the data points)
library(forecast)
response_time_byDay <- ts(mean_response_time, frequency = 24)
# Then plot to show the values, using my trusty forecast 
# (this data is a bit erratic so don't expect it to be accurate, look at the wide range in the shaded area!)
plot(hw(response_time_byDay,6) , main = c("Avg API response, day 1 = ", format(index(mean_response_time)[1], "%Y-%m-%d", tz = "")), xlab ="Day", ylab = "Elapsed ms")

######################################################################
# get the timeseries to work on - example 2 feature usage by day
feature_usage <- influx_query(con, 
                                   db = "metrics", 
                                   query = "SELECT sum(\"value\") FROM \"application audit_recorded\" where category = 'ElementUpdate' AND time >= '2017-11-15T00:00:00Z' group by time(1h)",
                                   timestamp_format = c("n", "u", "ms", "s", "m", "h"), return_xts = TRUE,
                                   chunked = FALSE, simplifyList = TRUE)
write.zoo(feature_usage, file="data-in/influx-audit.csv", sep=",") 

# clean data where the feature isn't used on a particular grouping and save our processed data set
feature_usage[is.na(feature_usage)] <- 0 # see example three for alternative way of achieving this
write.zoo(feature_usage, file="data-out/influx-audit-processed.csv", sep=",") 

# now get the frequency write and plot with notional prediction for future usage of "feature X"
feature_usage_byDay <- ts(feature_usage, frequency = 24)
plot(hw(feature_usage_byDay,6) , main = c("Usage of feature X, day 1 = ", format(index(feature_usage)[1], "%Y-%m-%d", tz = "")), xlab ="Day", ylab = "Frequency")

######################################################################
# get the timeseries to work on - example 3 filter usage by environment
filter_usage <- influx_query(con, 
                             db = "metrics", 
                             query = "SELECT environment, filter, value FROM \"interface notification_filter_selection\" WHERE time >= '2017-11-15T00:00:00Z'",
                             timestamp_format = c("n", "u", "ms", "s", "m", "h"), return_xts = TRUE,
                             chunked = FALSE, simplifyList = TRUE)
write.csv(filter_usage, file="data-in/influx-filter_usage.csv") 


######################################################################
# get the timeseries to work on - example 4 function by environment

audit_recorded <- influx_query(con, 
                               db = "metrics", 
                               query = "SELECT * FROM \"application audit_recorded\" WHERE time >= '2017-11-15T00:00:00Z'",
                               timestamp_format = c("n", "u", "ms", "s", "m", "h"), return_xts = TRUE,
                               chunked = FALSE, simplifyList = TRUE)
write.csv(audit_recorded, file="data-in/influx-audit_recorded.csv") 

######################################################################
# get the timeseries to work on - example 5 retrieval type by environment

retrieve_types <- influx_query(con, 
                               db = "metrics", 
                               query = "SELECT environment, type, value FROM \"interface notification_retrieve_type_selection\" WHERE time >= '2017-11-15T00:00:00Z'",
                               timestamp_format = c("n", "u", "ms", "s", "m", "h"), return_xts = FALSE,
                               chunked = FALSE, simplifyList = TRUE)

retrieve_types_df <- data.frame(X1 = retrieve_types[[1]]$time, environment = retrieve_types[[1]]$environment, type = retrieve_types[[1]]$type, value = retrieve_types[[1]]$value)
write.csv(retrieve_types_df, file="data-in/influx-retrieve_types.csv", row.names = FALSE)

##### create report
render("featureUsage.Rmd", "all")
