clc
clear
close
randn('state',0)
S0 = 50;
K = 52;
r = 0.1;
T = 5/12;
sigma = 0.4;
NRepl = 195000;
NPilot = 5000;
S = S0*exp(  (r-0.5*sigma^2)*T+sigma*randn(NPilot,1)*sqrt(T)    );
CallValue = exp(-r*T)*max(S-K,0);
cov_mat = cov(S,CallValue);
EY = S0*exp(r*T);
VarY = S0^2*exp(2*r*T)*(exp(sigma^2*T)-1);
c = -cov_mat(1,2)/VarY;

Y = S0*exp(  (r-0.5*sigma^2)*T+sigma*randn(NRepl,1)*sqrt(T)    );
X = exp(-r*T)*max(Y-K,0);
Xc = X + c*(Y-EY);
[muHat,sigmaHat,CI] = normfit(Xc);
muHat
BS_Value = BS (S0,K,r,0,sigma,T,'c')
(CI(2)-CI(1))/muHat
