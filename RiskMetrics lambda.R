# Estimate the lambda of RiskMetrics models
# RiskMetrics' lambda is the value that minimizes the MSE of variance forecast and realized variance (subsequent 25 days)
# John C. Hull. Options, Futures, and Other Derivatives, Global Edition. 9th p.564 Further Questions 23.19
cat("\014")
rm(list=ls())
library(tidyverse)
library(readxl)
library(zoo)   # rollapply
e <- read_excel("euro.xlsx") |> rename(e = euro)
f1 <- function(param){
  lam <- param
  e |> 
    mutate(ret = e/lag(e)-1) |>
    slice({ret1 <<- ret[2]; -(1:2)}) |> 
    mutate(v =
             head(
               accumulate(.x = ret,
                          .f = ~ .x*lam + (1-lam)*.y^2,
                          .init = ret1^2),-1)) |> 
    mutate(beta = rollapply(ret, 25, var, fill=NA, align='left')) |> 
    mutate(sqdiff = 10^6*(v-beta)^2) |> 
    slice(26:(n()-24)) |> 
    summarise(SumSqDiff=sum(sqdiff)) |> 
    pull()
}
res <- optimize(f1, c(0,1))
res$minimum
