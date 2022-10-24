### Data II Final Project - Shiny app
### Qiwen Zhang


# URL: https://qiwen24.shinyapps.io/final-project-qiwen/

library(tidyverse)
library(shiny)
library(sf)
library(plotly)

ui <- fluidPage(
  fluidRow(
    column(width = 2,
           tags$img(src = "https://d11jve6usk2wa9.cloudfront.net/platform/10747/assets/logo.png",
                    height = 90,
                    width = 260)
    ),
    column(width = 8,
           align = "center",
           tags$h1("Chicago COVID-19 Vaccination"),
           tags$hr()
    )
  ),
  fluidRow(
    column(width = 12,
           align = "center",
           tags$em(tags$h4("Final Project of Data and Programming for Public Policy II"))
    )
  ),
  fluidRow(
    column(width = 12,
           align = "center",
           tags$em(tags$h4("Qiwen Zhang"))
    )
  ),
  fluidRow(
    column(width = 4,
           offset = 2,
           align = "center",
           dateInput(inputId = "date",
                     label = "Choose a date:",
                     value = "2021-01-01",
                     min = "2020-12-15",
                     max = "2022-03-14")
    ),
    column(width = 4,
           align = "center",
           selectInput(inputId = "data",
                       label = "Choose data:",
                       choices = c("Vaccine Series Completed - Cumulative", "Vaccine Series Completed  - Percent Population"))
    )
  ),
  fluidRow(
    column(width = 12,
           align = "center",
           checkboxInput(inputId = "st",
                         label = "Street",
                         value = FALSE)
    )
  ),
  fluidRow(
    column(width = 6,
           offset = 3,
           plotlyOutput("map")
    )
  )
)

server <- function(input, output) {
  vac <- read_csv("./data/vac_zip_clean.csv")
  
  vac$`Zip Code` <- as.numeric(vac$`Zip Code`)
  vac$Date <- as.Date(vac$Date, format = "%m/%d/%Y")
  vac$Date <- format(vac$Date, "%Y-%m-%d")
  
  chicago_shp <- st_read("./data/Boundaries - ZIP Codes/geo_export_7b3f75c7-bfa0-4180-9b72-a74232269ae8.shp")
  chicago_shp$zip <- as.numeric(chicago_shp$zip)
  
  vac_shp <- left_join(vac, chicago_shp, by = c("Zip Code" = "zip"))
  
  street <- st_read("./data/Major_Streets/Major_Streets.shp")
  street <- st_transform(street, crs = 4326)
  
  df <- reactive({
    filter(vac_shp, Date == input$date)
  })
  
  output$map <- renderPlotly({
    if (input$data == "Vaccine Series Completed - Cumulative" & 
        input$st == FALSE) {
      plt <- ggplot() +
        geom_sf(data = df(), aes(geometry = geometry, fill = `Vaccine Series Completed - Cumulative`)) +
        scale_fill_gradient(low = "white", high = "navy") +
        labs(title = "COVID-19 Vaccination in Chicago",
             caption = "Source: Chicago Data Portal",
             fill = "Fully vaccinated") +
        theme_light()
      ggplotly(plt)
    } else if (input$data == "Vaccine Series Completed - Cumulative" & 
               input$st == TRUE) {
      plt <- ggplot() +
        geom_sf(data = df(), aes(geometry = geometry, fill = `Vaccine Series Completed - Cumulative`)) +
        geom_sf(data = street) +
        scale_fill_gradient(low = "white", high = "navy") +
        labs(title = "COVID-19 Vaccination in Chicago",
             caption = "Source: Chicago Data Portal",
             fill = "Fully vaccinated") +
        theme_light()
      ggplotly(plt)
    } else if (input$data == "Vaccine Series Completed  - Percent Population" & 
               input$st == FALSE) {
      plt <- ggplot() +
        geom_sf(data = df(), aes(geometry = geometry, fill = `Vaccine Series Completed  - Percent Population`)) +
        scale_fill_gradient(low = "white", high = "navy") +
        labs(title = "COVID-19 Vaccination in Chicago",
             caption = "Source: Chicago Data Portal",
             fill = "Fully vaccinated") +
        theme_light()
      ggplotly(plt)
    } else if (input$data == "Vaccine Series Completed  - Percent Population" & 
               input$st == TRUE) {
      plt <- ggplot() +
        geom_sf(data = df(), aes(geometry = geometry, fill = `Vaccine Series Completed  - Percent Population`)) +
        geom_sf(data = street) +
        scale_fill_gradient(low = "white", high = "navy") +
        labs(title = "COVID-19 Vaccination in Chicago",
             caption = "Source: Chicago Data Portal",
             fill = "Fully vaccinated") +
        theme_light()
      ggplotly(plt)
    }
  })
}

shinyApp(ui = ui, server = server)
