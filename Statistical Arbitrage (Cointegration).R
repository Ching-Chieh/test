# R program -------------------------------------------------------------------------------
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
# RATS program -----------------------------------------------------------------------------------
end(reset)
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
* There are many arbitrage opportunities.
* The mean of spread is 0.41340.
* Buy a share of MSFT and short 1.02545 shares of AAPL when spread equals 0.25296 (0.41340 - 0.16043).
* Unwind the position when spread equals 0.57383 (0.41340 + 0.16043).
