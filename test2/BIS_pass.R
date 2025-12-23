# 1 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
library(readxl)
url <- "https://dsp.twse.com.tw/public/static/downloads/brokerDepartment/肆、測驗合格人員名單_20250103153040.xlsx"
dest <- "Exam_Pass_List.xlsx"
download.file(url, destfile = dest, mode = "wb")
da <- read_excel(dest, col_names = c("券商代號", "券商名稱", "姓名"))
if (file.exists(dest)) unlink(dest)
tmp        <- da[, 1, drop=TRUE]
header_idx <- which(tmp == "券商代號")
year_idx   <- header_idx - 1
year       <- as.integer(str_extract(tmp[year_idx], "\\d+(?=年)"))
idx_start  <- header_idx + 1
idx_end    <- c(year_idx[-1] - 1, nrow(da))

df <- tibble(
  券商代號 = character(),
  券商名稱 = character(),
  姓名 = character()
)
for (i in seq_along(year)) {
  df_tmp <- da %>% slice(idx_start[i]:idx_end[i]) %>% drop_na(姓名) %>% mutate(year = year[i])
  df <- bind_rows(df, df_tmp)
}
df
df %>% filter(str_starts(姓名, ""), str_ends(姓名, ""))

df %>% 
  filter(str_starts(券商名稱, "")) %>%
  filter(str_starts(姓名, ""), str_ends(姓名, ""))
