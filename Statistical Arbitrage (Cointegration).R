# R program
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
da
