# John C. Hull. Options, Futures, and Other Derivatives, Global Edition. 9th p.6117 Example 25.3
import numpy as np
from scipy.stats import norm, binom
from scipy.integrate import quad
t = np.arange(1, 6)
t1 = np.linspace(0.5, 4.5, num=5)
_lambda = 0.02
rho = 0.3
R = 0.4
r = 0.05
def Q(f):
    return norm.cdf((norm.ppf(1 - np.exp(-_lambda * t)) - np.sqrt(rho) * f) / np.sqrt(1 - rho))
def p(f):
    p1 = 1 - binom.cdf(2, 10, Q(f))
    return np.insert(np.diff(p1), 0, p1[0])
def Cf(f):
    return np.sum(p(f) * (1 - R) * np.exp(-r * t1))
def Af(f):
    return np.sum(binom.cdf(2, 10, Q(f)) * np.exp(-r * t))
def Bf(f):
    return np.sum(0.5 * p(f) * np.exp(-r * t1))
def Cf1(f):
    return norm.pdf(f) * Cf(f)
def Af1(f):
    return norm.pdf(f) * Af(f)
def Bf1(f):
    return norm.pdf(f) * Bf(f)
C, _ = quad(Cf1, -np.inf, np.inf)
A, _ = quad(Af1, -np.inf, np.inf)
B, _ = quad(Bf1, -np.inf, np.inf)
spread = C / (A + B)
print("C:", round(C, 4))
print("A:", round(A, 4))
print("B:", round(B, 4))
print("Spread:", round(spread, 4))
#
f = -1.0104
print("C:", round(Cf(f), 4))
print("A:", round(Af(f), 4))
print("B:", round(Bf(f), 4))
