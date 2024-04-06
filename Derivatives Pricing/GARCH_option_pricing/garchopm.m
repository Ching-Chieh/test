% Duan, GARCH Option Pricing Model, 1995, Mathematical Finance
function y = garchopm(params, r) % R2024a can define functions anywhere in scripts.
omega = params(1);
alpha = params(2);
beta  = params(3);
lambda = params(4);

rf = 0;
N = length(r);
h = zeros(N,1);
h(1) = var(r);
e = zeros(N,1);
for t=2:N
   e(t-1) = r(t-1) - rf + 0.5*h(t-1) - lambda*sqrt(h(t-1));
   h(t) = omega + alpha*e(t-1)^2 + beta*h(t-1);
end
e(N) = r(N) - rf + 0.5*h(N) - lambda*sqrt(h(N));
logl = -sum(log(h) + e.^2./h);
y = -logl; 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
params = fmincon(@(x) garchopm(x,r), x0, A, b, [], [], lb, ub);
omega = params(1);
alpha = params(2);
beta  = params(3);
lambda = params(4);
[omega alpha beta lambda]
