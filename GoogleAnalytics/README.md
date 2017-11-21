# GoogleAnalytics
Scripts and visualisations dealing with Google Analytics data

## pre-res.R

Run this one first to install the packages required by the scripts in this folder

## ga.R
This covers the authentication and data collection using [GoogleAnalyticsR](http://code.markedmondson.me/googleAnalyticsR/). There is a [great query builder](https://ga-dev-tools.appspot.com/query-explorer/) to collect the data that you want to visualise. A couple notes for your first run and a value you need to alter to make the script work for you:

``` r
#run these three lines next to get the value you need for ga_id
# this will be the View ID in the account_list 
library(googleAnalyticsR)
ga_auth()
```
After the ga_auth() call for the first time you will be directed to a browser to get an autherisation token, you need to paste this into the RStudio console. 

``` r

account_list <- ga_account_list()
```

This allows you to pull in the datasets that you have access to and find the appropriate ID to put into the calls to collect data. Note: this script has a dummy value of 1, you probably don't have access to that ;-)

``` r
## pick a profile with data to query
ga_id <- 1
```

## ga-VisualiseStats.Rmd
This is based on [Google Analytics y R. Parte II: gráficos con ggplot2](http://omargonzalesdiaz.com/blog/googleanalytics-ggplot2.html) by [Omar Gonzáles Díaz](https://twitter.com/o_gonzales) with a couple of visualisations and updates to work with latest version of libraries. This R Markdown example file shows how you can generate automated reports from Google Analytics data. I have split out the query and saving the data to a plain R script so that the you can pull the data down to your machine and work on it locally, reducing the time it takes to run while you explore the data. 

## GA-Explore
Example Shiny app showing interatie exploration of data. Here it is looking at the referrers to the site, by date and optionally the type of referral. This is based on the simple [Google Trends example](http://shiny.rstudio.com/) currently on the Shniy website - at the bottom of the page.

