library(shiny)
library(ggplot2)
library(dplyr)
library(downloader)

# Download the raw data file
download(url = "https://raw.githubusercontent.com/STAT545-UBC/STAT545-UBC.github.io/master/shiny_supp/2016/bcl-data.csv", destfile = "bcl-data.csv")
gapminderData<-read.delim("bcl-data.csv",sep = ",")

bcl <- read.csv("bcl-data.csv", stringsAsFactors = FALSE)

function(input, output) {
  output$countryOutput <- renderUI({
    selectInput("countryInput", "Country",
                sort(unique(bcl$Country)),
                selected = "CANADA")
  })  
  
  filtered <- reactive({
    if (is.null(input$countryInput)) {
      return(NULL)
    }    
    
    
    itemlist <- bcl %>%
        filter(Price >= input$priceInput[1],
               Price <= input$priceInput[2],
               Type == input$typeInput,
               Country == input$countryInput
        )
    
#Added an If statement to catch results where 0 rows are returned
    if (nrow(itemlist)==0){
    return(NULL)
  }
    else{itemlist}
    })    
  
  output$coolplot <- renderPlot({
    if (is.null(filtered())) {
      return()
    }
    ggplot(filtered(), aes(Alcohol_Content)) +
      geom_histogram()
  })
  
  output$results <- renderTable({
    filtered()
  })
  
# Added downloadHandler function to be able to download the table as a .csv file  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("data-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(filtered(), file)
    }
  )
}


