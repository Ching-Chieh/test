function y = garchopm(params, r)
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
