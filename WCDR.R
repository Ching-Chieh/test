# Estimate Probability of Default (pd) and Copula Correlation (rho) and then calculate Worst Case Default Rate (WCDR)
# John C. Hull. Risk Management and Financial Institutions, 5th, p262
# nlminb -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
library(readxl)
df <- read_excel("defaultrate.xlsx")
# default rate log pdf
dr.log.pdf <- function(dr,rho,pd){
  log(sqrt((1-rho)/rho))*(0.5*(qnorm(dr)^2-((sqrt(1-rho)*qnorm(dr)-qnorm(pd))/sqrt(rho))^2))
}
# neagtive log likelihood
logl <- function(para){
  rho=para[1]
  pd=para[2]
  -sum(dr.log.pdf(df$dr,rho,pd))
}
initial_values <- c(rho=0.1,pd=0.01)
S <- 1e-5
res <- nlminb(initial_values, logl, lower = c(S,S), upper=c(1-S,1-S))
rho=res$par[['rho']]
pd=res$par[['pd']]
cat('Copula correlation =',round(rho,3),'\n')
cat('Probability of Default = ',round(pd,4)*100,'%\n', sep = "")
# 99.9% WCDR
X=0.999
WCDR = pnorm((qnorm(pd)+sqrt(rho)*qnorm(X))/sqrt(1-rho))
cat('WCDR = ',round(WCDR,4)*100,'%', sep = "")
