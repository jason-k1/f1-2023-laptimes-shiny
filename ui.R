#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)

# Define UI for application that draws a histogram
fluidPage(
    titlePanel("2023 Formula 1 Season Driver Lap Times"),
    
    fluidRow(
      column(width = 3, selectInput("driver", "Driver", choices = NULL)),
      
      column(width = 3, selectInput("round", "Round", choices = NULL))
    ),
    
    checkboxInput("checkbox", "Fuel-Adjusted Lap Times", value = FALSE),
    
    plotOutput("appPlot")
)
