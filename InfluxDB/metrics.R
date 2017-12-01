library(xts)
library(influxdbr)


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
filter_usage_temp <- read_csv("data-in/influx-filter_usage.csv") 

# agreggate and sum the data ready for plotting
filter_usage_date <- filter_usage_temp %>%
  group_by(mes = environment, filter_used = filter) %>%
  summarise(sessions = sum(value))


# Create a plot that has gradiated colour bars for filters used
filter_usage_graph <- ggplot(filter_usage_date, aes(x = filter_used, y = sessions, fill = sessions,
                                                    label = sessions)) 
filter_usage_graph <- filter_usage_graph +  geom_col()
filter_usage_graph <- filter_usage_graph + facet_wrap(~ mes) 
filter_usage_graph <- filter_usage_graph + coord_flip()
filter_usage_graph <- filter_usage_graph + labs(x="Filter", y="Frequency", title="Filter usage by environment" )
filter_usage_graph <- filter_usage_graph + scale_fill_gradientn()
filter_usage_graph <- filter_usage_graph + theme(plot.title=element_text(hjust=0.1))
filter_usage_graph <- filter_usage_graph + theme(axis.ticks=element_blank())
filter_usage_graph <- filter_usage_graph + theme(axis.text=element_text(size=12))
filter_usage_graph <- filter_usage_graph + theme(legend.title=element_text(size=10))
filter_usage_graph <- filter_usage_graph + theme(legend.text=element_text(size=8))
filter_usage_graph <- filter_usage_graph + geom_label(hjust = -0.5)
filter_usage_graph

######################################################################
# get the timeseries to work on - example 4 retrieval type by environment

retrieve_types <- influx_query(con, 
                               db = "metrics", 
                               query = "SELECT environment, type, value FROM \"interface notification_retrieve_type_selection\" WHERE time >= '2017-11-15T00:00:00Z'",
                               timestamp_format = c("n", "u", "ms", "s", "m", "h"), return_xts = TRUE,
                               chunked = FALSE, simplifyList = TRUE)
write.csv(retrieve_types, file="data-in/influx-retrieve_types.csv") 
retrieve_types_temp <- read_csv("data-in/influx-retrieve_types.csv") 

# Group and convert the timestamp to a month name
retrieve_types_date <- retrieve_types_temp %>%
  group_by(mes = months(X1), type) %>%
  summarise(sessions = sum(value))
# alternative just to do a count
# retrieve_types_aggregates <- aggregate(a$value,list(a$X1,a$type), sum)

# Create a plot that has gradiated colour bars for filters used
retrieve_types_graph <- ggplot(retrieve_types_date, aes(x = type, y = sessions, fill = sessions,
                                  label = sessions)) 
retrieve_types_graph <- retrieve_types_graph +  geom_col()
retrieve_types_graph <- retrieve_types_graph + facet_wrap(~ mes) 
retrieve_types_graph <- retrieve_types_graph + coord_flip()
retrieve_types_graph <- retrieve_types_graph + labs(x="month", y="sessions", title="Retrieval usage by Month" )
retrieve_types_graph <- retrieve_types_graph + scale_fill_gradientn()
retrieve_types_graph <- retrieve_types_graph + theme(plot.title=element_text(hjust=0.1))
retrieve_types_graph <- retrieve_types_graph + theme(axis.ticks=element_blank())
retrieve_types_graph <- retrieve_types_graph + theme(axis.text=element_text(size=12))
retrieve_types_graph <- retrieve_types_graph + theme(legend.title=element_text(size=10))
retrieve_types_graph <- retrieve_types_graph + theme(legend.text=element_text(size=8))
retrieve_types_graph <- retrieve_types_graph + geom_label(hjust = -0.5)
retrieve_types_graph

