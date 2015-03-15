
library(shiny)
library(shinyapps)
library(shinyStan)
library(rstan)
load(".RData")

shinystan_object <-as.shinystan(model.fit)
save(shinystan_object, file = "shinystan_object.RData")

shinyapps::deployApp(appDir = "shinyStan_for_shinyapps", appName = "BayesianIRT")
#launch_shinystan(model.fit)
