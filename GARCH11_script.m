clc
clear
close

byd = readtable('byd.csv');
r = byd.r;
Mean = mean(r);
Var = var(r);
x0  = [Mean 0.1*Var 0.1 0.8];
A = [0 0 1 1];
b = 1;
lb = [-10*abs(Mean) 0 0 0];
ub = [10*abs(Mean) 100*Var 1 1];
params = fmincon(@(x) GARCH11(x,r), x0, A, b, [], [], lb, ub);
mu = params(1);
omega = params(2);
alpha  = params(3);
beta = params(4);
[mu omega alpha beta]
