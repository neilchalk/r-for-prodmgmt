# UptimeRobot

## Background
Influx is a great database for storing timeseries information. For example feature usage metrics. To get going with the influx integration you will need to edit this line with the host, user name and password:

```R
con <- influxdbr::influx_connection(scheme = c("http", "https"), host = "",
                                    port = 8086, user = "", pass = "")
```

## pre-reqs.R
For convenience, run this one first to install the packages required by the scripts in this folder. this is maninly the InfluxDB connection package.

## Metrics.R
This script contains two examples, API response time and feature usage over time. 

### Average API response times
This takes the timing metric for API responses and charts it. This plot exaple shows using a date from the time series in the title.

### Feature usage of "feature X"
Example of querying the metric tracking feature usage of time, this example also shows how to fill the returned time series with "0" for further processing.

## data-in
This folder contains the results of the example call with illustrative data

## data-out
This folder contains processed data sets to save re-running parts of scripts or for passing on. With the size of the data files here that's not much of an issue, but with many more rows it might be.

