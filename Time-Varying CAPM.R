# This scripts includes:
# 1. Use GARCH(1,1) to calculate time-Varying Beta of TSLA
# 2. Use a state-space model to calculate time-Varying Alpha and Beta of AAPL
# Time-Varying Beta of TSLA, GARCH ----------------------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
library(lubridate)
quantmod::getSymbols(c('^GSPC','TSLA'), from = '2018-01-01')
sp500 <- GSPC %>%
  as_tibble(rownames = 'date') %>% 
  mutate(date=ymd(date)) %>% 
  select(date, sp500.close = GSPC.Close)
tsla <- TSLA %>% 
  as_tibble(rownames = 'date') %>% 
  mutate(date=ymd(date)) %>% 
  select(date, tsla.close = TSLA.Close)
da <- sp500 %>% 
  left_join(tsla, by = 'date') %>% 
  drop_na() %>% 
  mutate(sp500=log(sp500.close/lag(sp500.close)),
         tsla=log(tsla.close/lag(tsla.close))) %>% 
  drop_na() %>% 
  select(date,sp500,tsla)
rm(list=c('sp500','tsla'))
sp500=da$sp500
tsla=da$tsla
xp=sp500+tsla
xm=sp500-tsla
library(fGarch)
m1=garchFit(~1+garch(1,1),data=xp,trace=F)
m2=garchFit(~1+garch(1,1),data=xm,trace=F)
m3=garchFit(~1+garch(1,1),data=sp500,trace=F)
vxp=fGarch::volatility(m1)
vxm=fGarch::volatility(m2)
vsp500=fGarch::volatility(m3)
beta=(vxp^2-vxm^2)/(4*vsp500^2)
c2=coef(lm(tsla~sp500))[[2]]
df <- tibble(date=da$date,beta=beta)
ggplot(df, aes(date,beta)) + 
  geom_hline(yintercept = c2) + 
  geom_line(color='red') + 
  scale_x_date(date_breaks = "1 year",date_labels = "%Y") + 
  labs(y = "Beta",
       title = 'Time-Varying Beta of TSLA')
# AAPL Time-Varying CAPM - State-Space Model -----------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
library(lubridate)
quantmod::getSymbols(c('^GSPC','AAPL'), from = '2010-01-01')
sp500 <- GSPC %>%
  as_tibble(rownames = 'date') %>% 
  mutate(date=ymd(date)) %>% 
  select(date, sp500.close = GSPC.Close)
aapl <- AAPL %>% 
  as_tibble(rownames = 'date') %>% 
  mutate(date=ymd(date)) %>% 
  select(date, aapl.close = AAPL.Close)
sp500 %>% 
  left_join(aapl, by = 'date') %>% 
  drop_na() %>% 
  mutate(sp500=log(sp500.close/lag(sp500.close)),
         aapl=log(aapl.close/lag(aapl.close))) %>% 
  drop_na() %>% 
  select(date,sp500,aapl) %>% 
  write_csv('d-sp500aapl1023.csv')
# RATS program  ---------------------------------------------------------------------------------------------
end(reset)
OPEN DATA "C:\Users\Jimmy\Desktop\d-sp500aapl1023.csv"
DATA(FORMAT=PRN,NOLABELS,ORG=COLUMNS,TOP=2,LEFT=2) 1 3442 sp aapl
nonlin leps leta
compute leps=leta=0.0
dlm(y=aapl,c=||1.0,sp||,sv=1.0,var=concentrate,sw=%diag(||exp(leta),exp(leps)||),$
   presample=ergodic,method=bfgs,type=smoothed) / xstates vstates
*
? "Measurement Stdev" @20 sqrt(%variance)
? "Alpha Stdev" @20 sqrt(%variance*exp(leta))
? "Beta Stdev" @20 sqrt(%variance*exp(leps))
*
set alpha = xstates(t)(1)
set beta  = xstates(t)(2)
set expret = %dot(||1.0,sp||,xstates)
*
print / alpha beta expret
spgraph(hfields=2,vfields=2,footer="AAPL Time-varying CAPM")
graph(hlabel="Return")
# aapl
graph(hlabel="Expected return")
# expret
graph(hlabel="Alpha")
# alpha
graph(hlabel="Beta")
# beta
spgraph(done)
