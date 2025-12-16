from math import log, sqrt, exp
from scipy.stats import norm

class Options():
    def __init__(self, option_type, S, K, T, sigma, r):
        if option_type.lower() in ["c", "call"]:
            self.__option_type = "c"
        elif option_type.lower() in ["p", "put"]:
            self.__option_type = "p"
        else:
            raise ValueError("option_type must be 'call' or 'put'")
        self.S=S
        self.K=K
        self.T=T
        self.sigma=sigma
        self.r=r
    
    @property
    def option_type(self):
        return self.__option_type
    
    @option_type.setter
    def option_type(self, input_option_type):
        if input_option_type.lower() in ["c", "call"]:
            self.__option_type = "c"
        elif input_option_type.lower() in ["p", "put"]:
            self.__option_type = "p"
        else:
            raise ValueError("option_type must be 'call' or 'put'")
    
    @property
    def price(self):
        S=self.S
        K=self.K
        T=self.T
        sigma=self.sigma
        r=self.r
        d1 = (log(S / K) + (r + 0.5 * sigma**2) * T) / (sigma * sqrt(T))
        d2 = d1 - sigma * sqrt(T)
        if self.option_type == "c":
            return S * norm.cdf(d1) - K * exp(-r * T) * norm.cdf(d2)
        else: 
            return K * exp(-r * T) * norm.cdf(-d2) - S * norm.cdf(-d1)
S=42
K=40
T=0.5
sigma=0.2
r=0.1
option_type="c"

op1 = Options(option_type, S, K, T, sigma, r)
print(round(op1.price, 2))
op1.option_type="p"
print(round(op1.price, 2))

print(op1.S)
print(op1.K)
print(op1.T)
print(op1.sigma)
print(op1.r)

print(op1.option_type)
print(op1._Options__option_type)
