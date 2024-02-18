import numpy as np
import pandas as pd
from scipy.stats import norm
from scipy.optimize import minimize

def garch11Fit(x):
    Mean = np.mean(x)
    Var = np.var(x)
    S = 1e-6

    params = np.array([Mean, 0.1 * Var, 0.1, 0.8])
    lowerBounds = np.array([-10 * abs(Mean), S**2, S, S])
    upperBounds = np.array([10 * abs(Mean), 100 * Var, 1 - S, 1 - S])

    def garchDist(z, hh):
        return norm.pdf(z / hh) / hh

    def garchLLH(parm):
        mu, omega, alpha, beta = parm
        z = x - mu
        Mean = np.mean(z ** 2)
        e = omega + alpha * np.append(np.mean(z**2), z[:-1]**2)
        h = np.array([np.mean(z**2)])
        for i in range(len(e)):
            h = np.append(h, h[-1] * beta + e[i])
        h = h[1:]
        hh = np.sqrt(np.abs(h))
        llh = -np.sum(np.log(garchDist(z, hh)))
        return llh

    fit = minimize(garchLLH, params, bounds=list(zip(lowerBounds, upperBounds)))

    epsilon = 0.0001 * fit.x
    Hessian = np.zeros((4, 4))

    for i in range(4):
        for j in range(4):
            x1, x2, x3, x4 = fit.x.copy(), fit.x.copy(), fit.x.copy(), fit.x.copy()
            x1[i] += epsilon[i]; x1[j] += epsilon[j]
            x2[i] += epsilon[i]; x2[j] -= epsilon[j]
            x3[i] -= epsilon[i]; x3[j] += epsilon[j]
            x4[i] -= epsilon[i]; x4[j] -= epsilon[j]
            Hessian[i, j] = (garchLLH(x1) - garchLLH(x2) - garchLLH(x3) + garchLLH(x4)) / (4 * epsilon[i] * epsilon[j])

    se_coefs = np.sqrt(np.diag(np.linalg.inv(Hessian)))
    t_vals = fit.x / se_coefs
    p_vals = 2 * (1 - norm.cdf(np.abs(t_vals)))

    matcoef = np.column_stack((fit.x, se_coefs, t_vals, p_vals))
    col_names = ["Estimate", "Std. Error", "t value", "Pr(>|t|)"]

    print("\nCoefficient(s):\n")
    print(pd.DataFrame(matcoef, columns=col_names, index=["mu", "omega", "alpha", "beta"]))
# data #######################################################
df = pd.read_csv("byd.csv")
x = df['r'].to_numpy()
garch11Fit(x)
