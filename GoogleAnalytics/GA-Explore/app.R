#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(dplyr)
library(readr)

trend_data <- read_csv("../data/sessions.csv")

# Define UI for application that selects data from Google Analytics feed
ui <- fluidPage(
  
  #Set app theme - see more here https://rstudio.github.io/shinythemes/
  #theme = shinytheme("lumen"),
  shinythemes::themeSelector(),
   
   
   # Application title
   titlePanel("Google Analytics Stats"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        # Select type of trend to plot
        selectInput(inputId = "source", label = strong("Referrer source"),
                    choices = unique(trend_data$source),
                    selected = "(direct)"),
        # Select whether to overlay smooth trend line
        checkboxInput(inputId = "medium", label = strong("Filter by type?"), value = FALSE),
        
        # Display only if the smoother is checked
        conditionalPanel(condition = "input.medium == true",
                         selectInput(inputId = "type", label = strong("Medium"),
                                     choices = unique(trend_data$medium),
                                     selected = "(none)")
        ),
        
        # Select date range to be plotted
        dateRangeInput("date", strong("Date range"), start = "2017-01-01", end = "2017-11-31",
                       min = "2017-01-01", max = "2017-11-31")
        
      ),

      # Show a plot of the generated distribution
      mainPanel(
        plotOutput(outputId = "lineplot", height = "300px"),
        pre(textOutput(outputId = "desc"))
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  # Subset data
  selected_trends <- reactive({
    req(input$date)
    validate(need(!is.na(input$date[1]) & !is.na(input$date[2]), "Error: Please provide both a start and an end date."))
    validate(need(input$date[1] < input$date[2], "Error: Start date should be earlier than end date."))

    if(input$medium){
      trend_data %>%
        filter(
          {if("source" %in% names(.)) source else NULL} == input$source,
          date > input$date[1] & date < input$date[2],
          medium == input$type
        )
    } else {
      trend_data %>%
        filter(
          {if("source" %in% names(.)) source else NULL} == input$source,
          date > input$date[1] & date < input$date[2]
        ) 
      
    }
    
  })
  
  # Create scatterplot object the plotOutput function is expecting
  output$lineplot <- renderPlot({
   
    if (count(selected_trends()) > 0){
     color = "#434343"
    par(mar = c(4, 4, 1, 1))
    plot(x = selected_trends()$date, y = selected_trends()$sessions, type = "l",
         xlab = "Date", ylab = "Trend index", col = color, fg = color, col.lab = color, col.axis = color)
} 
  })
  
  output$desc <- renderText({
    #Display summary stats for sessions
    #Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    summary(selected_trends()$sessions)
  })
  
}  

# Run the application 
shinyApp(ui = ui, server = server)

