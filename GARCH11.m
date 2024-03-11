function y = GARCH11(params,r)
mu = params(1);
omega = params(2);
alpha  = params(3);
beta = params(4);

N = length(r);
e = r - mean(r);
h = zeros(N,1);
h(1) = var(r);
for t=2:N
    h(t) = omega + alpha*e(t-1)^2 + beta*h(t-1);
end
logl = -sum(log(h) + e.^2./h);
y = -logl;
end
