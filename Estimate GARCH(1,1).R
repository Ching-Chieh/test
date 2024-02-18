# normal distribution -----------------------------------------------------------------------
garch11Fit = function(x)
{
  Mean = mean(x); Var = var(x); S = 1e-6
  params = c(mu = Mean, omega = 0.1*Var, alpha = 0.1, beta = 0.8)
  lowerBounds = c(mu = -10*abs(Mean), omega = S^2, alpha = S, beta = S)
  upperBounds = c(mu = 10*abs(Mean), omega = 100*Var, alpha = 1-S, beta = 1-S)
  garchDist = function(z, hh) { dnorm(x = z/hh)/hh }
  garchLLH = function(parm) {
    mu = parm[1]; omega = parm[2]; alpha = parm[3]; beta = parm[4]
    z = (x-mu); Mean = mean(z^2)
    e = omega + alpha * c(Mean, z[-length(x)]^2)
    h = stats::filter(e, beta, "r", init = Mean)
    hh = sqrt(abs(h))
    llh = -sum(log(garchDist(z, hh)))
    llh }
  print(garchLLH(params))
  fit = nlminb(start = params, objective = garchLLH,
               lower = lowerBounds, upper = upperBounds)
  epsilon = 0.0001 * fit$par
  Hessian = matrix(0, ncol = 4, nrow = 4)
  for (i in 1:4) {
    for (j in 1:4) {
      x1 = x2 = x3 = x4 = fit$par
      x1[i] = x1[i] + epsilon[i]; x1[j] = x1[j] + epsilon[j]
      x2[i] = x2[i] + epsilon[i]; x2[j] = x2[j] - epsilon[j]
      x3[i] = x3[i] - epsilon[i]; x3[j] = x3[j] + epsilon[j]
      x4[i] = x4[i] - epsilon[i]; x4[j] = x4[j] - epsilon[j]
      Hessian[i, j] = (garchLLH(x1)-garchLLH(x2)-garchLLH(x3)+garchLLH(x4))/
        (4*epsilon[i]*epsilon[j])
    }
  }
  # Hessian = stats::optimHess(fit$par,garchLLH)
  se.coef = sqrt(diag(solve(Hessian)))
  tval = fit$par/se.coef
  matcoef = cbind(fit$par, se.coef, tval, 2*(1-pnorm(abs(tval))))
  dimnames(matcoef) = list(names(tval), c("Estimate","Std. Error", "t value", "Pr(>|t|)"))
  cat("\nCoefficient(s):\n")
  printCoefmat(matcoef, digits = 6, signif.stars = TRUE)
}
# t distribution ----------------------------------------------------------
garch11Fit = function(x)
{
  Mean = mean(x); Var = var(x); S = 1e-6
  params = c(mu = Mean, omega = 0.1*Var, alpha = 0.1, beta = 0.8, v = 2)
  lowerBounds = c(mu = -10*abs(Mean), omega = S^2, alpha = S, beta = S, v=1)
  upperBounds = c(mu = 10*abs(Mean), omega = 100*Var, alpha = 1-S, beta = 1-S, v=10)
  garchDist = function(z, hh, v) { dt(x = z/hh, df = v)/hh }
  garchLLH = function(parm) {
    mu = parm[1]; omega = parm[2]; alpha = parm[3]; beta = parm[4]; v=parm[5]
    z = (x-mu); Mean = mean(z^2)
    e = omega + alpha * c(Mean, z[-length(x)]^2)
    h = stats::filter(e, beta, "r", init = Mean)
    hh = sqrt(abs(h))
    llh = -sum(log(garchDist(z, hh, v)))
    llh }
  print(garchLLH(params))
  fit = nlminb(start = params, objective = garchLLH,
               lower = lowerBounds, upper = upperBounds)
  epsilon = 0.0001 * fit$par
  Hessian = matrix(0, ncol = 4, nrow = 4)
  for (i in 1:5) {
    for (j in 1:5) {
      x1 = x2 = x3 = x4 = fit$par
      x1[i] = x1[i] + epsilon[i]; x1[j] = x1[j] + epsilon[j]
      x2[i] = x2[i] + epsilon[i]; x2[j] = x2[j] - epsilon[j]
      x3[i] = x3[i] - epsilon[i]; x3[j] = x3[j] + epsilon[j]
      x4[i] = x4[i] - epsilon[i]; x4[j] = x4[j] - epsilon[j]
      Hessian[i, j] = (garchLLH(x1)-garchLLH(x2)-garchLLH(x3)+garchLLH(x4))/
        (4*epsilon[i]*epsilon[j])
    }
  }
  # Hessian = stats::optimHess(fit$par,garchLLH)
  se.coef = sqrt(diag(solve(Hessian)))
  tval = fit$par/se.coef
  matcoef = cbind(fit$par, se.coef, tval, 2*(1-pnorm(abs(tval))))
  dimnames(matcoef) = list(names(tval), c("Estimate","Std. Error", "t value", "Pr(>|t|)"))
  cat("\nCoefficient(s):\n")
  printCoefmat(matcoef, digits = 6, signif.stars = TRUE)
}
