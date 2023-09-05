cat("\014")
rm(list=ls())
library(tidyverse)
library(lubridate)
library(quantmod)
quantmod::getSymbols('TSLA',from = '2023-08-01')
TSLA %>% 
  as_tibble(rownames = 'date') %>% 
  mutate(date=ymd(date)) %>% 
  rename_with(~tolower(sub(".*\\.", "", .x)))
