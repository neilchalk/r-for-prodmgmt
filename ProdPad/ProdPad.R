library(jsonlite)
library(dplyr)

apikey <- "1"
baseurl <- "https://api.prodpad.com/v1/ideas?apikey="


pages <- list()
#TODO add in paging logic based on initial response
for(i in 0:9){
  mydata <- fromJSON(paste0(baseurl, apikey, "&page=", i), flatten=TRUE)
  message("Retrieving page ", i)
  pages[[i+1]] <- mydata$ideas
}

#combine all into one
backlog <- rbind_pages(pages)

#tidy up - TODO convert to dplyr workflow?
backlog$creator.display_name <- factor(backlog$creator.display_name)
backlog$state <- factor(backlog$state)
backlog$impact <- factor(backlog$impact)
backlog$effort <- factor(backlog$effort)
backlog$account.id  <- NULL  
backlog$account.slug <- NULL       
backlog$account.name <- NULL

# Get extended details to group ideas by goal
i <- 1
isEngagement <- vector()
isRevenue <- vector()
isUsability <- vector()
WIP <- vector()

for(idea in backlog$id){
  mydata <- fromJSON(paste0("https://api.prodpad.com/v1/ideas/", idea, "?apikey=", apikey,"&expand"), flatten=TRUE)
  
  if (!is.null(mydata$status)) { 
    WIP[[i]] <- mydata$status$status
    
  } else {
    WIP[[i]] <- "New Idea" 
  }
  if (!is.null(mydata$tags)) { 
    for(tag in  mydata$tags$tag){
      isEngagement[[i]] <- 0
      isRevenue[[i]] <- 0
      isUsability[[i]] <- 0
      switch(tag,
             "User Engagement" = isEngagement[[i]] <- 1,
             "Portal Usability" = isUsability[[i]] <- 1,
             "Revenue Generation" = isRevenue[[i]] <- 1)
    } 
    
  } else {
    isEngagement[[i]] <- 0
    isRevenue[[i]] <- 0
    isUsability[[i]] <- 0
  }
  
  i <- i + 1
}

isEngagement[is.na(isEngagement)] <- 0
isRevenue[is.na(isRevenue)] <- 0
isUsability[is.na(isUsability)] <- 0

backlog$isGoal1 <- isEngagement
backlog$isGoal2 <- isRevenue
backlog$isGoal3 <- isUsability
backlog$workflow.status <- WIP

write.csv(backlog, file="data-out/backlog.csv") 


baseurl <- "https://api.prodpad.com/v1/feedbacks?apikey="
feedback <- fromJSON(paste0(baseurl, apikey), flatten=TRUE) %>%
  select(id, feedback, created_at, updated_at, customer.name) %>%
  write.csv(file="data-out/feedback.csv") 

#check output
summary(backlog)
summary(feedback)