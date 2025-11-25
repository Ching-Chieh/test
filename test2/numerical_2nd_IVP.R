# Dennis G. Zill - Advanced Engineering Mathematics p310
# y''+xy'+y=0, y(0)=1, y'(0)=2
# deSolve ----------------------------------------------------
cat("\014")
rm(list=ls())
library(deSolve)
model <- function(x, state, parameters) {
  with(as.list(state), {
    dy <- u
    du <- -x*u-y
    return(list(c(dy, du)))
  })
}
state <- c(y = 1, u = 2)
times <- seq(0, 25, by = 0.1)
Euler <- ode(
  y = state,
  times = times,
  func = model,
  parms = NULL,
  method = "euler"
)
RK4 <- ode(
  y = state,
  times = times,
  func = model,
  parms = NULL,
  method = "rk4"
  )
Euler <- as.data.frame(Euler)
RK4 <- as.data.frame(RK4)

plot(Euler$time, Euler$y, type = "l", xlab = "x", ylab = "y", col = "green")
lines(RK4$time, RK4$y, col = "red")
# Euler’s Method -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
h= 0.1
x0= 0
y0= 1
u0= 2
steps= 250
x <- seq(x0, by = h, length.out = steps + 1)
y <- numeric(length(x))
u <- numeric(length(x))
y[1]= y0
u[1]= u0
for (n in 1:steps) {
  y[n+1] <- y[n] + h*u[n]
  u[n+1] <- u[n] + h*(-x[n]*u[n] - y[n])
}
plot(x, y, type = "l")
# RK4 ---------------------------------------------------------------------
cat("\014")
rm(list=ls())
h= 0.1
x0= 0
y0= 1
u0= 2
steps= 250
x <- seq(x0, by = h, length.out = steps + 1)
y <- numeric(length(x))
u <- numeric(length(x))
y[1]= y0
u[1]= u0
f <- function(x, y, u) -x*u-y
for (n in 1:steps) {
  m1 = u[n]
  k1 = f(x[n], y[n], u[n])
  m2 = u[n] + 1/2*h*k1
  k2 = f(x[n] + 1/2*h, y[n] + 1/2*h*m1, u[n] + 1/2*h*k1)
  m3 = u[n] + 1/2*h*k2
  k3 = f(x[n] + 1/2*h, y[n] + 1/2*h*m2, u[n] + 1/2*h*k2)
  m4 = u[n] + h*k3
  k4 = f(x[n] + h, y[n] + h*m3, u[n] + h*k3)
  
  y[n+1] <- y[n] + h/6*(m1 + 2*m2 + 2*m3 + m4)
  u[n+1] <- u[n] + h/6*(k1 + 2*k2 + 2*k3 + k4)
}
plot(x, y, type = "l")
# 2 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
h= 0.1
x0= 0
y0= 1
u0= 2
steps= 250
x <- seq(x0, by = h, length.out = steps + 1)
Euler_method <- function(x) {
  y <- numeric(length(x))
  u <- numeric(length(x))
  y[1]= y0
  u[1]= u0
  for (n in 1:steps) {
    y[n+1] <- y[n] + h*u[n]
    u[n+1] <- u[n] + h*(-x[n]*u[n] - y[n])
  }
  return(y)
}
RK4_method <- function(x) {
  y <- numeric(length(x))
  u <- numeric(length(x))
  y[1]= y0
  u[1]= u0
  f <- function(x, y, u) -x*u-y
  for (n in 1:steps) {
    m1 = u[n]
    k1 = f(x[n], y[n], u[n])
    m2 = u[n] + 1/2*h*k1
    k2 = f(x[n] + 1/2*h, y[n] + 1/2*h*m1, u[n] + 1/2*h*k1)
    m3 = u[n] + 1/2*h*k2
    k3 = f(x[n] + 1/2*h, y[n] + 1/2*h*m2, u[n] + 1/2*h*k2)
    m4 = u[n] + h*k3
    k4 = f(x[n] + h, y[n] + h*m3, u[n] + h*k3)
    
    y[n+1] <- y[n] + h/6*(m1 + 2*m2 + 2*m3 + m4)
    u[n+1] <- u[n] + h/6*(k1 + 2*k2 + 2*k3 + k4)
  }
  return(y)
}
plot(x, Euler_method(x), type = "l", col = "red", ylab = "y")
lines(x, RK4_method(x), col = "green")

