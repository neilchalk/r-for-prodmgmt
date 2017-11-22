# UptimeRobot

## Background
If you are a B2C product manager you might find this example a bit strange. But where your product is more technical and/or accessed by an API then it may be useful to look at patterns of problems that may be causing user churn. Example of why [non-functional reqs are a product concern](http://glinden.blogspot.co.uk/2006/11/marissa-mayer-at-web-20.html)

## pre-reqs.R
For convenience, run this one first to install the packages required by the scripts in this folder

## UptimeRobot.R
Really simple to load in the data exported from uptime robot

TODO insert image here

Then do some data clean up to remove a calculated column and save a partially cleaned version for further analysis

Then do a bit more of a data manipulation, using the dplyr workflow, to filter on a monitor type then call the pivot table fumction to start exploring data. This then uses the pivot filter to exclude "OK" events. Here using a default to see the average amount of downtime per event - i.e. what's costing us? The formatting is set to a column heatmap to highlight the most significant values.

This script shows some examples of data cleaning, and exploration using a pivot table. Although there are defaults set it can be called without any parameters used to allow the user to build up the pivot table themselves. For example, if you play around by resetting the "Reason" filter to show all and the calculation to "Sum as Fraction of Columns" you can see a rough uptime calculation.

## data-in
This folder contains the results of the example call with illustrative data

## data-out
This folder contains processed data sets to save re-running parts of scripts or for passing on. With the size of the data files here that's not much of an issue, but with many more rows it might be.