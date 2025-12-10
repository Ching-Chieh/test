# data -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
library(readxl)
library(slider)
graphics.off()
tickers <- read_excel("2025Q3_0050_constituents.xlsx")$ticker[1:30] %>% sort
tickers <- tickers %>% paste0(".TW")
# library(tidyquant)
# df <- tq_get(tickers, from = '2016-01-01', to = "2025-12-01")
# library(writexl)
# write_xlsx(df, "prices.xlsx")
df <- read_excel("prices.xlsx") %>% 
  mutate(
    date = ymd(date),
    symbol = str_replace(symbol, fixed(".TW"), "")
    ) %>% 
  select(symbol, date, adjusted)
# check
df_wide <- df %>%
  pivot_wider(names_from  = symbol, values_from = adjusted) %>% 
  arrange(date)
# sapply(df_wide, \(x) sum(is.na(x)))
# df_wide %>% filter(if_any(everything(), is.na))
# df_wide %>% 
#   select(date, `6669`) %>% 
#   filter(is.na(`6669`)) %>% 
#   tail # 2017-11-10
#
return_df <- df_wide %>% 
  fill(everything()) %>% 
  filter(date >= ymd("2017-11-30")) %>% 
  mutate(across(-date, ~.x / lag(.x) - 1)) %>% 
  drop_na
# return_df:  2017-12-01 ~ 2025-11-28 完整96個月
month_return_df <- return_df %>% 
  mutate(year = year(date), month = month(date)) %>% 
  summarise(across(-date, ~prod(1 + .x) - 1), .by = c(year, month))
N <- 3
f <- function(x) prod(x + 1) - 1
past_Nm_return_df <- month_return_df %>% 
  mutate(across(-c(year, month),
                ~slide_dbl(.x, f, .before = N, .after = -1, .complete = TRUE),
                .names = "{.col}_pastNm")) %>% 
  drop_na
# for loop中一個月份 ---------------------------------------------------------------------
# 用2017-12, 2018-1, 2018-2資料在2018 2月底形成的portfolio在2018 3月底的該月return
tmp <- past_Nm_return_df %>% 
  slice(1) %>% 
  select(ends_with("_pastNm")) %>% 
  pivot_longer(everything()) %>% 
  mutate(g = ntile(value, 5))
long_stocks  <- tmp %>% filter(g == 5) %>% pull(name) %>% str_replace("_pastNm", "")
short_stocks <- tmp %>% filter(g == 1) %>% pull(name) %>% str_replace("_pastNm", "")

a <- past_Nm_return_df %>% slice(1) %>% select(!!long_stocks) %>% unlist %>% mean
b <- past_Nm_return_df %>% slice(1) %>% select(!!short_stocks) %>% unlist %>% mean
a - b
past_Nm_return_df %>% slice(1) %>% select(-year, -month, -ends_with("_pastNm")) %>% unlist %>% mean # Buy-and-Hold
# for loop ----------------------------------------------------------------
momentum_ret <- numeric(0)
buy_and_hold_ret <- numeric(0)
for (i in 1:nrow(past_Nm_return_df)) {
  tmp <- past_Nm_return_df %>% 
    slice(i) %>% 
    select(ends_with("_pastNm")) %>% 
    pivot_longer(everything()) %>% 
    mutate(g = ntile(value, 5))
  long_stocks  <- tmp %>% filter(g == 5) %>% pull(name) %>% str_replace("_pastNm", "")
  short_stocks <- tmp %>% filter(g == 1) %>% pull(name) %>% str_replace("_pastNm", "")
  
  x <- past_Nm_return_df %>% slice(i) %>% select(!!long_stocks) %>% unlist %>% mean
  y <- past_Nm_return_df %>% slice(i) %>% select(!!short_stocks) %>% unlist %>% mean
  momentum_ret <- c(momentum_ret, x - y)
  
  z <- past_Nm_return_df %>% slice(i) %>% select(-year, -month, -ends_with("_pastNm")) %>% unlist %>% mean # Buy-and-Hold
  buy_and_hold_ret <- c(buy_and_hold_ret, z)
}
result <- tibble(
  year = past_Nm_return_df$year,
  month = past_Nm_return_df$month,
  momentum = momentum_ret,
  buy_and_hold = buy_and_hold_ret
  ) %>% 
  mutate(date = make_date(year, month, 1) %m+% months(1) - days(1), .before = 1) %>% 
  mutate(
    momentum = momentum*100,
    buy_and_hold = buy_and_hold*100
  ) %>% 
  select(date, momentum, buy_and_hold)
ggplot(result, aes(x = date)) +
  geom_line(aes(y = momentum, color = "momentum")) +
  geom_line(aes(y = buy_and_hold, color = "buy_and_hold")) +
  labs(y = "return", color = "strategy") +
  theme_minimal()
# result %>% print(n = Inf)
num1 <- sum(result$momentum >  result$buy_and_hold)
num2 <- nrow(result)
round(num1 / num2 * 100)
# f1 ----------------------------------------------------------------
f1 <- function(N) {
  f <- function(x) prod(x + 1) - 1
  past_Nm_return_df <- month_return_df %>% 
    mutate(across(-c(year, month),
                  ~slide_dbl(.x, f, .before = N, .after = -1, .complete = TRUE),
                  .names = "{.col}_pastNm")) %>% 
    drop_na
  
  tmp <- past_Nm_return_df %>% 
    slice(1) %>% 
    select(ends_with("_pastNm")) %>% 
    pivot_longer(everything()) %>% 
    mutate(g = ntile(value, 5))
  long_stocks  <- tmp %>% filter(g == 5) %>% pull(name) %>% str_replace("_pastNm", "")
  short_stocks <- tmp %>% filter(g == 1) %>% pull(name) %>% str_replace("_pastNm", "")
  
  a <- past_Nm_return_df %>% slice(1) %>% select(!!long_stocks) %>% unlist %>% mean
  b <- past_Nm_return_df %>% slice(1) %>% select(!!short_stocks) %>% unlist %>% mean
  a - b
  past_Nm_return_df %>% slice(1) %>% select(-year, -month, -ends_with("_pastNm")) %>% unlist %>% mean # Buy-and-Hold

  
  momentum_ret <- numeric(0)
  buy_and_hold_ret <- numeric(0)
  for (i in 1:nrow(past_Nm_return_df)) {
    tmp <- past_Nm_return_df %>% 
      slice(i) %>% 
      select(ends_with("_pastNm")) %>% 
      pivot_longer(everything()) %>% 
      mutate(g = ntile(value, 5))
    long_stocks  <- tmp %>% filter(g == 5) %>% pull(name) %>% str_replace("_pastNm", "")
    short_stocks <- tmp %>% filter(g == 1) %>% pull(name) %>% str_replace("_pastNm", "")
    
    x <- past_Nm_return_df %>% slice(i) %>% select(!!long_stocks) %>% unlist %>% mean
    y <- past_Nm_return_df %>% slice(i) %>% select(!!short_stocks) %>% unlist %>% mean
    momentum_ret <- c(momentum_ret, x - y)
    
    z <- past_Nm_return_df %>% slice(i) %>% select(-year, -month, -ends_with("_pastNm")) %>% unlist %>% mean # Buy-and-Hold
    buy_and_hold_ret <- c(buy_and_hold_ret, z)
  }
  result <- tibble(
    year = past_Nm_return_df$year,
    month = past_Nm_return_df$month,
    momentum = momentum_ret,
    buy_and_hold = buy_and_hold_ret
  ) %>% 
    mutate(date = make_date(year, month, 1) %m+% months(1) - days(1), .before = 1) %>% 
    mutate(
      momentum = momentum*100,
      buy_and_hold = buy_and_hold*100
    ) %>% 
    select(date, momentum, buy_and_hold)
  num1 <- sum(result$momentum >  result$buy_and_hold)
  num2 <- nrow(result)
  num3 <- round(num1 / num2 * 100)
  cat("N:", N, ", ", num1, "/", num2, "= ", num3, "%\n", sep = "")
}
cat("Momentum 贏 buy-and-hold 月份比例", "\n")
f1(2)
f1(3) # e.g. 用1, 2, 3月資料在3月底形成的portfolio，在4月底的該月return
f1(4)
f1(5)
f1(6)
# f2 ----------------------------------------------------------------
# aa <- tibble(x = 1:6)
# aa %>% mutate(y = slide_dbl(x, sum, .before = 3+1, .after = -2, .complete = TRUE))
f2 <- function(N) {
  f <- function(x) prod(x + 1) - 1
  past_Nm_return_df <- month_return_df %>% 
    mutate(across(-c(year, month),
                  ~slide_dbl(.x, f, .before = N+1, .after = -2, .complete = TRUE),
                  .names = "{.col}_pastNm"
    )
    ) %>% 
    drop_na
  
  tmp <- past_Nm_return_df %>% 
    slice(1) %>% 
    select(ends_with("_pastNm")) %>% 
    pivot_longer(everything()) %>% 
    mutate(g = ntile(value, 5))
  long_stocks  <- tmp %>% filter(g == 5) %>% pull(name) %>% str_replace("_pastNm", "")
  short_stocks <- tmp %>% filter(g == 1) %>% pull(name) %>% str_replace("_pastNm", "")
  
  a <- past_Nm_return_df %>% slice(1) %>% select(!!long_stocks) %>% unlist %>% mean
  b <- past_Nm_return_df %>% slice(1) %>% select(!!short_stocks) %>% unlist %>% mean
  a - b
  past_Nm_return_df %>% slice(1) %>% select(-year, -month, -ends_with("_pastNm")) %>% unlist %>% mean # Buy-and-Hold
  
  
  momentum_ret <- numeric(0)
  buy_and_hold_ret <- numeric(0)
  for (i in 1:nrow(past_Nm_return_df)) {
    tmp <- past_Nm_return_df %>% 
      slice(i) %>% 
      select(ends_with("_pastNm")) %>% 
      pivot_longer(everything()) %>% 
      mutate(g = ntile(value, 5))
    long_stocks  <- tmp %>% filter(g == 5) %>% pull(name) %>% str_replace("_pastNm", "")
    short_stocks <- tmp %>% filter(g == 1) %>% pull(name) %>% str_replace("_pastNm", "")
    
    x <- past_Nm_return_df %>% slice(i) %>% select(!!long_stocks) %>% unlist %>% mean
    y <- past_Nm_return_df %>% slice(i) %>% select(!!short_stocks) %>% unlist %>% mean
    momentum_ret <- c(momentum_ret, x - y)
    
    z <- past_Nm_return_df %>% slice(i) %>% select(-year, -month, -ends_with("_pastNm")) %>% unlist %>% mean # Buy-and-Hold
    buy_and_hold_ret <- c(buy_and_hold_ret, z)
  }
  result <- tibble(
    year = past_Nm_return_df$year,
    month = past_Nm_return_df$month,
    momentum = momentum_ret,
    buy_and_hold = buy_and_hold_ret
  ) %>% 
    mutate(date = make_date(year, month, 1) %m+% months(1) - days(1), .before = 1) %>% 
    mutate(
      momentum = momentum*100,
      buy_and_hold = buy_and_hold*100
    ) %>% 
    select(date, momentum, buy_and_hold)
  num1 <- sum(result$momentum >  result$buy_and_hold)
  num2 <- nrow(result)
  num3 <- round(num1 / num2 * 100)
  cat("N:", N, ", ", num1, "/", num2, "= ", num3, "%\n", sep = "")
}
cat("Momentum 贏 buy-and-hold 月份比例", "\n")
f2(2)
f2(3) # e.g. # 用1, 2, 3月資料形成portfolio，在5月底的該月return
f2(4)
f2(5)
f2(6)


