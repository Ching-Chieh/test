# Calculate the VaR of a porfolio consisting of four market indices
# EWMA
# John C. Hull. Risk Management and Financial Institutions, 5th, p324
cat("\014")
rm(list=ls())
library(readxl)
w1 <- read_excel("w1.xlsx")
djia=w1[[1]]
ftse=w1[[2]]
cac=w1[[3]]
nikkei=w1[[4]]
# variance
aa <- 0.06*c(var(djia),djia^2) %>% 
  stats::filter(0.94,'r', init = var(djia)) %>% 
  as.numeric()
bb <- 0.06*c(var(ftse),ftse^2) %>% 
  stats::filter(0.94,'r', init = var(ftse)) %>% 
  as.numeric()
cc <- 0.06*c(var(cac),cac^2) %>% 
  stats::filter(0.94,'r', init = var(cac)) %>% 
  as.numeric()
dd <- 0.06*c(var(nikkei),nikkei^2) %>% 
  stats::filter(0.94,'r', init = var(nikkei)) %>% 
  as.numeric()
# covariance
ab <- 0.06*c(cov(djia,ftse),djia*ftse) %>% 
  stats::filter(0.94,'r', init = cov(djia,ftse)) %>% 
  as.numeric()
ac <- 0.06*c(cov(djia,cac),djia*cac) %>% 
  stats::filter(0.94,'r', init = cov(djia,cac)) %>% 
  as.numeric()
ad <- 0.06*c(cov(djia,nikkei),djia*nikkei) %>% 
  stats::filter(0.94,'r', init = cov(djia,nikkei)) %>% 
  as.numeric()
bc <- 0.06*c(cov(ftse,cac),ftse*cac) %>% 
  stats::filter(0.94,'r', init = cov(ftse,cac)) %>% 
  as.numeric()
bd <- 0.06*c(cov(ftse,nikkei),ftse*nikkei) %>% 
  stats::filter(0.94,'r', init = cov(ftse,nikkei)) %>% 
  as.numeric() 
cd <- 0.06*c(cov(cac,nikkei),cac*nikkei) %>% 
  stats::filter(0.94,'r', init = cov(cac,nikkei)) %>% 
  as.numeric()
c11=tail(aa,1)
c22=tail(bb,1)
c33=tail(cc,1)
c44=tail(dd,1)

c12=tail(ab,1)
c13=tail(ac,1)
c14=tail(ad,1)
c23=tail(bc,1)
c24=tail(bd,1)
c34=tail(cd,1)
covm=matrix(c(
  c11,c12,c13,c14,
  c12,c22,c23,c24,
  c13,c23,c33,c34,
  c14,c24,c34,c44),4)
alp=1000*c(4,3,1,2)
t(alp)%*%covm%*%alp
