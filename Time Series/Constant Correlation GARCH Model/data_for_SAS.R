cat("\014")
rm(list=ls())
da=read.table('d-spcscointc.txt', header = TRUE)
write.csv(da, 'da.csv', row.names = FALSE)
