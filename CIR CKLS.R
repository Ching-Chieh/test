# Euro to USD -----------------------------------------------------------------------
cat("\014")
rm(list=ls())
library(yuima)
quantmod::getSymbols("DEXUSEU", src="FRED")
meanCIR <- mean(DEXUSEU, na.rm=TRUE)
DEXUSEU <- setData(na.omit(DEXUSEU),delta=1/252)
# Vasicek
vasicek <- setModel(drift="theta1-theta2*x", diffusion="sigma")
mod.vasicek <- setYuima(model=vasicek, data=DEXUSEU)
vasicek.fit <- qmle(mod.vasicek,
                    start=list(theta1=1, theta2=1, sigma=0.5),
                    lower=list(theta1=0.1, theta2=0.1, sigma=0.1),
                    upper=list(theta1=10, theta2=10, sigma=100),
                    method="L-BFGS-B")
summary(vasicek.fit)
# CIR
cir <- setModel(drift="kappa*(mu-x)", diffusion="sigma*sqrt(x)")
mod.cir <- setYuima(model=cir, data=DEXUSEU)
cir.fit <- qmle(mod.cir,
                start=list(kappa=1, mu=meanCIR, sigma=0.5),
                lower=list(kappa=0.1, mu=0.1, sigma=0.1),
                upper=list(kappa=10, mu=10, sigma=100),
                method="L-BFGS-B")
summary(cir.fit)
meanCIR
# CKLS
ckls <- setModel(drift="theta1-theta2*x", diffusion="sigma*x^gamma")
mod.ckls <- setYuima(model=ckls, data=DEXUSEU)
ckls.fit <- qmle(mod.ckls,
                 start=list(theta1=1, theta2=1, sigma=0.5,gamma=0.5),
                 lower=list(theta1=0.1, theta2=0.1, sigma=0.1,gamma=0.1),
                 upper=list(theta1=10, theta2=10, sigma=10,gamma=2),
                 method="L-BFGS-B")
summary(ckls.fit)
AIC(vasicek.fit,cir.fit,ckls.fit)
