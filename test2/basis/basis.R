# 1 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
library(readxl)
library(conflicted)
graphics.off()
FITX1 <- read_excel("TSE_FITX.xlsx", sheet = "FITX1") %>% 
  mutate(date = ymd(date)) %>% 
  select(date, FITX1 = close)
TSE <- read_excel("TSE_FITX.xlsx", sheet = "TSE") %>% 
  mutate(date = ymd(date)) %>% 
  select(date, TSE = close)
da <- inner_join(FITX1, TSE, by = "date") %>% 
  mutate(diff = FITX1 - TSE) %>% 
  arrange(date)
all_dates <- seq(ymd(da$date[1]), ymd(tail(da$date, 1)), "day")
third_wed_theoretical <- all_dates[((day(all_dates) - 1) %/% 7 + 1) == 3 & wday(all_dates, week_start = 1) == 3]
settlement_dates <- map_vec(third_wed_theoretical, function(d) {
  da %>% 
    dplyr::filter(date >= d) %>% 
    slice_min(date) %>% 
    pull(date)
})
diff(settlement_dates)
min(diff(settlement_dates))
wday(settlement_dates, week_start = 1)

da <- da %>% mutate(is_settlement_date = if_else(date %in% settlement_dates, 1, 0))

diff=da$diff
n=length(diff)
length(diff[diff<0])/n

da <- da %>% slice_tail(n = 1000)
da %>% 
  ggplot(aes(x = date, y = diff)) +
  geom_line(color = "steelblue") +
  geom_vline(
    data = da %>% dplyr::filter(is_settlement_date == 1),
    aes(xintercept = date),
    color = "red",
    linetype = "dashed"
  ) +
  theme_minimal() +
  scale_x_date(
    date_breaks = "1 month",
    date_labels = "%Y-%m"
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
