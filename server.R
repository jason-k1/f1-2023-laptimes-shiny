#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(dplyr)
library(ggplot2)


# Define server logic required to draw a histogram
function(input, output, session) {
    results = reactive({
      read.csv("2023results.csv")
    })
    
    observe({
      updateSelectInput(session, "driver", choices = sort(unique(results()$driver)))
      
    })
    
    observeEvent(input$driver, {
      updateSelectInput(session, "round", choices = unique(results()[results()$driver == input$driver, "round"]))
    })
    
    fuel_correction = function(laptime, total_laps, current_lap){
      laptime = laptime - (110 * 0.03) * (1 - current_lap / total_laps)
    }
    
    filtered = reactive({
      filter(results(),round == input$round, driver == input$driver, is.na(pit_in_time), is.na(pit_out_time), track_status == 1, !is.na(lap_time))
    })
    
    fuel_correction = function(laptime, total_laps, current_lap){
      laptime = laptime - (110 * 0.03) * (1 - current_lap / total_laps)
    }
    
    output$appPlot = renderPlot({
      tryCatch({
        if (input$checkbox) {
          filtered = reactive({
            filter(results(),round == input$round, driver == input$driver, is.na(pit_in_time), is.na(pit_out_time), track_status == 1, !is.na(lap_time)) %>%
              mutate(lap_time = fuel_correction(lap_time, max(lap_number), lap_number))
          })
          ggplot(filtered(), aes(x = lap_number, y = lap_time)) +
            geom_point() +
            facet_wrap( . ~ stint , nrow = 1, scales = "free_x", as.table = TRUE, dir = "h") +
            geom_smooth(se = FALSE, method = 'lm') +
            scale_x_continuous(breaks = seq(0, max(filtered()$lap_number), by = 5)) +
            labs (x = "Lap", y = "Lap Time (s)",
                  title = "Lap Times, Corrected for Fuel Load")
        } else {
          ggplot(filtered(), aes(x = lap_number, y = lap_time)) +
            geom_point() +
            facet_wrap( . ~ stint , nrow = 1, scales = "free_x", as.table = TRUE, dir = "h") +
            geom_smooth(se = FALSE, method = 'lm') +
            scale_x_continuous(breaks = seq(0, max(filtered()$lap_number), by = 5)) +
            labs (x = "Lap", y = "Lap Time (s)",
                  title = "Lap Times")
        }
      }, error = function(e) {plot(1, type = "n", main = "No Data", xlab = "", ylab = "")
                text(1, 1, "Driver did not start the race, or retired on Lap 1", cex = 2)
      })
      
    })
}
