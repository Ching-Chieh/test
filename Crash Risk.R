# connect -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
library(lubridate)
library(RSQLite)
library(dbplyr)
library(RPostgres)
wrds <- dbConnect(
  Postgres(),
  host = "wrds-pgdata.wharton.upenn.edu",
  dbname = "wrds",
  port = 9737,
  sslmode = "require",
  user = "",
  password = ""
)
start_date <- ymd('1983-12-30')
end_date <- ymd("2021-12-31")
# CRSP_daily --------------------------------------------------------------
dsf_db <- tbl(wrds, in_schema("crsp", "dsf"))
dsenames_db <- tbl(wrds, in_schema("crsp", "dsenames"))
crsp_daily <- dsf_db |> 
  filter(date >= start_date & date <= end_date) |>
  filter(!is.na(ret), prc > 0) |> 
  inner_join(
    dsenames_db |>
      filter(shrcd %in% c(10, 11)) |>
      select(permno, ncusip, namedt, nameendt),
    by = c("permno")
  ) |>
  filter(date >= namedt & date <= nameendt) |>
  select(permno, ncusip, date, ret, namedt, nameendt) |>
  collect()

rm(list = c('dsf_db', 'dsenames_db'))
# mkt -----------------------------------------------------------------------
dsi_db <- tbl(wrds, in_schema("crsp", "dsi"))
crsp_daily_mkt <- crsp_daily |> 
  left_join(
    dsi_db |> 
      filter(date >= start_date & date <= end_date) |>
      select(date, mkt = vwretd) |> collect(),
    by = "date")
rm(list = c('dsi_db','crsp_daily'))
# Compustat -----------------------------------------------------------------------
funda_db <- tbl(wrds, in_schema("comp", "funda"))
compustat <- funda_db |>
  filter(
    indfmt == "INDL" &
      datafmt == "STD" &
      consol == "C" &
      popsrc == "D"
  ) |>
  mutate(year = year(datadate)) |>
  group_by(gvkey, year) |>
  filter(datadate == max(datadate)) |>
  ungroup() |> 
  select(
    gvkey, cusip, sich,
    datadate, fyear, prcc_f
  ) |>
  collect() |> 
  mutate(retbegdate = floor_date(datadate %m+% months(-8), 'month'),
         retenddate = ceiling_date(datadate %m+% months(3), 'month') - days(1),
         cusip8 = str_sub(cusip,1,8)
  ) |> 
  select(gvkey, datadate, fyear,
         retbegdate, retenddate,
         cusip8, sich, prcc_f) 
rm(list = c('funda_db'))
# merge -------------------------------------------------------------------
library(data.table)
crsp_daily_mkt_dt <- crsp_daily_mkt |> 
  mutate(date_copy = date) |> 
  as.data.table()
compustat_dt <- compustat |> 
  mutate(datadate_copy = datadate) |> 
  as.data.table()
rm(list = c('crsp_daily_mkt','compustat'))
m1 <- crsp_daily_mkt_dt[compustat_dt,
                        on = .(ncusip == cusip8, date >= retbegdate, 
                               date <= retenddate, namedt <= datadate, nameendt >= datadate), nomatch = NULL] |> 
  as_tibble() |> 
  drop_na(permno, gvkey) |> 
  rename(retbegdate = date, retenddate = date.1, 
         datadate = datadate_copy) |> 
  rename(date = date_copy) |> 
  select(-namedt, -nameendt)
rm(list = c('crsp_daily_mkt_dt','compustat_dt'))
# fdate, wret -------------------------------------------------------------------
m1 <- m1 |> 
  select(permno, gvkey, sich,
         date, datadate, fyear, retbegdate, retenddate,
         ret, mkt, prcc_f)
dt_m1 <- m1 |> as.data.table()
dt_m1[, fdate := 
        as_date(ifelse(lubridate::wday(date, week_start = 1)==5, date,
                       ceiling_date(date, 'week', week_start = 5)))]
m2 <- dt_m1[, .(wret = exp(sum(log(1+ret)))-1,
                wmkt = exp(sum(log(1+mkt)))-1),
            by = .(gvkey, fdate)] |> 
  as_tibble() |> 
  rename(ret = wret, mkt = wmkt)
rm(list = c('dt_m1'))
m3 <- m2 |> 
  left_join(
    m1 |> 
      select(-ret, -mkt), by = c('gvkey', 'fdate' = 'date'))

m3 |> distinct(gvkey, fyear) |> nrow()
m3 <- m3 |>
  filter(!(floor(sich/100) %in% c(49, 60:69)))  # NA will remain.
m3 |> distinct(gvkey, fyear) |> nrow()
m3 <- m3 |> 
  filter(prcc_f >= 1)
m3 |> distinct(gvkey, fyear) |> nrow()
m3 <- m3 |> 
  group_by(gvkey, fyear) |>
  filter(n() >= 26) |> 
  ungroup()
m3 |> distinct(gvkey, fyear) |> nrow()
rm(list = c('m1','m2'))
# mkt_lag, resid -----------------------------------------------------------------------
mkt_lag_1 <- m3 |> mutate(fdate = fdate + days(7)) |> 
  select(gvkey, fdate, mktlag1 = mkt)
mkt_lag_2 <- m3 |> mutate(fdate = fdate + days(14)) |> 
  select(gvkey, fdate, mktlag2 = mkt)
mkt_lead_1 <- m3 |> mutate(fdate = fdate - days(7)) |> 
  select(gvkey, fdate, mktlead1 = mkt)
mkt_lead_2 <- m3 |> mutate(fdate = fdate - days(14)) |> 
  select(gvkey, fdate, mktlead2 = mkt)
m4 <- m3 |> 
  left_join(mkt_lag_1, by = c('gvkey','fdate')) |> 
  left_join(mkt_lag_2, by = c('gvkey','fdate')) |> 
  left_join(mkt_lead_1, by = c('gvkey','fdate')) |> 
  left_join(mkt_lead_2, by = c('gvkey','fdate'))
rm(list = c('mkt_lag_1','mkt_lag_2','mkt_lead_1','mkt_lead_2'))
m5 <- m4 %>%
  arrange(gvkey, fdate) %>%
  drop_na(ret, mktlag1, mktlag2, mkt, mktlead1, mktlead2) %>%
  nest(data = !gvkey) %>%
  mutate(res = map(data, ~resid(lm(ret ~ mktlag1 + mktlag2 + mkt + mktlead1 + mktlead2, .)))) %>%
  unnest(c(data, res))
m6 <- m5 |> 
  select(-c(ret, mktlag1, mktlag2, mkt, mktlead1, mktlead2)) |> 
  mutate(ret = log(1 + res)) |> 
  select(-res) |> 
  drop_na(ret)

m6 |> 
  group_by(gvkey) |> 
  summarise(abnormal = sd(ret), .groups = 'drop') |> 
  pull(abnormal) |> 
  mean(na.rm = T)

library(e1071)
m5 |>
  select(-c(ret, mktlag1, mktlag2, mkt, mktlead1, mktlead2)) |>
  pull(res) |>
  skewness(na.rm = T)
m6 |>
  pull(ret) |>
  skewness(na.rm = T)
# crash, SIGMA, RET -------------------------------------------------------------------
c1 <- m6 |> 
  group_by(gvkey, fyear) |> 
  mutate( cweek = as.numeric(ret < (mean(ret)-3.09*sd(ret))),
          CRASH = as.numeric(sum(cweek)>=1),
          NCSKEW = -(n()*(n()-1)^1.5*sum(ret^3))/
            ((n()-1)*(n()-2)*sum(ret^2)^1.5),
          dw = as.numeric(ret<mean(ret)),
          DUVOL = log((n()-sum(dw)-1)*sum((ret*dw)^2)/
                        na_if((sum(dw)-1)*sum((ret*(1-dw))^2),0)),
          SIGMA = sd(ret),
          past_ret = 100*mean(ret),
          jweek = as.numeric(ret > (mean(ret)+3.09*sd(ret))),
          COUNT = sum(cweek) - sum(jweek),
          sumcweek = sum(cweek),
          sumjweek = sum(jweek)
  ) |>
  ungroup() |> 
  distinct(gvkey, fyear, CRASH, NCSKEW, DUVOL, COUNT, .keep_all = T) |>    # become firm-year obs.
  select(-fdate, -cweek, -jweek, -dw, -ret) |> 
  rename(RET = past_ret)         # RET is control var past_ret.
