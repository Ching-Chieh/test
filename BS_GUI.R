cat("\014")
rm(list=ls())
BS <- function(type, S0, K, T1, t, sig, r, q) {
  type <- readline(prompt = "call(c) or put(p): ")
  S0 <- as.numeric(readline(prompt = "Current stock price: "))
  K <- as.numeric(readline(prompt = "Strike price: "))
  maturity_input <- readline(prompt = "Time to maturity (in years or fraction like 5/12): ")
  if (grepl("/", maturity_input)) {
    maturity_parts <- strsplit(maturity_input, "/")[[1]]
    tau <- as.numeric(maturity_parts[1]) / as.numeric(maturity_parts[2])
  } else tau <- as.numeric(maturity_input)
  sig <- as.numeric(readline(prompt = "Volatility: "))
  r <- as.numeric(readline(prompt = "Risk-free rate: "))
  q <- as.numeric(readline(prompt = "Dividend yield rate: "))
  d1 = (log(S0/K) + (r-q+0.5*sig^2)*tau)/(sig*sqrt(tau))
  d2 = d1 - sig*sqrt(tau)
  if (type =='c')
    return(S0*exp(-q*tau)*pnorm(d1) - K*exp(-r*tau)*pnorm(d2))
  else return(K*exp(-r*tau)*pnorm(-d2) - S0*exp(-q*tau)*pnorm(-d1))
}
BS()
