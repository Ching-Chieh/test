# Time-varying correlations between AAPL and TSLA
cat("\014")
rm(list=ls())
library(tidyverse)
library(lubridate)
quantmod::getSymbols(c('AAPL','TSLA'), from = '2018-01-01')
aapl <- AAPL %>%
  as_tibble(rownames = 'date') %>% 
  mutate(date=ymd(date)) %>% 
  select(date, aapl.close = AAPL.Close)
tsla <- TSLA %>% 
  as_tibble(rownames = 'date') %>% 
  mutate(date=ymd(date)) %>% 
  select(date, tsla.close = TSLA.Close)
da <- aapl %>% 
  left_join(tsla, by = 'date') %>% 
  drop_na()
aapl <- log(1 + (da$aapl.close/dplyr::lag(da$aapl.close)-1)[-1])
tsla <- log(1 + (da$tsla.close/dplyr::lag(da$tsla.close)-1)[-1])
library(fGarch)
m1 <- garchFit(~1+garch(1,1),data=aapl,trace=F)
m2 <- garchFit(~1+garch(1,1),data=tsla,trace=F)
vaapl <- fGarch::volatility(m1)
vtsla <- fGarch::volatility(m2)
xp <- aapl+tsla
xm <- aapl-tsla 
m3 <- garchFit(~1+garch(1,1),data=xp,trace=F)
m4 <- garchFit(~1+garch(1,1),data=xm,trace=F)
vxp <- fGarch::volatility(m3)
vxm <- fGarch::volatility(m4)
cov12 <- (vxp^2-vxm^2)/4
cor12 <- cov12/(vaapl*vtsla)
df <- tibble(date = da$date[-1],cor12 = cor12)
df
ggplot(df, aes(date,cor12)) + 
  geom_hline(yintercept = cor(aapl,tsla)) + 
  geom_line(color='red') + 
  scale_x_date(date_breaks = "1 year",date_labels = "%Y") + 
  labs(y = "correlation",
       title = 'Time-varying correlations between AAPL and TSLA')
