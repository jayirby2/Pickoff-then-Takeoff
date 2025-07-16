# Creating shiny app for predicting stolen base attempts after pickoff moves

library(shiny)
library(xgboost)
library(data.table)

# Load the model 
model <- xgb.load("pickoff_takeoff_model.json")

# Define UI application that predicts stolen base attempts 
# according to the parameters

ui <- fluidPage(
  # Set the title
  titlePanel("Pickoff, Then Takeoff? Predicting Stolen Base Attempts"),
  sidebarLayout(
    sidebarPanel(
      numericInput("lead_adj", "Lead Distance (ft):", 13),
      numericInput("speed", "Runner Speed (ft/sec):", 27),
      numericInput("time_between", "Time Since Last Pickoff (sec):", 19),
      selectInput("handedness", "Pitcher Handedness:", choices = c("Right" = 0,
                                                                   "Left" = 1)),
      numericInput("inning", "Inning:", 7),
      selectInput("pickoffs", "Number of Pickoffs", choices = c("1" = 1, 
                                                                   "2+" = 2)),
      actionButton("predict", "Predict Steal")
    ),
        mainPanel(
          h3("Prediction Result"),
          verbatimTextOutput("result")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  observeEvent(input$predict, {
    newdata <- data.table(
      pickoffs = as.numeric(input$pickoffs),
      inning = as.numeric(input$inning),
      lead_adj= as.numeric(input$lead_adj),
      handedness = as.numeric(input$handedness),
      time_between = as.numeric(input$time_between),
      speed = as.numeric(input$speed)
    )
    
    dmatrix <- xgb.DMatrix(data = as.matrix(newdata))
    pred <- predict(model, dmatrix)
    
    output$result <- renderPrint({
      cat("Predicted Steal Probability:", round(pred * 100, 2), "%")
    })
  })
}
# Run the application 
shinyApp(ui = ui, server = server)
