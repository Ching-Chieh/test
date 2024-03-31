# John C. Hull. Options, Futures, and Other Derivatives, Global Edition. 9th p.670
# The Least-Squares Approach
# 1 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
S3 = c(1.34, 1.54, 1.03, 0.92, 1.52, 0.9, 1.01, 1.34)
S2 = c(1.08, 1.26, 1.07, 0.97, 1.56, 0.77, 0.84, 1.22)
S1 = c(1.09, 1.16, 1.22, 0.93, 1.11, 0.76, 0.92, 0.88)
S0 = 1
K = 1.1
r = 0.06
x3 = sapply(S3, function(x) max(K-x,0))
idx = which(S2 < K)
idx
S = S2[idx]
V = x3[idx]*exp(-r)
conti = unname(fitted(lm(V~S+I(S^2))))
round(coef(lm(V~S+I(S^2))),3)
exerc = K - S2[idx]
idx2 = idx[conti < exerc]
idx2
x3[idx2] = 0
x2 = rep(0,8)
x2[idx2] = exerc[conti < exerc]
x2
# 
rm(list = c('idx','idx2','conti','exerc'))
idx = which(S1 < K)
idx
S = S1[idx]
V = x2[idx]*exp(-r)
conti = unname(fitted(lm(V~S+I(S^2))))
round(coef(lm(V~S+I(S^2))),3)
exerc = K - S1[idx]
idx2 = idx[conti < exerc]
idx2
x2[idx2] = 0
x1 = rep(0,8)
x1[idx2] = exerc[conti < exerc]
x1
#
x0 = sum((x3*exp(-r*3) + x2*exp(-r*2) + x1*exp(-r))/8)
x0
if(x0 < K - S0) {print('exercise immediately')} else {print('not exercise immediately')}
# for loop -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
S3 = c(1.34, 1.54, 1.03, 0.92, 1.52, 0.9, 1.01, 1.34)
S2 = c(1.08, 1.26, 1.07, 0.97, 1.56, 0.77, 0.84, 1.22)
S1 = c(1.09, 1.16, 1.22, 0.93, 1.11, 0.76, 0.92, 0.88)
S0 = 1
K = 1.1
r = 0.06
# 
paths = 8
steps = 3
price = matrix(c(S1,S2,S3), paths, steps)
table = matrix(0, paths, steps)
table[,steps] = sapply(price[,steps], function(x) max(K-x,0))
for (i in (steps-1):1) {
  S_all = price[,i]
  idx = which(S_all < K)
  S = S_all[idx]
  V = table[idx,i+1]*exp(-r)
  conti = unname(fitted(lm(V~S+I(S^2))))
  exerc = K - S_all[idx]
  idx2 = idx[conti < exerc]
  table[idx2, i+1] = 0
  table[idx2, i] = exerc[conti < exerc]
}
mean(c(table%*%matrix(exp(-r*(1:steps)),ncol=1)))
