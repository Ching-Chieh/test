# functions ----------------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
library(readxl)
library(slider)

calc_rsi <- function(price, window){
  price_change <- price - lag(price)
  x <- slide_dbl(
    price_change, 
    ~ sum(.x[.x > 0]), 
    .before = window - 1, 
    .complete = TRUE
  )
  y <- -slide_dbl(
    price_change, 
    ~ sum(.x[.x < 0]), 
    .before = window - 1, 
    .complete = TRUE
  )
  rsi <- if_else(x + y == 0, 0, x/(x+y)*100)
  return(rsi)
}

time_to_freq <- function(time, frequency){
  min845 <- 8*60 + 45
  min850 <- 8*60 + 50
  h <- time %/% 100
  m <- time %% 100
  total_min <- h * 60 + m
  t2 <- ((total_min - min850) %/% frequency + 1) * frequency + min845
  t2 <- t2 %/% 60 * 100 + t2 %% 60
  return(t2)
}

plus5 <- function(time) {
  h <- time %/% 100
  m <- time %% 100
  m <- m + 5
  if (m == 60) {
    m <- m - 60
    h <- h + 1
  }
  return(h*100 + m)
}

# 5min_data_FITX_1.TF.log -------------------------------------------------
freq <- 30
rsi_window = 6

da5 <- read_table("策略/python/5min_data_FITX_1.TF.log", show_col_types = FALSE) %>% 
  select(-last_col()) %>% 
  rename_with(~paste0(.x, "5"), .cols = -date) %>% 
  mutate(time5 = sapply(time5, plus5))

da30 <- da5 %>% 
  mutate(time30 = time_to_freq(time5, frequency = 30)) %>% 
  summarise(
    open30 = first(open5),
    high30 = max(high5),
    low30 = min(low5),
    close30 = last(close5),
    volume30 = sum(volume5),
    .by = c("date", "time30")) %>% 
  mutate(rsi30 = calc_rsi(close30, rsi_window))

da5 <- da5 %>% mutate(rsi5 = calc_rsi(close5, rsi_window))

result <- da5 %>% 
  left_join(da30, by = c("date", "time5" = "time30")) %>% 
  fill(open30, high30, low30, close30, volume30, rsi30)
result %>% head(100) %>% print(n = Inf)

