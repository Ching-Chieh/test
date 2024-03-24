cat("\014")
rm(list=ls())
library(tidyverse)
read_excel("g.xlsx") %>% 
  rename_with(tolower) %>% 
  mutate(across(everything(),~100*log(.x/dplyr::lag(.x)))) %>% 
  slice(-1) %>% 
  write_csv('g1.csv')
