# %% Constant Conditional Correlation GARCH(1,1) ----------------------------------------
# The result is similar with SAS' VARMAX Procedure.
# Convergence is successful with 7488 iterations. (time-consuming)
from IPython import get_ipython
get_ipython().run_line_magic('reset', '-f')
import numpy as np
import pandas as pd
from scipy.optimize import minimize

da = pd.read_csv('d-spcscointc.csv').values
T = da.shape[0]  # number of timepoints
N = da.shape[1]  # dimension of vector, number of assets

def nlogl(params):
    global cnt
    print('...', cnt, '...........')
    u = da - params[:N]
    vcv = params[N:2*N]
    vav = params[2*N:3*N]
    vbv = params[3*N:4*N]
    qc = np.diag(params[4*N:5*N-1])                                     # rho(1,2) rho(2,3)
    qc[np.tril_indices(N-1, -1)] = params[5*N-1:5*N+(N-1)*(N-2)//2-1]   # rho(1,3)
    for t in range(1, T):
        for i in range(N):
            h[t, i, i] = vcv[i] + vav[i] * np.outer(u[t-1], u[t-1])[i,i] + vbv[i] * h[t-1, i, i]
        for i in range(1, N):
            for j in range(i):
                h[t, i, j] = qc[i-1, j] * np.sqrt(h[t, i, i] * h[t, j, j])
        for ii in range(N-1):
            for jj in range(ii+1, N):
                h[t, ii, jj] = h[t, jj, ii]
    llv = np.zeros(T)
    for t in range(T):
        llv[t] = np.dot(np.dot(u[t], np.linalg.inv(h[t, :, :])), u[t])
    llv = np.sum(-0.5*(np.log(np.linalg.det(h)) + llv))
    cnt += 1
    return -llv

# Set initial values
rr = np.cov(da, rowvar=False)
h = np.zeros((T,N,N))
h[0,:,:] = rr
start_values = np.concatenate([
    np.mean(da, axis=0),      # mean
    np.diag(rr),              # vcv
    np.repeat(0.05, N),       # vav
    np.repeat(0.8, N),        # vbv
    np.repeat(0, (N-1)*N//2)  # correlations  (2,1) (3,2) (3,1)
])

cnt = 1
S = 1e-6
lower = np.concatenate([
    -20*np.abs(np.mean(da, axis=0)),  # mean
    np.repeat(S, N),                  # vcv
    np.repeat(S, N),                  # vav
    np.repeat(S, N),                  # vbv
    np.repeat(-1+S, (N-1)*N//2)       # correlations  (2,1) (3,2) (3,1)
])
upper = np.concatenate([
    20*np.abs(np.mean(da, axis=0)),   # mean
    20*np.diag(rr),                   # vcv
    np.repeat(1-S, N),                # vav
    np.repeat(1-S, N),                # vbv
    np.repeat(1-S, (N-1)*N//2)        # correlations  (2,1) (3,2) (3,1)
])

bounds = list(zip(list(lower), list(upper)))
mm = minimize(nlogl, start_values, bounds = bounds)

print(mm)
pars = mm.x
names = [
    'mean_1', 'mean_2', 'mean_3',
    'c1', 'c2', 'c3',
    'a1', 'a2', 'a3',
    'b1', 'b2', 'b3',
    'rho(1,2)', 'rho(2,3)', 'rho(1,3)'
]
pd.DataFrame(mm.x, index=names, columns=['Estimate'])
# %% Use SAS' estimates to replicate SAS' log likelihood --------------------------------
from IPython import get_ipython
get_ipython().run_line_magic('reset', '-f')
import numpy as np
import pandas as pd
args = np.array([
  0.07074, 0.33455, 0.20797, # mean
  0.00818, 0.18336, 0.04149, # vcv
  0.04320, 0.06187, 0.01178, # vav
  0.94428, 0.91661, 0.98135, # vbc
  0.51954, 0.47771, 0.48626  # correlations  (2,1) (3,2) (3,1)
])

da = pd.read_csv('d-spcscointc.csv').values
T = da.shape[0]  # number of timepoints
N = da.shape[1]  # dimension of vector, number of assets
rr = np.cov(da, rowvar=False)
h = np.zeros((T,N,N))
h[0,:,:] = rr

u = da - args[:N]
vcv = args[N:2*N]
vav = args[2*N:3*N]
vbv = args[3*N:4*N]
qc = np.diag(args[4*N:5*N-1])  # rho(1,2) rho(2,3)
qc[np.tril_indices(N-1, -1)] = args[5*N-1:5*N+(N-1)*(N-2)//2-1] # rho(1,3)
for t in range(1, T):
    for i in range(N):
        h[t, i, i] = vcv[i] + vav[i] * np.outer(u[t-1], u[t-1])[i,i] + vbv[i] * h[t-1, i, i]
    for i in range(1, N):
        for j in range(i):
            h[t, i, j] = qc[i-1, j] * np.sqrt(h[t, i, i] * h[t, j, j])
    for ii in range(N-1):
        for jj in range(ii+1, N):
            h[t, ii, jj] = h[t, jj, ii]
llv = np.zeros(T)
for t in range(T):
    llv[t] = np.dot(np.dot(u[t], np.linalg.inv(h[t, :, :])), u[t])
llv = np.sum(-0.5*(np.log(np.linalg.det(h)) + llv))
llv
