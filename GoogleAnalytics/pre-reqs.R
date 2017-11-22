#Install all the packages needed for the scripts in this folder
#  will check if they are installed first then skip
packages <- c("readr", "ggplot2", "googleAnalyticsR", "forecast", "shinythemes")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))  
}  else {
  print("All packages installed")
}

