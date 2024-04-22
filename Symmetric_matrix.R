# fill a symmetric matrix -------------------------------------------------
cat("\014")
rm(list=ls())
# wrong method
x = matrix(0,4,4)
x[upper.tri(x)] = 1:6
x[lower.tri(x)] = x[upper.tri(x)]
isSymmetric.matrix(x)
# right method
x = matrix(0,4,4)
x[upper.tri(x)] = 1:6
x[lower.tri(x)] = t(x)[lower.tri(x)]
isSymmetric.matrix(x)
