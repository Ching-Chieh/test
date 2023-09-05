def Explicit_Finite_Difference(S, S_max, K, r, q, sigma, T, OptionType, ExerciseType, N, M):
    import numpy as np
    dS = S_max/M
    dt = T/N
    f = np.asmatrix(np.zeros((N+1,M+1)))
    
    if OptionType == 'p':       # put
        f[:,0] = K
        f[:,M] = 0
        for j in range(M+1):
            f[N,j] = max(K-j*dS,0)
    else:                       # call
        f[:,0] = 0
        f[:,M] = K
        for j in range(M+1):
            f[N,j] = max(j*dS-K,0)
    
    for i in range(N-1,-1,-1):
        for j in range(M-1,0,-1):
            a = ( -0.5*(r-q)*j*dt + 0.5*(sigma**2)*(j**2)*dt ) / (1+r*dt)
            b = ( 1-(sigma**2)*(j**2)*dt ) / (1+r*dt)
            c = ( 0.5*(r-q)*j*dt + 0.5*(sigma**2)*(j**2)*dt ) / (1+r*dt)
            if OptionType == 'p':
                if ExerciseType == 'a':
                    # American put
                    intrinsic_value = max( K-j*dS, 0)
                    f[i,j] = max(   a*f[i+1,j-1] + b*f[i+1,j] + c*f[i+1,j+1] , intrinsic_value)
                else:
                    # European put
                    f[i,j] = a*f[i+1,j-1] + b*f[i+1,j] + c*f[i+1,j+1]
            else:
                if ExerciseType == 'a':
                    # American call
                    intrinsic_value = max( j*dS-K,0)
                    f[i,j] = max(   a*f[i+1,j-1] + b*f[i+1,j] + c*f[i+1,j+1] , intrinsic_value)
                else:
                    # European call
                    f[i,j] = a*f[i+1,j-1] + b*f[i+1,j] + c*f[i+1,j+1]
    ind = int(S/dS)
    return f[0,ind]
