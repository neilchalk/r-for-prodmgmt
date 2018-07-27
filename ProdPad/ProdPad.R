library(jsonlite)

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

#tidy up
backlog$creator.display_name <- factor(backlog$creator.display_name)
backlog$state <- factor(backlog$state)
backlog$impact <- factor(backlog$impact)
backlog$effort <- factor(backlog$effort)
backlog$account.id  <- NULL  
backlog$account.slug <- NULL       
backlog$account.name <- NULL

i <- 1
WIP <- vector()

for(idea in backlog$id){
  mydata <- fromJSON(paste0("https://api.prodpad.com/v1/ideas/", idea, "?apikey=", apikey,"&expand"), flatten=TRUE)
 # message("Retrieving page ", i)
  
  if (!is.null(mydata$status)) { 
    WIP[[i]] <- mydata$status$status
    
  } else {
    WIP[[i]] <- "" 
  }
  i <- i + 1
}

backlog$workflow.status <- factor(WIP)

#check output
summary(backlog)
