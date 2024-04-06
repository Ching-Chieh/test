cat("\014")
rm(list=ls())
library(quantmod)
da = quantmod::getSymbols('^SP100',
                          from = '1986-01-02', to = '1989-12-15', auto.assign = FALSE)
r = diff(log(as.numeric(da$SP100.Close)))
da = data.frame(r)
write.csv(da, 'rtn.csv', row.names = FALSE)
