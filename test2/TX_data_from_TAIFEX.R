# 把csv處理成各個freq -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
library(vroom)
file <- "Daily_2025_11_21.csv"
d_ = str_sub(file, 7, 16) %>% str_replace_all("_", "") %>% as.integer
m_ = "202512"
da <- vroom(file,
            col_select = 1:6,
            skip = 1,
            col_names = c("date", "code", "month", "time", "price", "volume"),
            show_col_types = FALSE,
            col_types = "iccidi"
)

da <- da %>% 
  filter(
    date == d_, # integer
    code == "TX",
    month == m_, # character
    time >= 84500, time <= 134500
  ) %>% 
  mutate(
    volume = volume / 2,
    h = time %/% 10000,
    m = (time %% 10000) %/% 100,
    total_min = h * 60 + m
  )
tmp <- 8*60+45

f1 <- function(df, freq) {
  df <- df %>% 
    mutate(
      t = (total_min - tmp) %/% freq * freq + tmp,
      t = t %/% 60 * 100 + t %% 60
    ) %>% 
    summarise(
      open = price[1],
      high = max(price),
      low = min(price),
      close = tail(price, 1),
      volume = sum(volume),
      .by = t) %>% 
    rename(time = t)
  return(df)
}
freq <- c(1, 3, 5, 10, 15, 20, 30, 60)
result <- map(freq, ~f1(da, .x))
names(result) <- freq
result

# download, unzip -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
library(readxl)
library(rvest)

html <- read_html("https://www.taifex.com.tw/cht/3/futPrevious30DaysSalesData")
date_str <- html %>% 
  html_element("table.table_f.table-fixed") %>% 
  html_table(convert = FALSE) %>% 
  select(date = 日期) %>% 
  pull %>% 
  ymd %>% 
  sort %>% 
  as.character %>% 
  str_replace_all("-", "")

path <- "C:/Users/Jimmy/Desktop/download_data"
# https://www.taifex.com.tw/file/taifex/Dailydownload/DailydownloadCSV/Daily_2025_09_29.zip
download_file <- function(date_str_vec, path) {
  file_name <- paste0("Daily_", str_sub(date_str_vec, 1, 4), "_", str_sub(date_str_vec, 5, 6), "_", str_sub(date_str_vec, 7, 8))
  file_name_ext <- paste0(file_name, ".zip")
  url <- "https://www.taifex.com.tw/file/taifex/Dailydownload/DailydownloadCSV/"
  url <- paste0(url, file_name_ext)
  
  zip_path <- file.path(path, file_name_ext)
  download.file(url, destfile = zip_path, mode = "wb")
}
unzip_file <- function(folder_path) {
  zip_files <- list.files(path = folder_path, pattern = "\\.zip$", full.names = TRUE)
  for (zip_file in zip_files) {
    unzip(zip_file, exdir = folder_path)
  }
}

download_file(date_str, path)
unzip_file(path)
# readcsv -----------------------------------------------------------------
# files' date: 2025-09-26 ~ 2025-11-12
cat("\014")
rm(list=ls())
library(tidyverse)
# library(vroom)
path <- "C:/Users/Jimmy/Desktop/download_data"

file_names <- list.files(path = path, pattern = "\\.csv$", full.names = TRUE)
# file_names <- file_names[1:5]
date_ymd <- str_sub(file_names, -14, -5) %>% str_replace_all("_", "-") %>% ymd
# 找第三個星期三
d <- seq(ymd("20251001"), ymd("20251031"), by = "day")
w <- wday(d, week_start = 1)
dd <- d[which(w == 3)[3]]
m <- tibble(files = file_names, date = date_ymd) %>% 
  mutate(mo = if_else(date <= dd, "202510", "202511"))
rm(list = c("d", "w", "dd"))
# m %>% print(n = Inf)
header <- c("date", "code", "month", "time", "price", "volume")
tmp <- 8*60+45
freq <- 5
f1 <- function(file) {
  cat(file, "\n")
  m <- m %>% filter(files == file)
  mo <- m %>% pull(mo)
  dat <- m %>% pull(date) %>% as.character %>% str_replace_all("-", "") %>% as.integer
  df <- read_csv(file,  # vroom() parsing issue
                 col_select = 1:6,
                 skip = 1,
                 col_names = header,
                 show_col_types = FALSE,
                 col_types = "iccidi"
  ) %>%
    filter(
      date == dat, code == "TX", month == mo,
      time >= 84500, time <= 134500
    ) %>% 
    mutate(
      volume = volume / 2,
      h = time %/% 10000,
      m = (time %% 10000) %/% 100,
      total_min = h * 60 + m,
      t = (total_min - tmp) %/% freq * freq + tmp,
      t = t %/% 60 * 100 + t %% 60
    ) %>% 
    summarise(
      open = price[1],
      high = max(price),
      low = min(price),
      close = tail(price, 1),
      volume = sum(volume),
      .by = t) %>% 
    rename(time = t) %>% 
    mutate(date = ymd(dat), .before = 1)
  return(df)
}
stop_on_warning <- function(expr) {
  withCallingHandlers(expr, warning = function(w) stop(w))
}

stop_on_warning({
  df <- map(file_names, f1) %>% list_rbind
})
# df <- map(file_names, f1) %>% list_rbind
df %>% tail(100) %>% print(n = Inf)



