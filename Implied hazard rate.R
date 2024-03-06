# Calculate implied hazard rate from market CDS spread
# John C. Hull. Options, Futures, and Other Derivatives, Global Edition. 9th p.600
cat("\014")
rm(list=ls())
f1 <- function(h){
  t = 1:5
  t1 = seq(0.5, by = 1, length.out = 5)
  recovery = 0.4
  r = 0.05
  s = 0.01
  ps = exp(-h*t)
  pd = c(1-ps[1], -diff(ps))
  PV_expected_payment = sum(ps*s*exp(-r*t))
  PV_expected_payoff = sum(pd*(1-recovery)*exp(-r*t1))
  PV_expected_accrual_payment = sum(pd*0.5*s*exp(-r*t1))
  PV_expected_payment + PV_expected_accrual_payment - PV_expected_payoff
}
round(uniroot(f1, interval = c(0,1))$root,4)
