# R program
# For small T and large quantity of assets
cat("\014")
rm(list=ls())
library(tidyverse)
library(lubridate)
da <- read.table('m-apca0103.txt')
colnames(da)=c('id','date','ret')
ret_df <- da %>% 
  as_tibble() %>% 
  mutate(date = ymd(date)) %>% 
  pivot_wider(names_from = 'id', values_from = 'ret') %>% 
  select(-1)
write_csv(ret_df,"ret_df.csv")
# Use RATS to determine number of factors *****************************
end(reset)
OPEN DATA "C:\Users\Jimmy\Desktop\ret_df.csv"
DATA(FORMAT=PRN,NOLABELS,ORG=COLUMNS,TOP=2) 1 36 r01 r02 r03 r04 r05 r06 r07 r08 r09 r10 r11 r12 r13 r14 $
 r15 r16 r17 r18 r19 r20 r21 r22 r23 r24 r25 r26 r27 r28 r29 r30 r31 r32 r33 r34 r35 r36 r37 r38 r39 $
 r40
dec rect rmat(36,40)
do i=1,36
   do j=1,40
      compute rmat(i,j) = ([series]j)(i)
   end do j
end do i
@BaiNg(max=10,center) rmat
* 4 different criteria
* Output: ICP1 criteria picks 6.
# Back to R *********************************************************************
ret_df <- ret_df %>% 
  mutate(across(everything(),~.-mean(.)))
retm = ret_df %>% as.matrix() %>% unname   # 36*40
omega = tcrossprod(retm)                   # 36*36
x=eigen(omega)$vectors[,1:6]               # number of factors: 6
x_df = x %>% as_tibble()
sig = rep(0,40)
for (i in 1:40) {
  da1= x_df %>% mutate(y=ret_df[[i]])
  sig[i]=stats::sigma(lm(y~.,da1))
}
retm <- retm%*%diag(1/sig)
ret_df <- retm %>% as_tibble()
omega = tcrossprod(retm)                   # 36*36
x = eigen(omega)$vectors[,1:6]
x_df = x %>% as_tibble()
coe=rep(0,40)
rsq=rep(0,40)
for (i in 1:40) {
  da1 = x_df %>% mutate(y=ret_df[[i]]*sig[i])
  m1=lm(y~.,da1)
  rsq[i]=summary(m1)$r.squared
  coe[i]=coef(m1)[[2]]
}
data.frame(coe,rsq)
