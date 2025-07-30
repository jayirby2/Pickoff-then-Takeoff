# Creating shiny app for predicting stolen base attempts after pickoff moves

library(shiny)
library(xgboost)
library(data.table)
library(bslib)
library(ggplot2)
library(dplyr)
library(sportyR)

# Load the model 
model <- xgb.load("pickoff_takeoff_model.json")

# Define UI application that predicts stolen base attempts 
# according to the parameters

ui <- fluidPage(
  # Change theme
  theme = bs_theme(bootswatch = "lumen", primary = "#092C5C"),
  # Set the title
  titlePanel("Pickoff, Then Takeoff? Predicting Stolen Base Attempts"),
  tags$h4(HTML("- This tool outputs the chance that a runner will steal, given
  that 
  the pitcher has thrown over to first base at least once during the at-bat.<br>
  - Conditions: Model assumes the values are measured directly before a pitcher
  initiates pitching motion and that there is only a runner on first.<br>
  - Use this tool to identify potential threats, make defensive adjustments,
  or simply explore runner aggression in these conditions."
                )),
  sidebarLayout(
    sidebarPanel( 
      # Slider inputs
      sliderInput("lead_adj", "Lead Distance (ft):", min = 0,
                  max = 22, step = 0.1, value = 13),
      sliderInput("speed", "Runner Speed (ft/sec):", min = 23, max = 32,
                  step = 0.1, value = 27),
      sliderInput("time_between", "Time Since Last Pickoff (sec):", min = 10,
                  max = 220, step = 1, value = 20),
      # Radio button
      radioButtons(
        inputId = "handedness",
        label = "Pitcher Handedness:",
        choices = c("Right" = 0, "Left" = 1)
      ),
      sliderInput("inning", "Inning:", min = 1, max = 18, step = 1, value = 4),
      radioButtons(
        inputId = "pickoffs",
        label = "Number of Pickoffs:",
        choices = c("1" = 1, "2+" = 2)
      )),
        mainPanel(
          h3("Prediction Result"),
          verbatimTextOutput("result"),
          plotOutput("myImage",  width = "800px", height = "600px")
        )
    )
)

# Server logic for prediction app
server <- function(input, output) {

  # Reactive input to change prediction after an input changve
  result <- reactive({
    # New user data
    newdata <- data.frame(
      pickoffs = as.numeric(input$pickoffs),
      inning = as.numeric(input$inning),
      lead_adj= as.numeric(input$lead_adj),
      handedness = as.numeric(input$handedness),
      time_between = as.numeric(input$time_between),
      speed = as.numeric(input$speed)
    )
    
    # Make new predictions
    dmatrix <- xgb.DMatrix(data = as.matrix(newdata))
    predict(model, newdata = dmatrix)
  })
  
  output$result <- renderPrint({
    cat("Predicted Steal Probability:", round(result() * 100, 2), "%")
  })
  
  output$myImage <- renderPlot({
    
    runner_line <- function(x1, y1, x2, y2, n=900) {
      t <- seq(0, 1, length.out = n)
      x <- x1 + t * (x2 - x1)
      y <- y1 + t * (y2 - y1)
      data.frame(x = x, y = y)
    }
    
    pos_df <- runner_line(63.6, 67, 0, 135) %>%
      mutate(euc = sqrt((x - 63.6)^2 + (y - 67)^2)) %>%
      filter(euc < as.numeric(input$lead_adj)) %>%
      tail(1) %>%
      select(x, y)
      
    runner_pos <- c(pos_df$x, pos_df$y)
    
    line_2b <- data.frame(
      x = c(0, runner_pos[1]),
      y = c(127.5, runner_pos[2])
    )
    
    fielders <- data.frame(
      x = c(0, 0, 62, 30, -30, -60),
      y = c(-2, 60.5, 65, 140, 140, 75),
      position = c("Catcher","Pitcher","1B","2B","SS", "3B")
    )
    
    runner <- data.frame(
      x = runner_pos[1],
      y = runner_pos[2],
      pred = as.numeric(result() * 100),
      position = paste("Runner", as.numeric(input$speed), "ft/sec")
    )
    
    radius <- 10 * 0.3528 / 25.4
    
    offset_segment <- function(x, y, xend, yend, offset) {
      dx <- xend - x
      dy <- yend - y
      length <- sqrt(dx^2 + dy^2)
      
      # Unit vector
      ux <- dx / length
      uy <- dy / length
      
      # Offset start point
      x_new <- x + ux * offset
      y_new <- y + uy * offset
      
      delta_dist = 90 - as.numeric(input$lead_adj)
      
      label = paste(delta_dist, "ft")
      
      return(data.frame(x = x_new, y = y_new, xend = xend, yend = yend, 
                        label = label))
    }
    
    arrow_df <- offset_segment(x = runner_pos[1], y = runner_pos[2], xend = 0, 
                               yend = 127.5, offset = 3.5)
    
    geom_baseball(league = "MiLB",
                  display_range = "infield") +
      geom_point(data = fielders, aes(x, y), color = "black", size = 3) +
      geom_text(data = fielders, aes(x, y, label = position), vjust = -1) +
      geom_point(data = runner, aes(x, y, fill = pred),
                 size = 10, shape = 21) + 
      geom_text(data = runner, aes(x, y, label = position), vjust = -1.5, 
                hjust = -0.02, 
                size = 5) +
      scale_fill_gradient(low = "blue", high = "red", limits = c(0, 100),
                            labels = function(x) paste0(x, "%"),
                          name = paste("Probability of Steal Attempt", "(%)",
                                       sep = "\n")) +
      geom_segment(data = arrow_df,
                   aes(x = x, y = y, xend = xend, yend = yend),
                   arrow = arrow(length = unit(0.2, "inches")),
                   color = "black", size = 0.5) +
      geom_text(data = arrow_df, aes(x = (x + xend)/2, y = (y + yend)/2, 
                                     label = label), size = 7, vjust = -1.5,
                hjust = -0.01) +
      theme(
        legend.position = c(0.8, 0.2),
        legend.title = element_text(size = 16), 
        legend.text  = element_text(size = 14),
        legend.key.height = unit(0.4, "in")
      )
  })
}
# Run the application 
shinyApp(ui = ui, server = server)
