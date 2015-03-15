
library(shiny)
library(shinyapps)
library(shinyStan)
library(rstan)
load(".RData")
shinyapps::setAccountInfo(name='rfarouni', token='57EC0707EF56DF97CF3FA5952737E441', 
                          secret='6n5CJwh7gqwkV762/2KS0FMf6u12aqsr7eLaVqfj')
shinystan_object <-as.shinystan(model.fit)
save(shinystan_object, file = "shinystan_object.RData")

shinyapps::deployApp(appDir = "shinyStan_for_shinyapps", appName = "BayesianIRT")
#launch_shinystan(model.fit)
