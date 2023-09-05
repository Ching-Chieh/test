# Time-Varying Beta of TSLA
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
