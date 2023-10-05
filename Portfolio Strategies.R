cat("\014")
rm(list=ls())
library(tidyverse)
library(lubridate)
library(glmnet)
# da: date, stock_id, ret
returns <- da %>%
  pivot_wider(names_from = stock_id, values_from = ret)
weights_sparse_hedge <- function(returns, alpha, lambda){
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
weights_strategies <- function(returns, strategy, alpha, lambda){
  N <- ncol(returns)
  if(strategy == 1){
    # equal weight
    return(rep(1/N,N))
  }
  if(strategy == 2){
    # global minimum variance: If there are more assets than dates,
    # covariance matrix is singular. Use strategies 3
    sigma <- cov(returns)
    w <- solve(sigma) %*% rep(1,N)
    return(w / sum(w))
  }
  if(strategy == 3){
    # add a shrinkage term to global minimum variance
    sigma <- cov(returns) + 0.01 * diag(N)
    w <- solve(sigma) %*% rep(1,N)
    return(w / sum(w))
  }
  if(strategy == 4){
    # sparse-hedging approach to minimum variance
    w <- weights_sparse_hedge(returns, alpha, lambda)
    return(w)
  }
}
# backtesting
testing_time_points <- returns %>% 
  filter(date > separation_date) %>% 
  pull() %>% 
  unique()
# Use all data points before a testing time point to calculate weights, and
# use asset returns at the testing time point to calculate portfolio return
Tt <- length(testing_time_points)
n_strategies <- 4
portf_weights <- array(0, dim = c(Tt, n_strategies, ncol(returns %>% select(-date))))
portf_returns <- matrix(0, nrow = Tt, ncol = n_strategies)
for(t in 1:length(testing_time_points)){
  temp_data <- returns %>%
    filter(date < testing_time_points[t]) %>%
    select(-date) %>% 
    as.matrix()
  realized_return <- returns %>%
    filter(date == testing_time_points[t]) %>%
    select(-date)
  for(j in 1:4){
    portf_weights[t,j,] <- weights_strategies(temp_data, j, 0.1, 0.1)
    portf_returns[t,j] <- sum(portf_weights[t,j,] * realized_return)
  }
}
colnames(portf_returns) <- c("EW", "GMV", "GMV_shrink", "Sparse")
apply(portf_returns, 2, sd)
