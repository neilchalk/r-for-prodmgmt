library(jsonlite)

baseurl <- "https://api.prodpad.com/v1/ideas?apikey=1"
pages <- list()
#TODO add in paging logic based on initial response
for(i in 0:9){
  mydata <- fromJSON(paste0(baseurl, "&page=", i), flatten=TRUE)
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

#check output
summary(backlog)
