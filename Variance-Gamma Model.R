# Variance-Gamma Model -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
n = 10000
S0 = 100
T = 0.5
v = 0.5
theta = 0.1
sigma = 0.2
r = 0
q = 0
w = (T/v)*log(1-theta*v-0.5*v*sigma^2)
alpha = T/v
g = rgamma(n, shape = alpha, scale = v)
z = theta*g+sigma*sqrt(g)*rnorm(n)
ST_gamma = S0*exp((r-q)*T+w+z)
ST_GBM = S0*exp((r-q-0.5*sigma^2)*T+sigma*rnorm(n)*sqrt(T))
# compare -----------------------------------------------------------------------
plot(density(ST_gamma),col='red',main="",xlab="",xlim=c(40,180),xaxt = "n", yaxt = "n")
lines(density(ST_GBM),col='blue')
axis(1,at = seq(40,180,20))
legend("topright", legend=c("gamma", "GBM"), lty=1, col=c("red", "blue"))
