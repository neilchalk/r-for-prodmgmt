library(jsonlite)
library(dplyr)

apikey <- "1"
baseurl <- "https://api.prodpad.com/v1/ideas?apikey="

#change the line below to make sure that you are in the correct workign directory
#setwd("C:/Temp/R/ProdPad")
source("ProdPad-functions.R")

##### START OF DATA RETRIEVAL ########
backlog <- retrieve_ideas()
# set the raw prioritisation score 
backlog$raw <- backlog$impact %/0% backlog$effort

backlog %>% 
  tag_status() %>%
  distinct(id, .keep_all = TRUE) %>%
  select(-.data$account.id, -.data$account.slug, -.data$account.name, 
         -.data$creator.id, -.data$creator.username) %>%
  write.csv(file="data-out/backlog.csv") 


baseurl <- "https://api.prodpad.com/v1/feedbacks?apikey="
feedback <- fromJSON(paste0(baseurl, apikey), flatten=TRUE) %>%
  select(id, feedback, created_at, updated_at, customer.name) %>%
  write.csv(file="data-out/feedback.csv") 

#check output
summary(backlog)
summary(feedback)
