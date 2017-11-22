library(rpivotTable) 
library(dplyr)
library(readr)


sessions <- read_csv("data/sessions_browser_stats.csv")


# Show a pivot table with the screen resolutions by browser to show the popular clusters
  rpivotTable(
    sessions,
    rows = "screenResolution", 
    cols = "browser",
    aggregatorName = "Sum", 
    vals = "hits", 
    rendererName = "Col Heatmap") 
