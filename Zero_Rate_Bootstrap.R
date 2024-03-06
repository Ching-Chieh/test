# John C. Hull. Options, Futures, and Other Derivatives, Global Edition. 9th p.106
# R6 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(R6)
Bond_creator <- R6Class("Bond", list(
  principal = 100,
  term = NULL,
  coupon = NULL,
  price = NULL,
  initialize = function(principal = 100, term, coupon, price) {
    stopifnot(is.numeric(principal), length(principal) == 1)
    stopifnot(is.numeric(term), length(term) == 1)
    stopifnot(is.numeric(coupon), length(coupon) == 1)
    stopifnot(is.numeric(price), length(price) == 1)
    self$principal <- principal
    self$term <- term
    self$coupon <- coupon
    self$price <- price
  },
  print = function(...) {
    cat("Bond: \n")
    cat(" Principal: ", self$principal, "\n", sep = "")
    cat(" Time to maturity: ", self$term, "\n", sep = "")
    cat(" Coupon: ", self$coupon, "\n", sep = "")
    cat(" Market price: ", self$price, "\n", sep = "")
    invisible(self)
  }
))

x1 = Bond_creator$new(principal = 100,
                      term = 0.25,
                      coupon = 0,
                      price = 97.5)
x2 = Bond_creator$new(principal = 100,
                      term = 0.5,
                      coupon = 0,
                      price = 94.9)
x3 = Bond_creator$new(principal = 100,
                      term = 1,
                      coupon = 0,
                      price = 90)
x4 = Bond_creator$new(principal = 100,
                      term = 1.5,
                      coupon = 8,
                      price = 96)
x5 = Bond_creator$new(principal = 100,
                      term = 2,
                      coupon = 12,
                      price = 101.6)
bonds <- list(x1,x2,x3,x4,x5)
# 2 -----------------------------------------------------------------------
library(purrr)
zero_rate_bootstrap <- function(bonds){
  zero_rate_ZCB <- function(b){
    comp_freq = 1/b$term
    discrete_rate = (b$principal - b$price) * comp_freq / b$price
    zero_rate = comp_freq * log(1 + (discrete_rate/comp_freq))
    zero_rate
  }
  zero_rate_CB <- function(b, current_curve, terms){
    coupon_1period =  b$coupon / 2
    timepoints = head(seq(0.5, b$term, 0.5), -1)
    ind = which(terms %in% timepoints)
    sum0 = sum(coupon_1period * exp(-current_curve[ind] * timepoints))
    zero_rate = -log((b$price - sum0) / (b$principal + coupon_1period)) / b$term
    zero_rate
  }
  terms <- map_dbl(bonds, ~.x$term)
  zero_rate_curve <- numeric()
  for (i in seq_along(bonds)) {
    b = bonds[[i]]
    if (b$coupon == 0) zero_rate_curve <- c(zero_rate_curve, zero_rate_ZCB(b))
    else zero_rate_curve <- c(zero_rate_curve, zero_rate_CB(b, zero_rate_curve, terms))
  }
  zero_rate_curve
}
round(zero_rate_bootstrap(bonds),5)






