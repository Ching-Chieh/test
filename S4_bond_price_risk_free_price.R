# John C. Hull. Options, Futures, and Other Derivatives, Global Edition. 9th p.570 Example 24.2
# 1 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
setClass("Bond",
         slots = c(
           principal = "numeric",
           term = "numeric",
           coupon_rate = "numeric",
           comp_freq = "numeric"
         ),
         prototype = list(
           principal = NA_real_,
           term = NA_real_,
           coupon_rate = NA_real_,
           comp_freq = NA_real_
         )
)
# Helper
Bond <- function(name, principal, term, coupon_rate, comp_freq) {
  name <- as.character(name)
  principal <- as.double(principal)
  term <- as.double(term)
  coupon_rate <- as.double(coupon_rate)
  comp_freq <- as.double(comp_freq)
  new("Bond",
      principal = principal,
      term = term,
      coupon_rate = coupon_rate,
      comp_freq = comp_freq)
}
# display method
setMethod("show", "Bond", function(object) {
  cat(is(object)[[1]], '\n',
  " Principal: ", object@principal, "\n",
  " Time to maturity: ", object@term, "\n",
  " Coupon rate: ", object@coupon_rate*100, " %\n",
  " ", object@comp_freq, " coupons in a year\n",
  sep = "")
})
setGeneric("price", function(x) standardGeneric("price"))
setMethod("price", "Bond", function(x) {
  y <- c(0.065,0.068,0.0695)[x@term]
  coupon <- x@principal*x@coupon_rate/x@comp_freq
  cf <- rep(coupon, x@term*x@comp_freq)
  cf[length(cf)] <- cf[length(cf)] + x@principal
  t <- seq(1/x@comp_freq, x@term, 1/x@comp_freq)
  sum(cf*exp(-y*t))
})
setGeneric("risk_free_price", function(x) standardGeneric("risk_free_price"))
setMethod("risk_free_price", "Bond", function(x) {
  r = 0.05
  coupon <- x@principal*x@coupon_rate/x@comp_freq
  cf <- rep(coupon, x@term*x@comp_freq)
  cf[length(cf)] <- cf[length(cf)] + x@principal
  t <- seq(1/x@comp_freq, x@term, 1/x@comp_freq)
  sum(cf*exp(-r*t))
})
x1 <- Bond("x1", principal = 100, term = 1, coupon_rate =  0.08, comp_freq =  2)
x2 <- Bond("x2", principal = 100, term = 2, coupon_rate =  0.08, comp_freq =  2)
x3 <- Bond("x3", principal = 100, term = 3, coupon_rate =  0.08, comp_freq =  2)
x1
x2
x3
round(price(x1),2)
round(price(x2),2)
round(price(x3),2)
round(risk_free_price(x1),2)
round(risk_free_price(x2),2)
round(risk_free_price(x3),2)
