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
