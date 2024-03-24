# 99.9% Worst Case Default Rate (WCDR)
# Vasicek's Model, One-factor Gaussian copula model
# Assumptions:
#    1. All loans have the same unconditional cdf for the time to default.
#    2. The copula correlation between each pair of loans is the same.
# John C. Hull. Risk Management and Financial Institutions, 5th, p262
# WCDR -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(tidyverse)
da=read_csv('defaultrate.csv', show_col_types = F)
logl <- function(parm){
  rho=parm[1]
  pd=parm[2]
  x <- da %>% 
    mutate(logg = log(sqrt((1-rho)/rho))*
             0.5*( qnorm(dr)^2 - 
                   ((sqrt(1-rho)*qnorm(dr)-qnorm(pd))/sqrt(rho))^2
                  )
           ) %>% 
    pull(logg)
  -sum(x)
}
init_values=c(rho=0.1,pd=0.01)
S=1e-6
mm=optim(init_values,logl,method = 'L-BFGS-B',
         lower = c(S,S),upper = c(1-S,1-S))
mm$convergence
(rho=mm$par[[1]])
(pd=mm$par[[2]])
wcdr=pnorm((qnorm(pd)+sqrt(rho)*qnorm(0.999))/sqrt(1-rho))
cat('99.9% worst case default rate= ',round(wcdr*100,3),'%\n', sep = '')
gDR <- function(dr,rho,pd) {
  sqrt((1-rho)/rho)*
    exp(0.5*( qnorm(dr)^2 - 
              ((sqrt(1-rho)*qnorm(dr)-qnorm(pd))/sqrt(rho))^2
             )
    )
}
ggplot() +
  geom_function(fun = gDR,
                args = list(rho=rho,pd=pd),
                xlim = c(S,0.06)) + 
  scale_x_continuous(breaks = seq(0,0.06,0.01)) + 
  labs(x = "default rate",
       y = "density")
