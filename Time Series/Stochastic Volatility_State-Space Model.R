# Stochastic Volatility of TSLA - State-Space Model
#   log(h(t)) = gamma + phi*log(h(t-1)) + w(t)
#   y(t) = sqrt(h(t))*v(t),  v(t) ~ N(0,1)
# 1. R fetch TSLA data -----------------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
library(lubridate)
quantmod::getSymbols('TSLA', from = '2018-01-01')
TSLA %>% 
  as_tibble(rownames = 'date') %>% 
  mutate(date=ymd(date)) %>% 
  select(date, tsla.close = TSLA.Close) %>% 
  mutate(tsla = log(tsla.close/dplyr::lag(tsla.close))) %>% 
  slice(-1) %>%
  select(date, tsla) %>%
  write_csv('d-tsla2018.csv')
# 2. RATS program -----------------------------------------------------------------------------
end(reset)
OPEN DATA "C:\Users\Jimmy\Desktop\d-tsla2018.csv"
DATA(FORMAT=PRN,NOLABELS,ORG=COLUMNS,TOP=2,LEFT=2) 1 1432 TSLA
*
compute meanx2=%digamma(0.5)-log(0.5)
compute varx2 =%trigamma(0.5)
diff(center) tsla / demean
*
nonlin phi sw gammax
set ysq = log(demean^2)-meanx2
boxjenk(ar=1,ma=1,constant,noprint) ysq
compute phi=%beta(2),sw=-phi*varx2*(1+%beta(3)^2)/%beta(3)-(1+phi^2)*varx2
compute sw=%if(sw<0,.1,sw)
compute gammax=%mean
*
dlm(method=bfgs,sw=sw,sv=varx2,y=ysq,type=filter,c=1.0, $
   sx0=sw/(1-phi^2),x0=gammax,a=phi,z=gammax*(1-phi)) / states
set h_sv = exp(states(t)(1))
*
* compare with EGARCH(1,1)
garch(p=1,q=1,exp,nomean,hseries=h_egarch) / demean
*
graph(footer="Estimates of Variance from SV and EGARCH Models",key=upleft,klabels=||"SV","EGARCH"||) 2
# h_sv
# h_egarch
