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
