output$ui_credits <- renderUI({
  jonah <- "Jonah Sol Gabry and Stan Development Team"
  michael <- "Michael Andreae,"
  yuanjun <- "Yuanjun Gao,"
  dongying <- "Dongying Song"
#   HTML(paste(jonah, michael, yuanjun, dongying, sep = '<br/>'))
  HTML(paste(strong(jonah), paste("with", michael, yuanjun, dongying), sep = '<br/>'))
})
