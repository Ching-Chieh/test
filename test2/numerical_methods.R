# RK4 y'=2xy, y(1)=1 ---------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
Euler_method <- function(x0, y0, h, steps, f) {
  x <- seq(x0, by = h, length.out = steps + 1)
  y <- numeric(length(x))
  y[1] <- y0
  for (i in 1:steps) {
    y[i+1] <- y[i] + h*f(x[i], y[i])
  }
  return(y)
}
Improved_Euler_method <- function(x0, y0, h, steps, f) {
  x <- seq(x0, by = h, length.out = steps + 1)
  y <- numeric(length(x))
  y[1] <- y0
  for (i in 1:steps) {
    y_star <- y[i] + h*f(x[i], y[i])
    y[i+1] <- y[i] + h*(f(x[i], y[i]) + f(x[i+1], y_star))/2
  }
  return(y)
}
RK4_method <- function(x0, y0, h, steps, f) {
  x = seq(x0, by = h, length.out = steps + 1)
  y = numeric(length(x))
  y[1] = y0
  for (n in 1:steps) {
    k1 = f(x[n], y[n])
    k2 = f(x[n] + h/2, y[n] + h/2*k1)
    k3 = f(x[n] + h/2, y[n] + h/2*k2)
    k4 = f(x[n] + h,   y[n] + h*k3)
    y[n+1] <- y[n] + h/6*(k1 + 2*k2 + 2*k3 + k4)
  }
  return(y)
}

x0= 1
y0= 1
h= 0.05
steps= 10
f <- function(x, y) 2*x*y

Euler <- Euler_method(x0, y0, h, steps, f)
Improved_Euler <- Improved_Euler_method(x0, y0, h, steps, f)
RK4 <- RK4_method(x0, y0, h, steps, f)
actual_value <- exp(seq(x0, by = h, length.out = steps + 1)^2 - 1)

tibble(
  n = 0:steps,
  x = seq(x0, by = h, length.out = steps + 1),
  Euler,
  Improved_Euler,
  RK4,
  actual_value
) %>% 
  mutate(across(c(Euler, Improved_Euler, RK4, actual_value), ~num(.x, digits = 4)))

# y'=x+y-1 y(0)=1 --------------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
Euler_method <- function(x0, y0, h, steps, f) {
  x <- seq(x0, by = h, length.out = steps + 1)
  y <- numeric(length(x))
  y[1] <- y0
  for (i in 1:steps) {
    y[i+1] <- y[i] + h*f(x[i], y[i])
  }
  return(y)
}
Improved_Euler_method <- function(x0, y0, h, steps, f) {
  x <- seq(x0, by = h, length.out = steps + 1)
  y <- numeric(length(x))
  y[1] <- y0
  for (i in 1:steps) {
    y_star <- y[i] + h*f(x[i], y[i])
    y[i+1] <- y[i] + h*(f(x[i], y[i]) + f(x[i+1], y_star))/2
  }
  return(y)
}
RK4_method <- function(x0, y0, h, steps, f) {
  x = seq(x0, by = h, length.out = steps + 1)
  y = numeric(length(x))
  y[1] = y0
  for (n in 1:steps) {
    k1 = f(x[n], y[n])
    k2 = f(x[n] + h/2, y[n] + h/2*k1)
    k3 = f(x[n] + h/2, y[n] + h/2*k2)
    k4 = f(x[n] + h,   y[n] + h*k3)
    y[n+1] <- y[n] + h/6*(k1 + 2*k2 + 2*k3 + k4)
  }
  return(y)
}
ABM_method <- function(x0, y0, h, steps, f) { # Adams-Bashforth-Moulton method
  x = seq(x0, by = h, length.out = steps + 1)
  y = numeric(length(x))
  y[1] = y0
  y_prime = numeric(length(x))
  # RK4
  for (n in 1:3) { # y1 ~ y3 index: 2 ~ 4
    k1 = f(x[n], y[n])
    k2 = f(x[n] + h/2, y[n] + h/2*k1)
    k3 = f(x[n] + h/2, y[n] + h/2*k2)
    k4 = f(x[n] + h,   y[n] + h*k3)
    y[n+1] = y[n] + h/6*(k1 + 2*k2 + 2*k3 + k4)
  }
  y_prime[1:4] = f(x[1:4], y[1:4])  # y0' y1' y2' y3'
  for (n in 4:steps) {  # y4 ~ y10  index: 5 ~ 11
    y_star = y[n] + h/24*(55*y_prime[n] - 59*y_prime[n-1] + 37*y_prime[n-2] - 9*y_prime[n-3])
    y_prime[n+1] = f(x[n+1], y_star)
    y[n+1] = y[n] + h/24*(9*y_prime[n+1] + 19*y_prime[n] - 5*y_prime[n-1] + y_prime[n-2])
  }
  return(y)
}

sol <- function(x) -x + exp(x)
x0 = 0
y0 = 1
h = 0.05
steps = 10
f = \(x, y) x + y - 1
# ABM_method(0, 1, 0.2, 4, f)  # y0~y4
# ABM_method(0, 1, 0.2, 10, f) # y0~y10
da <- tibble(
  n = 0:steps,
  x = seq(x0, by = h, length.out = steps + 1),
  actual_value = sol(x),
  Euler = Euler_method(x0, y0, h, steps, f),
  Improved_Euler = Improved_Euler_method(x0, y0, h, steps, f),
  RK4 = RK4_method(x0, y0, h, steps, f),
  ABM = ABM_method(x0, y0, h, steps, f)
)
da %>% as.data.frame

# error
map(c("Euler", "Improved_Euler", "RK4", "ABM"), 
      ~da[11, "actual_value", drop=TRUE] - da[11, .x, drop=TRUE]) %>% 
  purrr::set_names(c("Euler", "Improved_Euler", "RK4", "ABM"))



