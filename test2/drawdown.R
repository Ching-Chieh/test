# 1 -----------------------------------------------------------------------
# Python for Algorithmic Trading p343
cat("\014")
rm(list=ls())
library(tidyverse)
graphics.off()
raw <- read_csv("http://hilpisch.com/pyalgo_eikon_eod_data.csv", show_col_types = FALSE)
spxvix <- raw %>%
  select(date = Date, SPX = `.SPX`, VIX = `.VIX`) %>% 
  arrange(date) %>% 
  drop_na

spxvix %>%
  pivot_longer(c(SPX, VIX), values_to = "price") %>%
  ggplot(aes(date, price)) +
  geom_line() +
  facet_wrap(~name, scales = "free_y", ncol = 1) +
  scale_x_date(
    date_breaks = "1 year",
    date_labels = "%Y"
  ) +
  theme_minimal()

rets <- spxvix %>%
  mutate(
    SPX = log(SPX / lag(SPX)),
    VIX = log(VIX / lag(VIX))
  ) %>%
  drop_na

ggplot(rets, aes(SPX, VIX)) +
  geom_point(alpha = 0.4) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  theme_minimal()

spxvix %>%
  mutate(run_max = cummax(SPX)) %>%
  ggplot(aes(date)) +
  geom_line(aes(y = SPX, color = "S&P 500")) +
  geom_line(aes(y = run_max, color = "Running Max")) +
  scale_color_manual(values = c("blue", "red")) +
  scale_x_date(
    date_breaks = "1 year",
    date_labels = "%Y"
  ) +
  theme_minimal()

rdrawdown <- spxvix %>%
  mutate(
    run_max = cummax(SPX),
    rdrawdown = (run_max - SPX) / run_max
  )

max(rdrawdown$rdrawdown)

adrawdown <- spxvix %>%
  mutate(
    run_max = cummax(SPX),
    adrawdown = run_max - SPX
  )
max(adrawdown$adrawdown)

peaks <- adrawdown %>%
  filter(adrawdown == 0) %>%
  pull(date)

as.numeric(max(diff(peaks)))
