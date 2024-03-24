# Statistical Arbitrage (Cointegrated VAR model)
cat("\014")
rm(list=ls())
library(tidyverse)
library(lubridate)
library(urca)
da=read_csv("aaplmsft2011.csv")
sig=stats::sigma(lm(msft~aapl,da))
xt=as.matrix(select(da,msft,aapl))
m1=urca::ca.jo(xt,type='eigen',ecdet="const",K=2,spec='transitory')
gam=-unname(m1@V[,1])[2]
mu=-unname(m1@V[,1])[3]
da=mutate(da,spread = msft - gam*aapl)
upp=mu+sig
lowe=mu-sig
cat('Buy a share of MSFT and short ',round(gam,4),' shares of AAPL\n',
    'when spread equals ',round(lowe,4),'\n',
    'Unwind the position when spread equals ',round(upp,4),'\n',sep = "")
cat('The mean of the spread is',round(mu,4),'\n')
ggplot(da,aes(date,spread)) + 
  geom_hline(yintercept = upp,color='red') +
  geom_hline(yintercept = lowe,color='green') +
  geom_line(color='blue') + 
  scale_x_date(date_labels = "%Y",date_breaks = "1 year")
