# symmetric matrix --------------------------------------------------------
cat("\014")
rm(list=ls())
# 1. fill upper *******************************
x = matrix(0,4,4)
x[upper.tri(x)] = 1:6
# 2. fill lower
x[lower.tri(x)] = t(x)[lower.tri(x)]
isSymmetric.matrix(x)

# 1. fill lower *******************************
x = matrix(0,4,4)
x[lower.tri(x)] = 1:6
# 2. fill upper *******************************
x[upper.tri(x)] = t(x)[upper.tri(x)]
isSymmetric.matrix(x)


# wrong method *********************************
x = matrix(0,4,4)
x[upper.tri(x)] = 1:6
x[lower.tri(x)] = x[upper.tri(x)]
# x[lower.tri(x)] = 1:6
# x[upper.tri(x)] = x[lower.tri(x)]
isSymmetric.matrix(x)
