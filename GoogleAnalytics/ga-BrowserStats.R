library(rpivotTable) 
library(dplyr)
library(readr)


sessions <- read_csv("data/sessions_browser_stats.csv")

#set the number of sessions that have a screen size before we are interested in them
session_cutoff <- 100

# Now find the aggregates for different screen sizes to get the subset we are interested in
session_aggregates <- aggregate(sessions$hits,list(screenResolution = sessions$screenResolution), sum)
significant_sessions <- session_aggregates[which(session_aggregates[,2] > session_cutoff),]

# Show a pivot table with the screen resolutions by browser to show the popular clusters
# This does an initial filter to reduce the amount of data, if we wanted to compare 
#  total browser popularity you'd probably want to remove this
sessions %>%
  filter(sessions$screenResolution %in% significant_sessions[,1]) %>%
  rpivotTable(
    rows = "screenResolution", 
    cols = "browser",
    aggregatorName = "Sum", 
    vals = "hits", 
    rendererName = "Col Heatmap") 
# actually to see relative browser takeup a Treemap might be better, e.g. replace above rpivotTable with this
#rpivotTable(
#  rows = "browser", 
#  aggregatorName = "Sum", 
#  vals = "hits", 
#  rendererName = "Treemap") 
