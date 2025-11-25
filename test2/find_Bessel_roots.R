#
# 3*J_1(x) + x*J'_1(x) = 0
# Use Differential Recurrence Relations
# 2*J_1(x) + x*J_0(x) = 0
# 2 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())

f <- function(x) 2 * besselJ(x, 1) + x * besselJ(x, 0)

find_roots <- function(n) {
  roots <- numeric(n)
  interval_start <- 0
  i <- 1
  
  while (i <= n) {
    root_result <- tryCatch({
      uniroot(f, c(interval_start, interval_start + 1))$root
    }, error = function(e) NULL)
    
    if (!is.null(root_result)) {
      roots[i] <- root_result
      i <- i + 1
      interval_start <- root_result + 1
    } else {
      interval_start <- interval_start + 1
    }
  }
  
  return(roots)
}

round(find_roots(6), 4)


