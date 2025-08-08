# hbut_create_a_secure.R

# Load necessary libraries
library(shiny)
library(digest)

# Define game controller class
Controller <- R6::R6Class(
  "Controller",
  public = list(
    initialize = function(game_state, player_id) {
      private$game_state <- game_state
      private$player_id <- player_id
      private$salt <- "my_secret_salt"
      private$hash <- digest::hmac(private$game_state, private$salt, "sha256")
    },
    get_game_state = function() {
      private$game_state
    },
    get_player_id = function() {
      private$player_id
    },
    get_hash = function() {
      private$hash
    },
    update_game_state = function(new_game_state) {
      private$game_state <- new_game_state
      private$hash <- digest::hmac(private$game_state, private$salt, "sha256")
    }
  ),
  private = list(
    game_state = NULL,
    player_id = NULL,
    salt = NULL,
    hash = NULL
  )
)

# Create a shiny UI for the game
ui <- fluidPage(
  textInput("game_state", "Enter game state:"),
  actionButton("update", "Update game state"),
  textOutput("current_game_state"),
  textOutput("current_player_id"),
  textOutput("current_hash")
)

# Create a shiny server for the game
server <- function(input, output) {
  controller <- Controller$new(game_state = "initial_state", player_id = "player1")
  
  output$current_game_state <- renderText({
    controller$get_game_state()
  })
  
  output$current_player_id <- renderText({
    controller$get_player_id()
  })
  
  output$current_hash <- renderText({
    controller$get_hash()
  })
  
  observeEvent(input$update, {
    new_game_state <- input$game_state
    controller$update_game_state(new_game_state)
  })
}

# Run the shiny app
shinyApp(ui = ui, server = server)