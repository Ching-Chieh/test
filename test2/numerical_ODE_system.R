# Dennis G. Zill - Advanced Engineering Mathematics p312
# x'= 2x+4y
# y'= -x+6y
# x(0)= -1, y(0)= 6
# deSolve RK4 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(deSolve)
model <- function(t, state, parameters) {
  with(as.list(c(state, parameters)), {
    dxdt <- 2*x + 4*y
    dydt <- -x + 6*y
    return(list(c(dxdt, dydt)))
  })
}
state <- c(x = -1, y = 6)
t <- seq(0, 0.6, by = 0.2)
solution <- ode(
  y = state,
  times = t,
  func = model,
  parms = NULL,
  method = "rk4"
)
library(tidyverse)
df <- as.data.frame(solution)
df %>% 
  as_tibble %>% 
  mutate(
    x = num(x, digits = 4),
    y = num(y, digits = 4)
    )

x <- function(t) (26*t-1)*exp(4*t)
y <- function(t) (13*t+6)*exp(4*t)
t=seq(-1.2, 0.2, 0.01)
plot(t, x(t), ylab = "", type = "l", col = "green")
lines(t, y(t), col = "red")
text(0.15, x(0.15), "x(t)", pos = 4, col = "green")
text(-0.2, y(-0.2), "y(t)", pos = 4, col = "red")
abline(h = 0, v = 0)


# Euler’s method -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
h= 0.2
t0= 0
x0= -1
y0= 6
steps= 3
t <- seq(t0, by = h, length.out = steps + 1)
x <- numeric(length(t))
y <- numeric(length(t))
x[1]= x0
y[1]= y0
f <- function(t, x, y) 2*x+4*y
g <- function(t, x, y)  -x+6*y
for (n in 1:steps) {
  x[n+1] <- x[n] + h*f(t[n], x[n], y[n])
  y[n+1] <- y[n] + h*g(t[n], x[n], y[n])
}
tibble(t, x, y) %>% 
  mutate(
    x = num(x, digits = 4),
    y = num(y, digits = 4)
  )
# RK4 method ---------------------------------------------------------------------
cat("\014")
rm(list=ls())
h= 0.2
t0= 0
x0= -1
y0= 6
steps= 3
t <- seq(t0, by = h, length.out = steps + 1)
x <- numeric(length(t))
y <- numeric(length(t))
x[1]= x0
y[1]= y0
f <- function(t, x, y) 2*x+4*y
g <- function(t, x, y)  -x+6*y
for (n in 1:steps) {
  m1 = f(t[n], x[n], y[n])
  k1 = g(t[n], x[n], y[n])
  
  m2 = f(t[n] + 1/2*h, x[n] + 1/2*h*m1, y[n] + 1/2*h*k1)
  k2 = g(t[n] + 1/2*h, x[n] + 1/2*h*m1, y[n] + 1/2*h*k1)
  
  m3 = f(t[n] + 1/2*h, x[n] + 1/2*h*m2, y[n] + 1/2*h*k2)
  k3 = g(t[n] + 1/2*h, x[n] + 1/2*h*m2, y[n] + 1/2*h*k2)
  
  m4 = f(t[n] + h, x[n] + h*m3, y[n] + h*k3)
  k4 = g(t[n] + h, x[n] + h*m3, y[n] + h*k3)
  
  x[n+1] <- x[n] + h/6*(m1 + 2*m2 + 2*m3 + m4)
  y[n+1] <- y[n] + h/6*(k1 + 2*k2 + 2*k3 + k4)
}
tibble(t, x, y) %>% 
  mutate(
    x = num(x, digits = 4),
    y = num(y, digits = 4)
  )
# comparison -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
h= 0.2
t0= 0
x0= -1
y0= 6
steps= 3
t <- seq(t0, by = h, length.out = steps + 1)
f <- function(t, x, y) 2*x+4*y
g <- function(t, x, y)  -x+6*y

Euler_method <- function(t) {
  x <- numeric(length(t))
  y <- numeric(length(t))
  x[1]= x0
  y[1]= y0
  for (n in 1:steps) {
    x[n+1] <- x[n] + h*f(t[n], x[n], y[n])
    y[n+1] <- y[n] + h*g(t[n], x[n], y[n])
  }
  return(list(x = x, y = y))
}
RK4_method <- function(t) {
  x <- numeric(length(t))
  y <- numeric(length(t))
  x[1]= x0
  y[1]= y0
  for (n in 1:steps) {
    m1 = f(t[n], x[n], y[n])
    k1 = g(t[n], x[n], y[n])
    
    m2 = f(t[n] + 1/2*h, x[n] + 1/2*h*m1, y[n] + 1/2*h*k1)
    k2 = g(t[n] + 1/2*h, x[n] + 1/2*h*m1, y[n] + 1/2*h*k1)
    
    m3 = f(t[n] + 1/2*h, x[n] + 1/2*h*m2, y[n] + 1/2*h*k2)
    k3 = g(t[n] + 1/2*h, x[n] + 1/2*h*m2, y[n] + 1/2*h*k2)
    
    m4 = f(t[n] + h, x[n] + h*m3, y[n] + h*k3)
    k4 = g(t[n] + h, x[n] + h*m3, y[n] + h*k3)
    
    x[n+1] <- x[n] + h/6*(m1 + 2*m2 + 2*m3 + m4)
    y[n+1] <- y[n] + h/6*(k1 + 2*k2 + 2*k3 + k4)
  }
  return(list(x = x, y = y))
}
Euler <- Euler_method(t)
RK4 <- RK4_method(t)
library(deSolve)
deSolve_RK4_method <- function(t) {
  model <- function(time, state, parameters) {
    with(as.list(c(state, parameters)), {
      dxdt <- 2*x + 4*y
      dydt <- -x + 6*y
      return(list(c(dxdt, dydt)))
    })
  }
  state <- c(x = x0, y = y0)
  solution <- ode(
    y = state,
    times = t,
    func = model,
    parms = NULL,
    method = "rk4"
  )
  df <- as.data.frame(solution)
  return(list(x = df$x, y = df$y))
}
deSolve_Euler_method <- function(t) {
  model <- function(time, state, parameters) {
    with(as.list(c(state, parameters)), {
      dxdt <- 2*x + 4*y
      dydt <- -x + 6*y
      return(list(c(dxdt, dydt)))
    })
  }
  state <- c(x = x0, y = y0)
  solution <- ode(
    y = state,
    times = t,
    func = model,
    parms = NULL,
    method = "euler"
  )
  df <- as.data.frame(solution)
  return(list(x = df$x, y = df$y))
}

deSolve_RK4 <- deSolve_RK4_method(t)
deSolve_Euler <- deSolve_Euler_method(t)
tibble(
  t,
  Euler = Euler$x,
  deSolve_Euler = deSolve_Euler$x,
  RK4 = RK4$x,
  deSolve_RK4 = deSolve_RK4$x
) %>% 
  mutate(across(-t, ~num(.x, digits = 4)))
tibble(
  t,
  Euler = Euler$y,
  deSolve_Euler = deSolve_Euler$y,
  RK4 = RK4$y,
  deSolve_RK4 = deSolve_RK4$y
) %>% 
  mutate(across(-t, ~num(.x, digits = 4)))
