# binomial --------------------------------------------------------------------
cat("\014")
rm(list=ls())
binomial_tree <- function(OptionType, ExerciseType, S0, K, T, sigma, r, q, N) {
  dt <- T/N
  u <- exp(sigma*sqrt(dt))
  d <- 1/u
  a <- exp((r-q)*dt)
  p <- (a-d)/(u-d)
  # fill last column
  S <- matrix(0, N+1, N+1)
  S[N+1, 1] <- S0
  f <- matrix(0, N+1, N+1)
  for (i in (N+1):1) { # N = 5 steps
    S_ <- S0*u^(N-i+1)*d^(i-1)
    S[i, N+1] <- S_
    if (OptionType == "c") f[i, N+1] <- max(S_ - K, 0)
    else                   f[i, N+1] <- max(K - S_, 0)
  }
  for (j in N:1) {     # N = 5, column 5, 4, 3, 2, 1
    for (i in (N-j+2):(N+1)) {  # j = N, i = 2, 3, 4, 5, 6  # j = 1, i = (N-1+2):(N+1)
      if (j != 1) {
        S_ <- S0*u^(N-i+1)*d^(-N+i+j-2)
        S[i, j] <- S_
      } else {
        S_ <- S0
      }
      if (OptionType == "c") {
        if (ExerciseType == "a") {
          intrinsic_value <- max(S_ - K, 0)
          f[i, j] <- max(intrinsic_value, exp(-r*dt)*(p*f[i-1, j+1] + (1-p)*f[i, j+1]))
        } else {
          f[i, j] <- exp(-r*dt)*(p*f[i-1, j+1] + (1-p)*f[i, j+1])
        }
      } else {
        if (ExerciseType == "a") {
          intrinsic_value <- max(K - S_, 0)
          f[i, j] <- max(intrinsic_value, exp(-r*dt)*(p*f[i-1, j+1] + (1-p)*f[i, j+1]))
        } else {
          f[i, j] <- exp(-r*dt)*(p*f[i-1, j+1] + (1-p)*f[i, j+1])
        }
      }
    }
  }
  return(list(S_matrix = S, f_matrix = f, f_value = f[N+1, 1]))
}
# fill S ********************************************************
# S0=10
# u=1.2
# d=1/u
# N=3L
# S=matrix(0, N+1, N+1)
# S[N+1, 1] = S0
# for (j in (N+1):2) {
#   for (i in (N-j+2):(N+1)) {
#     S[i, j] <- S0*u^(N-i+1)*d^(-N+i+j-2)
#   }
# }
# round(S, 2)
