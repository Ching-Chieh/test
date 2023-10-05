cat("\014")
rm(list=ls())
library(tidyverse)
library(lubridate)
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
weights_strategies
weights_multi <- function(returns, strategies, alpha, lambda){
  N <- ncol(returns)
  if(j == 1){
    # equal weight
    return(rep(1/N,N))
  }
  if(j == 2){
    # global minimum variance
    sigma <- cov(returns)
    w <- solve(sigma) %*% rep(1,N)
    return(w / sum(w))
  }
  if(j == 3){
    # add a shrinkage term to global minimum variance
    sigma <- cov(returns) + 0.01 * diag(N)
    w <- solve(sigma) %*% rep(1,N)
    return(w / sum(w))
  }
  if(j == 4){
    # sparse-hedging approach to minimum variance
    w <- weights_sparse_hedge(returns, alpha, lambda)
  }
}
