# fixed point 單變數 -------------------------------------------------------------------------
cat("\014")
rm(list=ls())
g <- function(x) {
  cos(x)
}

fixed_point <- function(g, x0, tol = 1e-6, max_iter = 1000) {
  x_old <- x0
  for (i in 1:max_iter) {
    x_new <- g(x_old)
    if (abs(x_new - x_old) < tol) {
      cat("收斂於第", i, "次迭代\n")
      return(x_new)
    }
    x_old <- x_new
  }
  warning("未收斂")
  return(x_new)
}

x0 <- 1
result <- fixed_point(g, x0)
cat("近似解為:", result, "\n")

uniroot(\(x) x-cos(x), interval = c(-5,5))$root

# fixed point 雙變數 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())

fixed_point_2d <- function(g1, g2, x0, y0, tol = 1e-6, max_iter = 1000) {
  x_old <- x0
  y_old <- y0
  
  for (i in 1:max_iter) {
    x_new <- g1(x_old, y_old)
    y_new <- g2(x_old, y_old)
    
    if (sqrt((x_new - x_old)^2 + (y_new - y_old)^2) < tol) {
      cat("收斂於第", i, "次迭代\n")
      return(c(x = x_new, y = y_new))
    }
    
    x_old <- x_new
    y_old <- y_new
  }
  warning("未收斂")
  return(c(x = x_new, y = y_new))
}

g1 <- function(x, y) cos(y)
g2 <- function(x, y) sin(x)

x0 <- 0.5
y0 <- 0.5

result <- fixed_point_2d(g1, g2, x0, y0)

cat("近似解為:\n")
print(result)


y=uniroot(\(y) sin(cos(y))-y, interval = c(-1, 1))$root
x=cos(y)
x
y

# converge plot 單變數 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
# --- 固定點迭代函數 ---
fixed_point <- function(g, x0, tol = 1e-6, max_iter = 50) {
  xs <- numeric(max_iter)
  xs[1] <- x0
  for (i in 2:max_iter) {
    xs[i] <- g(xs[i - 1])
    if (abs(xs[i] - xs[i - 1]) < tol) break
  }
  xs[1:i]
}

# --- 定義 g(x) 及其導數 ---
g1  <- function(x) cos(x)
g1p <- function(x) -sin(x)

g2  <- function(x) 2 - exp(x)
g2p <- function(x) -exp(x)

# 初始值
x0 <- 1

# 執行固定點迭代
x_seq1 <- fixed_point(g1, x0)
x_seq2 <- fixed_point(g2, x0)

# 導數絕對值在各點的大小
g1_deriv_vals <- abs(g1p(x_seq1))
g2_deriv_vals <- abs(g2p(x_seq2))

# --- 圖 1: 收斂與發散比較 ---
par(mfrow = c(1, 2))

plot(x_seq1, type="o", col="blue", pch=19,
     main="✅ 收斂：x = cos(x)",
     xlab="迭代次數", ylab="x 值")
abline(h=tail(x_seq1, 1), col="gray", lty=2)
legend("topright", legend=c("x 值收斂至 ~0.739"), col="blue", lty=1)

plot(x_seq2, type="o", col="red", pch=19,
     main="❌ 發散：x = 2 - exp(x)",
     xlab="迭代次數", ylab="x 值")
legend("topright", legend=c("值不穩定 → 發散"), col="red", lty=1)

# --- 圖 2: |g'(x)| 的大小比較 ---
par(mfrow = c(1, 1))
plot(g1_deriv_vals, type="o", col="blue", pch=19,
     ylim=c(0, max(c(g1_deriv_vals, g2_deriv_vals))),
     main="收斂條件比較：|g'(x)| < 1 才會收斂",
     xlab="迭代次數", ylab="|g'(x)|")
lines(g2_deriv_vals, type="o", col="red", pch=19)
abline(h=1, col="gray", lty=2)
legend("topright",
       legend=c("|g1'(x)| = |-sin(x)|", "|g2'(x)| = |exp(x)|", "閾值 |g'(x)| = 1"),
       col=c("blue", "red", "gray"), lty=c(1,1,2), pch=c(19,19,NA))

uniroot(\(x) 2-exp(x)-x, interval = c(-5,5))$root
# converge plot 雙變數 -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
fixed_point_2d_trace <- function(g1, g2, x0, y0, tol = 1e-6, max_iter = 1000) {
  xs <- numeric(max_iter)
  ys <- numeric(max_iter)
  xs[1] <- x0
  ys[1] <- y0
  
  for (i in 2:max_iter) {
    xs[i] <- g1(xs[i-1], ys[i-1])
    ys[i] <- g2(xs[i-1], ys[i-1])
    
    # 收斂判斷
    if (sqrt((xs[i] - xs[i-1])^2 + (ys[i] - ys[i-1])^2) < tol) {
      xs <- xs[1:i]
      ys <- ys[1:i]
      cat("收斂於第", i, "次迭代\n")
      return(data.frame(iter = 1:i, x = xs, y = ys))
    }
  }
  warning("未收斂")
  return(data.frame(iter = 1:max_iter, x = xs, y = ys))
}

# 定義 g1, g2
# x=cosy
# y=sinx
g1 <- function(x, y) cos(y)
g2 <- function(x, y) sin(x)

# 初始值
x0 <- 0.5
y0 <- 0.5

# 執行迭代並記錄
trace <- fixed_point_2d_trace(g1, g2, x0, y0)

# 最終解
final_point <- tail(trace, 1)

# --- 繪製收斂軌跡 ---
plot(trace$x, trace$y, type = "o", pch = 19, col = "blue",
     xlab = "x", ylab = "y",
     main = "雙變數固定點迭代收斂軌跡")
points(final_point$x, final_point$y, col = "red", pch = 19, cex = 1.5)
text(final_point$x, final_point$y, labels = "固定點", pos = 4, col = "red")
grid()

# 收斂條件
# 單變數: |g'(x)|
# 多變數: Jacobian 矩陣abs(特徵值)全部<1
# 改用向量，不要用一堆變數x,y,z... ---------------------------------------------
cat("\014")
rm(list=ls())
fixed_point <- function(g, x0, tol = 1e-6, max_iter = 1000) {
  x_old <- x0
  
  for (i in 1:max_iter) {
    x_new <- g(x_old)
    
    if (sqrt(sum((x_new - x_old)^2)) < tol) {
      cat("收斂於第", i, "次迭代\n")
      return(x_new)
    }
    
    x_old <- x_new
  }
  
  warning("未收斂")
  return(x_new)
}

g <- function(v) {
  x <- v[1]
  y <- v[2]
  c(cos(y), sin(x))
}

x0 <- c(0.5, 0.5)

result <- fixed_point(g, x0)

cat("近似解為:\n")
print(result)

