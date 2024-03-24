# John C. Hull. Options, Futures, and Other Derivatives, Global Edition. 9th p.570 Example 24.2
# 1 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(R6)
Bond <- R6Class("Bond",
                public = list(
                  principal = NULL,
                  term = NULL,
                  coupon_rate = NULL,
                  comp_freq = NULL,
                  initialize = function(principal, term, coupon_rate, comp_freq) {
                    self$principal <- principal
                    self$term <- term
                    self$coupon_rate <- coupon_rate
                    self$comp_freq <- comp_freq
                  },
                  print = function(...) {
                    cat("Bond: \n")
                    cat(" Principal: ", self$principal, "\n", sep = "")
                    cat(" Time to maturity: ", self$term, "\n", sep = "")
                    cat(" Coupon rate: ", self$coupon_rate*100, " %\n", sep = "")
                    cat(" ", self$comp_freq, " coupons in a year\n", sep = "")
                    invisible(self)
                  }
                ),
                active = list(
                  price = function(value) {
                    if (missing(value)) {
                      y <- c(0.065,0.068,0.0695)[self$term]
                      cf <- private$.cf_function()
                      t <- private$.t_function()
                      private$.price <- sum(cf*exp(-y*t))
                      private$.price
                    } else stop("Can't set `$price`", call. = FALSE)
                  },
                  risk_free_price = function(value) {
                    if (missing(value)) {
                      r <- 0.05
                      cf <- private$.cf_function()
                      t <- private$.t_function()
                      private$.risk_free_price <- sum(cf*exp(-r*t))
                      private$.risk_free_price
                    } else stop("Can't set `$risk_free_price`", call. = FALSE)
                  }
                ),
                private = list(
                  .price = NULL,
                  .risk_free_price = NULL,
                  .cf_function = function(...) {
                    coupon <- self$principal*self$coupon_rate/self$comp_freq
                    cf <- rep(coupon, self$term*self$comp_freq)
                    cf[length(cf)] <- cf[length(cf)] + self$principal
                    cf
                  },
                  .t_function = function(...) seq(1/self$comp_freq, self$term, 1/self$comp_freq)
                )
)
x1 = Bond$new(principal = 100, term = 1, coupon_rate =  0.08, comp_freq =  2)
x1$price
x1$risk_free_price
# test -----------------------------------------------------------------------
# set price
x1$price <- 8888
# change principal to 1000
x1$principal <- 1000
x1$price
x1$risk_free_price
