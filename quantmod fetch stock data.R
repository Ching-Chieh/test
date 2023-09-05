cat("\014")
rm(list=ls())
library(tidyverse)
library(lubridate)
library(quantmod)
quantmod::getSymbols('TSLA',from = '2023-08-01')
chartSeries(TSLA, theme ="white")
da=TSLA
da %>% 
  as_tibble(rownames = 'date') %>% 
  mutate(date=ymd(date)) %>% 
  rename_with(~tolower(gsub(".", "_", .x, fixed = TRUE)))
da %>% 
  as_tibble(rownames = 'date') %>% 
  mutate(date=ymd(date)) %>% 
  rename_with(~tolower(sub(".*\\.", "", .x)))
