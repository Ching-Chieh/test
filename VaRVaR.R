# 2 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
# traditional -------------------------------------------------------------
calulate_loss <- function(price_matrix, portfolio) {
  number_of_assets <- ncol(price_matrix)
  number_of_scenarios <- nrow(price_matrix) - 1
  portfolio_value <- rep(0, number_of_scenarios)
  for (i in 1:number_of_scenarios) {
    portfolio_value[i] <- sum(portfolio*price_matrix[i+1, ]/price_matrix[i, ])
  }
  loss <- sum(portfolio) - portfolio_value
  return(loss)
}
traditional <- function(loss) {
  number_of_scenarios <- length(loss)
  loss <- sort(loss, decreasing = TRUE)
  num <- as.integer(floor(number_of_scenarios*0.01))
  VaR <- loss[num]
  ES <- mean(loss[1:(num-1)])
  sd_function <- function(x) {
    N <- length(x)
    value <- 0
    for (i in 1:N) {
      value <- value + x[i]^2
    }
    value <- sqrt((value - sum(x)^2/N) / (N-1))
    return(value)
  }
  loss_mean <- mean(loss)
  loss_sd <- sd_function(loss)
  SE <- 1/dnorm(qnorm(0.99, loss_mean, loss_sd), loss_mean, loss_sd)*
    sqrt(0.01*0.99/number_of_scenarios)
  z <- qnorm(0.99)
  VaR_lower <- VaR - z*SE
  VaR_upper <- VaR + z*SE
  
  result <- list(VaR = VaR, ES = ES, VaR_lower = VaR_lower, VaR_upper = VaR_upper)
  class(result) <- "Historical_Simulation"
  attr(result, "approach") <- "traditional"
  return(invisible(result))
}
# traditional_weighting -----------------------------------------------------------------------
traditional_weighting <- function(loss) {
  scenario_number <- order(loss, decreasing = TRUE)
  number_of_scenarios <- length(loss)
  loss <- sort(loss, decreasing = TRUE)
  lambda <- 0.995
  weight <- lambda^(number_of_scenarios-scenario_number)*(1-lambda)/(1-lambda^number_of_scenarios)
  cum_weight <- cumsum(weight)
  num <- 1
  while (cum_weight[num] < 0.01) {
    num <- num + 1
  }
  value <- sum(loss[1:(num-1)]*weight[1:(num-1)])
  VaR <- loss[num]
  ES <- (value + (0.01 - cum_weight[num - 1])*loss[num])/0.01
  
  result <- list(VaR = VaR, ES = ES)
  class(result) <- "Historical_Simulation"
  attr(result, "approach") <- "traditional_weighting"
  return(invisible(result))
}
# adjusted_loss -----------------------------------------------------------
adjusted_loss <- function(loss) {
  number_of_scenarios <- length(loss)
  variance <- rep(0, number_of_scenarios)
  variance[1] <- var(loss)
  lambda <- 0.94
  for (i in 2:number_of_scenarios) {
    variance[i] <- lambda*variance[i-1] + (1 - lambda)*loss[i-1]^2
  }
  adj_loss <- loss*sqrt(variance[length(variance)]/variance)
  adj_loss <- sort(adj_loss, decreasing = TRUE)
  num <- as.integer(floor(number_of_scenarios*0.01))
  VaR <- adj_loss[num]
  ES <- mean(adj_loss[1:(num-1)])
  
  result <- list(VaR = VaR, ES = ES)
  class(result) <- "Historical_Simulation"
  attr(result, "approach") <- "adjusted_loss"
  return(invisible(result))
}
# volatility_scaling ------------------------------------------------------
get_return_matrix <- function(price_matrix) {
  M <- nrow(price_matrix)
  N <- ncol(price_matrix)
  return_matrix <- matrix(0, M - 1, N)
  for (i in 1:N) {
    p <- price_matrix[, i]
    return_matrix[, i] <- p[-1]/p[-M] - 1
  }
  return(return_matrix)
}
volatility_scaling <- function(price_matrix, portfolio) {
  number_of_prices <- nrow(price_matrix)
  number_of_scenarios <- number_of_prices - 1
  number_of_assets <- ncol(price_matrix)
  calculate_volatility <- function(return, lambda = 0.94) {
    return_length <- length(return)
    variance <- rep(0, return_length + 1)
    variance[1] <- var(return)
    for (i in 2:length(variance)) {
      variance[i] <- variance[i - 1]*lambda + (1 - lambda)*return[i - 1]^2
    }
    return(sqrt(variance))
  }
  calculate_multiplier <- function(price) {
    return <- price[-1]/price[-length(price)] - 1
    volatility <- calculate_volatility(return)
    multiplier <- rep(0, length(return))
    for (i in 1:length(multiplier)) {
      multiplier[i] <- (price[i] + (price[i+1] - price[i])*tail(volatility, 1)/volatility[i])/price[i]
    }
    return(multiplier)
  }
  multiplier_matrix <- matrix(0, number_of_scenarios, number_of_assets)
  for (j in 1:number_of_assets) {
    multiplier <- calculate_multiplier(price_matrix[, j])
    for (i in 1:number_of_scenarios) {
      multiplier_matrix[i, j] <- multiplier[i]
    }
  }
  portfolio_value <- rep(0, number_of_scenarios)
  for (i in 1:number_of_scenarios) {
    portfolio_value[i] <- sum(portfolio*multiplier_matrix[i, ])
  }
  loss <- sum(portfolio) - portfolio_value
  scenario_number <- order(loss, decreasing = TRUE)
  loss <- sort(loss, decreasing = TRUE)
  num <- as.integer(floor(number_of_scenarios*0.01))
  VaR <- loss[num]
  ES <- mean(loss[1:(num-1)])
  result <- list(VaR = VaR, ES = ES)
  class(result) <- "Historical_Simulation"
  attr(result, "approach") <- "volatility_scaling"
  return(invisible(result))
}
# equal_weight -----------------------------------------------------------------------
equal_weight <- function(return_matrix, portfolio) {
  covm <- cov(return_matrix)
  portfolio_sd <- sqrt((t(portfolio)%*%covm%*%portfolio)[1,1])
  VaR <- portfolio_sd*qnorm(0.99)
  ES <- portfolio_sd*exp(-qnorm(0.99)^2/2)/(sqrt(2*pi)*0.01)
  result <- list(VaR = VaR, ES = ES)
  class(result) <- "Model_Building"
  attr(result, "approach") <- "equal_weight"
  return(invisible(result))
}
EWMA <- function(return_matrix, portfolio, lambda = 0.94) {
  var_EWMA_function <- function(x, y = NULL) {
    if (is.null(y)) y <- x
    value <- cov(x, y)
    N <- length(x)
    for (i in 1:N) {
      value <- lambda*value + (1 - lambda)*x[i]*y[i]
    }
    return(value)
  }
  N <- ncol(return_matrix)
  covm <- matrix(0, N, N)
  cat("Calculating variance...\n")
  for (i in 1:N) {
    cat("----(", i, "/", N, ")----\n")
    covm[i, i] <- var_EWMA_function(return_matrix[, i])
  }
  cat("Calculating covariance...\n")
  for (i in 1:(N-1)) {
    cat("----(", i, "/", N - 1, ")----\n")
    for (j in (i+1):N) {
      covm[i, j] <- var_EWMA_function(return_matrix[, i], return_matrix[, j])
      covm[j, i] <- covm[i, j]
    }
  }
  portfolio_sd <- sqrt((t(portfolio)%*%covm%*%portfolio)[1,1])
  VaR <- portfolio_sd*qnorm(0.99)
  ES <- portfolio_sd*exp(-qnorm(0.99)^2/2)/(sqrt(2*pi)*0.01)
  result <- list(VaR = VaR, ES = ES)
  class(result) <- "Model_Building"
  attr(result, "approach") <- "EWMA"
  return(invisible(result))
}
# run --------------------------------------------------------------------
cat("\014")
# rm(list=ls())
da <- read.csv("portfolio4indices.csv")
price_matrix <- unname(as.matrix(da))
portfolio <- c(4000, 3000, 1000, 2000)
loss <- calulate_loss(price_matrix, portfolio) # not sorted
h1=traditional(loss)
h2=traditional_weighting(loss)
h3=adjusted_loss(loss)
return_matrix <- get_return_matrix(price_matrix)
h4=volatility_scaling(price_matrix, portfolio)

m1=equal_weight(return_matrix, portfolio)
m2=EWMA(return_matrix, portfolio)

h1
h2
h3
h4
m1
m2


