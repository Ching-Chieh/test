# Sparse-hedging approach to Global minimum variance portfolio (GMVP)
cat("\014")
rm(list=ls())
library(tidyverse)
library(lubridate)
returns <- da %>% 
  pivot_wider(names_from = stock_id, values_from = ret)
weights <- function(returns, alpha, lambda){
  w <- numeric(ncol(returns))
  for(i in 1:ncol(returns)){
    y <- returns[, i]
    x <- returns[, -i]
    fit <- glmnet(x, y, alpha = alpha, lambda = lambda)
    err <- y - predict(fit, x)
    w[i] <- (1 - sum(fit$beta))/var(err)
  }
  return(w / sum(w))
}
