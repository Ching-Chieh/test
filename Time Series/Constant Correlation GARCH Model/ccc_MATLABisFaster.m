function llv = nlogl(params, da) % R2024a can define functions anywhere in scripts.
global cnt
fprintf('... %d ...........\n', cnt);
T = size(da, 1);
N = size(da, 2);
u = da - ones(T, 1) * params(1:N);
vcv = params(N+1:2*N);
vav = params(2*N+1:3*N);
vbv = params(3*N+1:4*N);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
qc = diag(params(4*N+1:5*N-1));
for i = 2:(N-1)
    for j = 1:(i-1)
        qc(i,j) = params(5*N:(5*N+(N-1)*(N-2)/2-1));
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h = zeros(N, N, T);
h(:,:,1) = cov(da);
for t = 2:T
    for i = 1:N
        uu = u(t-1,:)' * u(t-1,:);
        h(i,i,t) = vcv(i) + vav(i) * uu(i,i) + vbv(i) * h(i,i,t-1);
    end
    for i = 2:N
        for j = 1:(i-1)
            h(i,j,t) = qc(i-1,j) * sqrt(h(i,i,t) * h(j,j,t));
        end
    end
    for ii = 1:(N-1)
        for jj = (ii+1):N
            h(ii,jj,t) = h(jj,ii,t);
        end
    end
end
llv = zeros(1,T);
for t = 1:T
    llv(t) = u(t,:) * inv(h(:, :, t)) * u(t,:)';
end
tmp = zeros(1,T);
for t = 1:T
    tmp(t) = det(h(:, :, t));
end
cnt = cnt + 1;
llv = -sum(-0.5*(log(tmp) + llv));
end
%%%%%   main  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear

da = table2array(readtable('d-spcscointc.txt'));
T = size(da, 1);
N = size(da, 2);
start_values = [
    mean(da, 1) ...              % mean
    diag(cov(da))' ...           % vcv
    repmat(0.05, 1, N) ...       % vav
    repmat(0.8, 1, N) ...        % vbv
    zeros(1, (N-1)*N/2) ...      % correlations  (2,1) (3,2) (3,1)
];
lower = [
    -20*abs(mean(da, 1)) ...     % mean
    zeros(1, N) ...              % vcv
    zeros(1, N) ...              % vav
    zeros(1, N) ...              % vbv
    repmat(-1, 1, (N-1)*N/2) ... % correlations  (2,1) (3,2) (3,1)
];
upper = [
    20*abs(mean(da, 1)) ...      % mean
    20*diag(cov(da))' ...        % vcv
    ones(1, N) ...               % vav
    ones(1, N) ...               % vbv
    ones(1, (N-1)*N/2) ...       % correlations  (2,1) (3,2) (3,1)
];

global cnt
cnt = 1;
[pars,fval] = fmincon(@(x) nlogl(x, da), start_values, [], [], [], [], lower, upper);

names = {'mean_1' 'mean_2' 'mean_3' ...
         'c1' 'c2' 'c3' ...
         'a1' 'a2' 'a3' ...
         'b1' 'b2' 'b3' ...
         'rho(1,2)' 'rho(2,3)' 'rho(1,3)' ...
};
for i = 1:length(pars)
    fprintf('%s: %.5f\n', names{i}, pars(i));
end
fprintf('log likelihood = %.3f\n', -fval);