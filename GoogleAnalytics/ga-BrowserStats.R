library(rpivotTable) 
library(dplyr)
library(readr)


#set the number of sessions that have a screen size before we are interested in them
session_cutoff <- 100
#set factors where we are fairly sure we know the values in advance
browserTypes <- col_factor(levels = c("Chrome", "Edge", "Firefox", "Internet Explorer", "Opera", "Safari"))
int <- col_integer()
char <- col_character()

#read in data
sessions <- read_csv("data/sessions_browser_stats.csv", col_types = list(int, browserTypes, char, char, char, char, int))
#different way to set factors, using data imported
sessions$country <- factor(sessions$country, levels = unique(sessions$country)) 


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
