library(rpivotTable) 
library(dplyr)
library(readr)

# Load in the data exported from uptime robot and print a summary to describe shape of data
alertData <- read_csv("data-in/uptimerobot-all_monitors-logs.csv")
summary(alertData)

# Data clean up number 1
#   remove a calculated column and save a partially cleaned version for further analysis
alertData["Duration"] <- NULL
write.csv(alertData, file="data-out/uptimerobot-filtered_LandingPage-logs.csv") 



# Data clean up number 2
#   using the dplyr workflow, filter on a monitor type
#   then call the pivot table fumction to start exploring data
#   this then uses the pivot filter to exclude "OK" events
#   here using a default to see the average amount of downtime per event - i.e. what's costing us?
#   The formatting is set to a column heatmap to highlight the most significant values
  alertData %>%
  filter (Monitor == "Landing page") %>%
  rpivotTable(
    rows = "Reason", 
    cols = "Event",
    aggregatorName = "Average", 
    exclusions= list( Reason = list( "OK")),
    vals = "Duration (in mins.)", 
    rendererName = "Col Heatmap") 


