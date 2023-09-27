# John C. Hull. Options, Futures, and Other Derivatives, Global Edition. 9th p.507 Table 21.5
# 1 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
AmericanPutExp <- function(S0, Smin = 0, Smax, T, N = 10, M = 10, K, r, sigma) {
    dt = T/N
    dS = (Smax - Smin)/M
    t <- seq(0, T, by = dt)
    S <- seq(Smin, Smax, by = dS)
    A <- function(j) (-0.5 * r * j * dt + 0.5 * sigma^2 * j^2 * dt)/(1 + r * dt)
    B <- function(j) (1 - sigma^2 * j^2 * dt)/(1 + r * dt)
    C <- function(j) ( 0.5 * r * j * dt + 0.5 * sigma^2 * j^2 * dt)/(1 + r * dt)
    P <- matrix(, M + 1, N + 1)
    colnames(P) <- round(t, 2)
    rownames(P) <- round(rev(S), 2)
    P[M + 1, ] <- K
    P[1, ] <- 0
    P[, N + 1] <- sapply(rev(S), function(x) max(K - x, 0))
    earlyexercise <- matrix(FALSE, M + 1, N + 1)
    earlyexercise[M + 1, ] <- TRUE
    earlyexercise[which(P[, N + 1] > 0), N + 1] <- TRUE
    for (i in (N - 1):0) {
      for (j in 1:(M - 1)) {
        J <- M + 1 - j
        I <- i + 1
        P[J, I] <- A(j) * P[J + 1, I + 1] + B(j) * P[J, I + 1] + C(j) * P[J - 1, I + 1]
        if (P[J, I] < P[J, N + 1]){
          if (P[J, I] > 0){   # Just to be consistent with the textbook. When negative, should early exercise.
            P[J, I] <- P[J, N + 1]
            earlyexercise[J, I] <- TRUE
          }
        }
      }
    }
    colnames(earlyexercise) <- colnames(P)
    rownames(earlyexercise) <- rownames(P)
    ans <- list(S0 = S0, P = P, t = t, S = S, earlyexercise = earlyexercise, N = N, M = M)
    class(ans) <- "AmericanPut"
    return(invisible(ans))
  }
plot.AmericanPut <- function(obj) {
  plot(range(obj$t), range(obj$S), type = "n", axes = F, xlab = "t (months)", ylab = "S")
  axis(1, obj$t, obj$t*12)
  axis(2, obj$S, obj$S, cex.axis = 0.6, las = 1)
  abline(v = obj$t, h = obj$S, col = "darkgray", lty = "dotted")
  for (i in 0:obj$N) {
    for (j in 0:obj$M) {
      J <- obj$M + 1 - j
      I <- i + 1
      cl <- "grey"
      if (obj$earlyexercise[J, I]) cl <- "black"
      text(obj$t[i + 1], obj$S[j + 1], round(obj$P[J, I],2), cex = 0.75, col = cl)
    }
  }
  text(0, obj$S0, round(APut$P[as.character(obj$S0),'0'],2), cex = 0.75, col = 'red')
  dS <- mean(obj$S[1:2])
  y <- as.numeric(apply(obj$earlyexercise, 2, function(x) which(x)[1]))
  lines(obj$t, obj$S[obj$M + 2 - y] + dS, lty = 2)
}
cat("\014")
APut=AmericanPutExp(S0 = 50, Smax = 100, T = 5/12, N = 10, M = 20, K = 50, r = 0.1, sigma = 0.4)
round(APut$P,2)
APut$P['50','0']
plot(APut)



