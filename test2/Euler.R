# Euler for loop -----------------------------------------------------------------------
# Dennis G. Zill - Advanced Engineering Mathematics p71
# y' = 0.1*sqrt(y) + 0.4*x^2, y(2)=4
cat("\014")
rm(list=ls())
Euler_method <- function(x0, y0, h, steps, f) {
  x <- seq(x0, by = h, length.out = steps + 1)
  y <- numeric(length(x))
  y[1] <- y0
  for (i in 1:steps) {
    y[i+1] <- y[i] + h*f(x[i], y[i])
  }
  return(y)
}

x0=2
y0=4
steps=5
h=0.1
f <- function(x, y) 0.1*sqrt(y)+0.4*x^2
round(Euler_method(x0, y0, h, steps, f), 4)

# Euler accumulate -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
Euler_method_accumulate <- function(x0, y0, h, steps, f) {
  x <- seq(x0, by = h, length.out = steps+1)
  f1 <- function(y, x) y + h*f(x, y)
  y <- head(accumulate(x, f1, .init = y0), -1)
  return(y)
}
x0=2
y0=4
steps=5
h=0.1
f <- function(x, y) 0.1*sqrt(y) + 0.4*x^2
round(Euler_method_accumulate(x0, y0, h, steps, f), 4)
# Improved Euler for loop -----------------------------------------------------------------------
# Dennis G. Zill - Advanced Engineering Mathematics p301
# y'=2xy, y(1)=1
cat("\014")
rm(list=ls())
Improved_Euler_method <- function(x0, y0, h, steps, f) {
  x <- seq(x0, by = h, length.out = steps+1)
  y <- numeric(length(x))
  y[1] <- y0
  for (i in 1:steps) {
    y_star <- y[i] + h*f(x[i], y[i])
    y[i+1] <- y[i] + h*(f(x[i], y[i]) + f(x[i+1], y_star))/2
  }
  return(y)
}

x0= 1
y0= 1
steps= 5
h= 0.1
f <- function(x, y) 2*x*y
round(Improved_Euler_method(x0, y0, h, steps, f), 4)



