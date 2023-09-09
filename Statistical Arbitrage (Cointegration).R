# Statistical Arbitrage (Cointegrated VAR model)
# 1. Use R and RATS
# 2. All using R
# Step 1: Fetch data using R -------------------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
library(lubridate)
quantmod::getSymbols(c('AAPL','MSFT'), from = '2011-01-01')
aapl <- AAPL %>% 
  as_tibble(rownames = 'date') %>% 
  select(date,aapl=AAPL.Close) %>% 
  mutate(date=ymd(date),aapl=log(aapl))
msft <- MSFT %>%
  as_tibble(rownames = 'date') %>%
  select(date,msft=MSFT.Close) %>% 
  mutate(date=ymd(date),msft=log(msft))
da <- aapl %>% 
  left_join(msft, by = 'date') %>% 
  drop_na()
da %>% write_csv("aaplmsft2011.csv")
# Step 2: Estimate using RATS -----------------------------------------------------------------------------------
end(reset)
OPEN DATA "C:\Users\Jimmy\Desktop\aaplmsft2011.csv"
CALENDAR(D) 2011:1:1
DATA(FORMAT=PRN,NOLABELS,ORG=COLUMNS,TOP=2,LEFT=2) 2011:01:03 2023:03:27 aapl msft
linreg(noprint) msft
# constant aapl
compute se=sqrt(%seesq)
@johmle(det=rc,lags=2,cv=cv)
# msft aapl
compute cv=cv/cv(1)
equation(coeffs=cv) ecteq
# msft aapl constant
*
system(model=ectmodel)
variables msft aapl
lags 1 2
ect ecteq
end(system)
estimate
*
compute gamma = -cv(2)
compute mean = -cv(3)
set spread = msft - gamma*aapl
set up = mean + se 
set low = mean - se
set mu = mean
spgraph(vfields=1)
graph(vlabel="Spread") 4
# spread
# mu
# up
# low
spgraph(done)
* There are some arbitrage opportunities.
* The mean of the spread is 0.41340.
* The standard error of the spread is 0.16043.
* Trading strategy
*  Buy a share of MSFT and short 1.02545 shares of AAPL when spread equals 0.25296 (0.41340 - 0.16043).
*  Unwind the position when spread equals 0.57383 (0.41340 + 0.16043).
# All in R ----------------------------------------------------------------------------------------------------
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
    'when spread equals ',round(upp,4),'\n',
    'Unwind the position when spread equals ',round(lowe,4),'\n',sep = "")
cat('The mean of the spread is',round(mu,4),'\n')
ggplot(da,aes(date,spread)) + 
  geom_hline(yintercept = upp,color='red') +
  geom_hline(yintercept = lowe,color='green') +
  geom_line(color='blue') + 
  scale_x_date(date_labels = "%Y",date_breaks = "1 year")
