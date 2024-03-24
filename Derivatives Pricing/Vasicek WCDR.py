import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.stats import norm
from scipy.optimize import minimize
df = pd.read_excel("defaultrate.xlsx")
# default rate log pdf
def dr_log_pdf(dr, rho, pd):
    return np.log(np.sqrt((1 - rho) / rho)) * (
            0.5 * (norm.ppf(dr) ** 2 - ((np.sqrt(1 - rho) * norm.ppf(dr) - norm.ppf(pd)) / np.sqrt(rho)) ** 2)
    )
# negative log likelihood
def neg_log_likelihood(para):
    rho = para[0]
    pd = para[1]
    return -np.sum(dr_log_pdf(df['dr'], rho, pd))

initial_values = np.array([0.1, 0.01])
S = 1e-5
bounds = [(S, 1 - S), (S, 1 - S)]

res = minimize(neg_log_likelihood, initial_values, bounds=bounds)
rho, pd = res.x

print('Copula correlation =', round(rho, 3))
print('Probability of Default =', round(pd * 100, 2), '%')

# 99.9% WCDR
X = 0.999
WCDR = norm.cdf((norm.ppf(pd) + np.sqrt(rho) * norm.ppf(X)) / np.sqrt(1 - rho))
print('99.9% WCDR =', round(WCDR * 100, 2), '%')

# Plotting
def g_DR(dr, rho, pd):
    return np.sqrt((1 - rho) / rho) * np.exp(
        0.5 * (norm.ppf(dr) ** 2 - ((np.sqrt(1 - rho) * norm.ppf(dr) - norm.ppf(pd)) / np.sqrt(rho)) ** 2)
    )
dr_values = np.linspace(S, 0.06, 1000)
g_values = g_DR(dr_values, rho, pd)

plt.plot(dr_values, g_values)
plt.xlabel('Default Rate')
plt.ylabel('Density')
plt.title('Default Rate Density')
plt.xticks(np.arange(0, 0.07, 0.01))
plt.show()
