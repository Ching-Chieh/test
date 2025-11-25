# 2 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
graphics.off()
library(tidyverse)
adam <- function(f, grad_f, theta0, alpha = 0.001, 
                 beta1 = 0.9, beta2 = 0.999, eps = 1e-8, 
                 max_iter = 1000) {
  
  theta <- theta0
  m <- rep(0, length(theta))
  v <- rep(0, length(theta))
  t <- 0
  
  history <- data.frame(iter = integer(), theta1 = numeric(), theta2 = numeric(), loss = numeric())
  
  for (i in 1:max_iter) {
    t <- t + 1
    
    g <- grad_f(theta)
    
    m <- beta1 * m + (1 - beta1) * g
    v <- beta2 * v + (1 - beta2) * (g^2)
    
    m_hat <- m / (1 - beta1^t)
    v_hat <- v / (1 - beta2^t)
    
    theta <- theta - alpha * m_hat / (sqrt(v_hat) + eps)
    
    loss <- f(theta)
    history <- rbind(history, data.frame(iter = i, theta1 = theta[1], theta2 = theta[2], loss = loss))
    
    if (sqrt(sum(g^2)) < 1e-6) break
  }
  
  list(theta = theta, history = history)
}

adaMax <- function(f, grad_f, theta0, alpha = 0.002, 
                   beta1 = 0.9, beta2 = 0.999, eps = 1e-8, 
                   max_iter = 1000) {
  
  theta <- theta0
  m <- rep(0, length(theta))
  u <- rep(0, length(theta))
  t <- 0
  
  history <- data.frame(iter = integer(), theta1 = numeric(), theta2 = numeric(), loss = numeric())
  
  for (i in 1:max_iter) {
    t <- t + 1
    g <- grad_f(theta)
    m <- beta1 * m + (1 - beta1) * g
    u <- pmax(beta2 * u, abs(g))
    theta <- theta - (alpha / (1-beta1^t)) * (m / u)
    
    loss <- f(theta)
    history <- rbind(history, data.frame(iter = i, theta1 = theta[1], theta2 = theta[2], loss = loss))
    
    if (sqrt(sum(g^2)) < 1e-6) break
  }
  
  list(theta = theta, history = history)
}


# (x-3)^2 + (y+2)^2
f <- function(theta) {
  (theta[1] - 3)^2 + (theta[2] + 2)^2
}

grad_f <- function(theta) {
  c(2 * (theta[1] - 3),
    2 * (theta[2] + 2))
}

theta0 <- c(-5, 5)

#result <- adam(f, grad_f, theta0, alpha = 0.1, max_iter = 500)
result <- adaMax(f, grad_f, theta0, alpha = 0.1, max_iter = 500)

tail(result$history)

cat("最佳參數：", result$theta, "\n")
cat("最小損失：", tail(result$history$loss, 1), "\n")

# plot(result$history$iter, result$history$loss, type = "l",
#      main = "Adam Optimization Loss",
#      xlab = "Iteration", ylab = "Loss", col = "blue")
# plot --------------------------------------------------------------------


x <- seq(-6, 6, length.out = 100)
y <- seq(-6, 6, length.out = 100)
z <- outer(x, y, function(a, b) (a - 3)^2 + (b + 2)^2)

df <- expand.grid(x = x, y = y)
df$z <- as.vector(z)

ggplot(df, aes(x, y)) +
  geom_contour_filled(aes(z = z), bins = 20, alpha = 0.8) +
  geom_path(data = result$history, aes(x = theta1, y = theta2), color = "red", linewidth = 1.2) +
  geom_point(data = result$history[1,], aes(x = theta1, y = theta2), color = "black", size = 3) +
  geom_point(data = tail(result$history, 1), aes(x = theta1, y = theta2), color = "yellow", size = 3) +
  geom_text(
    data = result$history[1,],
    aes(x = theta1, y = theta2, label = "Start"),
    vjust = -1, color = "black", fontface = "bold"
  ) +
  geom_text(
    data = tail(result$history, 1),
    aes(x = theta1, y = theta2, label = "End"),
    vjust = -1, color = "yellow4", fontface = "bold"
  ) +
  labs(
    x = expression(theta[1]),
    y = expression(theta[2])
  ) +
  theme_minimal() +
  theme(legend.position = "none")


