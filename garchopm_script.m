% Duan, GARCH Option Pricing Model, 1995, Mathematical Finance
clc
clear
close
da = readtable('rtn.csv');
r = da.r;
x0  = [0.000015 0.19 0.72 0.007];
A = [0 1 1 0];
b = 1;
lb = [0 0 0 0];
ub = [+Inf +Inf +Inf +Inf];
params = fmincon(@(x) garchopm(x,r), x0, A, b, [], [], lb, ub)
omega = params(1);
alpha = params(2);
beta  = params(3);
lambda = params(4);
[omega alpha beta lambda]
