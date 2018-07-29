# ProdPad
Scripts and visualisations dealing with ProdPad roadmaps and backlog

## ProdPad.R
Work in progress to get data from the live ProdPad system and report on the state of workflow. On line 4 

``` r

apikey <- "1"
```

You need to add your [API key](https://help.prodpad.com/hc/en-us/articles/204956707-How-do-I-generate-an-API-key-) for your ProdPad user and account, in place of the value "1" in the script by default.

There is also a bit of logic to change around goals infered from tags on lines 

``` r
      switch(tag,
             "User Engagement" = isEngagement[[i]] <- 1,
             "Portal Usability" = isUsability[[i]] <- 1,
             "Revenue Generation" = isRevenue[[i]] <- 1)
```

The easiest way to change it is to update the tag text, e.g. "User Engagement", and leave the variables in this and ProdPad-report.Rmd untouched. This will probably be extracted to a function to improve the reusability.

## ProdPad-report.Rmd
Very much work in progress to use the data from ProdPad.R and report on it. This report is intended to sit alongside the roadmap directly from ProdPad and any release plan. It provides the progress on ideas through product management phases and insights gained from feedback that might lead to new ideas. It uses some of the techniques from [Text-Mining](https://github.com/neilchalk/Text-Mining) applied to the feedback data. The theory is that this report provides detail on the pipeline, the roadmap the current strategic plan, and the release plan the short term implementation plan.

There are a couple of place that you will need to update for your configuration, line 23-24
``` r
states <- c("New Idea", "In Analysis", "Product Definition", 
            "Market Validation", "Queued for Dev", "In Development", "QA", "Released")
```

the order of the states is the order that will be used for sorting and displaying. There are also the summary lines that give a breakdown of ideas in each goal, like this:

``` r
  summarise(Engagement = sum(isGoal1),Revenue = sum(isGoal2), Usability = sum(isGoal3), Total = n()) 

```

and finally the search terms for your product, used in the document term matrix in line 110 onwards
``` r
findAssocs(tdm, "sign-up", 0.25)
findAssocs(tdm, "search", 0.25)
findAssocs(tdm, "feed", 0.6)
findAssocs(tdm, "API", 0.25)
```

I usually tweak this in a console session against words that are in our SEO list to make sure that the threashld is appropriate. E.g. taking 0.25 up to 0.6 if there are a lot of words connected with the original search term.