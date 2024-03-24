# John C. Hull. Options, Futures, and Other Derivatives, Global Edition. 9th p.106
# S4 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
setClass("Bond",
  slots = c(
    principal = "numeric",
    term = "numeric",
    coupon = "numeric",
    price = "numeric"
  ),
  prototype = list(
    principal = NA_real_,
    term = NA_real_,
    coupon = NA_real_,
    price = NA_real_
  )
)
# Helper
Bond <- function(name, principal, term, coupon, price){
  name <- as.character(name)
  principal <- as.double(principal)
  term <- as.double(term)
  coupon <- as.double(coupon)
  price <- as.double(price)
  new("Bond",
      principal = principal,
      term = term,
      coupon = coupon,
      price = price)
}
# display method
setGeneric("display", function(object) standardGeneric("display"))
setMethod("display", "Bond", function(object) {
  cat("Principal: ", object@principal, "\n")
  cat("Time to maturity: ", object@term, "\n")
  cat("Coupon: ", object@coupon, "\n")
  cat("Market price: ", object@price, "\n")
})
# functions
library(purrr)
zero_rate_bootstrap <- function(bonds){
  zero_rate_ZCB <- function(b){
    comp_freq = 1/b@term
    discrete_rate = (b@principal - b@price) * comp_freq / b@price
    zero_rate = comp_freq * log(1 + (discrete_rate/comp_freq))
    zero_rate
  }
  zero_rate_CB <- function(b, current_curve, terms){
    coupon_1period =  b@coupon / 2
    timepoints = head(seq(0.5, b@term, 0.5), -1)
    ind = which(terms %in% timepoints)
    sum0 = sum(coupon_1period * exp(-current_curve[ind] * timepoints))
    zero_rate = -log((b@price - sum0) / (b@principal + coupon_1period)) / b@term
    zero_rate
  }
  terms <- map_dbl(bonds, ~.x@term)
  zero_rate_curve <- numeric()
  for (i in seq_along(bonds)) {
    b = bonds[[i]]
    if (b@coupon == 0) zero_rate_curve <- c(zero_rate_curve, zero_rate_ZCB(b))
    else zero_rate_curve <- c(zero_rate_curve, zero_rate_CB(b, zero_rate_curve, terms))
  }
  zero_rate_curve
}
bonds <- list(
  Bond("x1", principal = 100, term = 0.25, coupon =  0, price = 97.5),
  Bond("x2", principal = 100, term =  0.5, coupon =  0, price = 94.9),
  Bond("x3", principal = 100, term =    1, coupon =  0, price = 90.0),
  Bond("x4", principal = 100, term =  1.5, coupon =  8, price = 96.0),
  Bond("x5", principal = 100, term =    2, coupon = 12, price = 101.6)
)
round(zero_rate_bootstrap(bonds),5)
