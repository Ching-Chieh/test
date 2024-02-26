# Invest UMC 1,000,000 from 2009-01-02 to 2023-06-27
# Invest additional 36000 and reinvest dividends at every ex-dividend day
cat("\014")
rm(list=ls())
library(tidyverse)
library(lubridate)
library(quantmod)
date_from <- '2009-01-01'
myticker <- '2303.TW'
umc <- getSymbols(myticker, from = date_from, auto.assign = FALSE)
umc.dividends <- getDividends(myticker, from = date_from, auto.assign = FALSE)
p <- umc %>% 
  as_tibble(rownames = 'date') %>% 
  mutate(date=ymd(date)) %>% 
  rename_with(~tolower(sub(".*\\.", "", .x))) %>% 
  select(date, price = close)
# invest 10^6 at 2009-01-02
dividends <- umc.dividends %>% 
  as_tibble(rownames = 'date') %>% 
  rename(dividends = '2303.TW.div') %>% 
  mutate(date = ymd(date))
# check the price at one ex-dividend day: The 'close' at ex-dividend day already minuses dividend.
p %>% filter(date %in% (ymd('2010-07-08') + -1:0))
dividends %>% filter(date == ymd('2010-07-08'))

df <- p %>% 
  inner_join(dividends, by = 'date')
rm(list = c('dividends'))
p0 <- p$price[1]  # price at 2009-01-02
rm(list = c('p'))
C = 10^6
reinvest = 36000
N0 = C/p0
calculate <- function(previous_N, price, dividends){
  previous_N + (reinvest + dividends*previous_N)/price
}
table_1 <- df %>% 
  mutate(N = accumulate2(price, dividends, calculate, .init = N0)[-1],
         total_value = price*N)
invest_horizon <- as.numeric(slice_tail(table_1, n = 1)$date - ymd('2009-01-02')) / 365
annual_return = (slice_tail(table_1, n = 1)$total_value / C)^(1/invest_horizon) - 1
annual_return
