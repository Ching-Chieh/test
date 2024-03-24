# Fama-Macbeth regressions
# Coqueret and Guida, Machine Learning for Factor Investing, p.22
# data, FF_factors -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
library(lubridate)
load("data_ml.RData")
data_ml <- data_ml %>% 
  filter(date >= ymd("2000-01-01"), date <= ymd("2018-12-31")) %>%
  mutate(month = floor_date(date, 'month')) %>% 
  arrange(stock_id, month) %>%
  select(-date) %>% 
  select(stock_id, month, everything())
library(frenchdata)
factors_ff5_monthly_raw <- download_french_data("Fama/French 5 Factors (2x3)")
FF_factors <- factors_ff5_monthly_raw$subsets$data[[1]] %>% 
  mutate(
    month = ymd(str_c(date, "01")),
    across(c(RF, `Mkt-RF`, SMB, HML, RMW, CMA), ~as.numeric(.) / 100),
    .keep = "none"
  ) %>% 
  filter(month >= ymd("1963-07-31") & month <= ymd("2020-03-28")) %>% 
  select(month, MKT_RF = `Mkt-RF`, SMB, HML, RMW, CMA, RF)
# stocks_with_full_data, returns -----------------------------------------------------------------------
stocks_with_full_data <- data_ml %>% 
  group_by(stock_id) %>% 
  mutate(nbs = n()) %>% 
  ungroup() %>% 
  filter(nbs == max(nbs)) %>% 
  select(month, stock_id, R1M_Usd) %>% 
  arrange(stock_id, month)
returns <- stocks_with_full_data %>% 
  pivot_wider(names_from = "stock_id", values_from = "R1M_Usd")
# betas -----------------------------------------------------------------------
nb_factors <- 5
df <- stocks_with_full_data %>% 
  left_join(FF_factors, by = "month")
df_lag <- df %>% 
  mutate(month = month %m+% months(1)) %>% 
  select(stock_id, month, R1M_Usd_lag = R1M_Usd)
data_FM <- df %>% 
  left_join(df_lag, by = c("stock_id", "month")) %>% 
  select(month, stock_id, R1M_Usd = R1M_Usd_lag,
         MKT_RF, SMB, HML, RMW, CMA) %>% 
  drop_na()
rm(list = c('df','df_lag'))
betas <- data_FM %>% 
  nest(data = -stock_id) %>% 
  mutate(coef = map(data, \(data) broom::tidy(lm(R1M_Usd~.,data)))) %>% 
  unnest(coef) %>% 
  select(stock_id, term, estimate) %>% 
  pivot_wider(id_cols = stock_id,
              names_from = term,
              values_from = estimate) %>% 
  select(stock_id, MKT_RF, SMB, HML, RMW, CMA) %>% 
  arrange(stock_id)
# FM-gamma -----------------------------------------------------------------------
gam <- stocks_with_full_data %>% 
  inner_join(betas, by = 'stock_id') %>% 
  nest(data = -month) %>% 
  mutate(est = map(data, ~broom::tidy(lm(R1M_Usd ~ MKT_RF + SMB + HML + RMW + CMA, .x)))) %>% 
  unnest(est) %>% 
  select(month, term, estimate) %>% 
  pivot_wider(id_cols = month, names_from = term, values_from = estimate) %>% 
  select(-`(Intercept)`)
gam %>%
  select(month, MKT_RF, SMB, HML, RMW, CMA) %>%
  pivot_longer(-month, names_to = 'factor', values_to = "factor premium") %>%
  mutate(across(factor,
                ~factor(.x,
                  levels = c("MKT_RF","SMB","HML","RMW","CMA")))) %>% 
  ggplot(aes(x = month, y = `factor premium`, color = factor)) +
  geom_line() + 
  facet_wrap(~factor, ncol = 1, strip.position = 'right', scales = "free") +
  theme(legend.position = "none") +
  labs(x = 'date')
# redundant factors -----------------------------------------------------------------------
factors <- c("MKT_RF", "SMB", "HML", "RMW", "CMA")
formulas <- paste(factors, '~ MKT_RF + SMB + HML + RMW + CMA -', factors)
map_dfr(formulas, function(f) {
  broom::tidy(lm(as.formula(f), FF_factors)) %>% 
    filter(term == "(Intercept)") %>% 
    select(intercept = estimate, p.value)
}) %>% 
  mutate(factors) %>% 
  mutate(across(-factors, ~num(.x, digits = 4))) %>% 
  select(factors, everything())
# Table 3.5
table3.5 <- map_dfr(formulas, function(f) {
  broom::tidy(lm(as.formula(f), FF_factors)) %>% 
  select(term, estimate) %>% 
  pivot_wider(names_from = 'term', values_from = 'estimate') %>% 
  rename(Intercept = '(Intercept)')
}) %>% 
  mutate(`Dep. Variable` = factors) %>% 
  select(`Dep. Variable`, Intercept, MKT_RF, everything())
p.value.table <- map_dfr(formulas, function(f) {
  broom::tidy(lm(as.formula(f), FF_factors)) %>% 
    select(term, p.value) %>% 
    pivot_wider(names_from = 'term', values_from = 'p.value') %>% 
    rename(Intercept = '(Intercept)')
}) %>% 
  mutate(`Dep. Variable` = factors) %>% 
  select(`Dep. Variable`, Intercept, MKT_RF, everything())
signi.star <- function(p.value){
  if (is.na(p.value))       star = "(   )"
  else if (p.value <= 0.01) star = "(***)"
  else if (p.value <= 0.05) star = "( **)"
  else if (p.value <= 0.1)  star = "(  *)"
  else star = "(   )"
  star
}
table3.5.m <- as.matrix(table3.5[,-1]) %>% round(3)
p.value.table.m <- as.matrix(p.value.table[,-1])
for (i in 1:5) {
  for (j in 1:6) {
    table3.5.m[i,j] = 
             paste(table3.5.m[i,j], signi.star(p.value.table.m[i,j]))
  }
}
row.names(table3.5.m) <- factors
print.data.frame(as.data.frame(table3.5.m), quote = FALSE)
rm(list = c('factors','formulas'))
