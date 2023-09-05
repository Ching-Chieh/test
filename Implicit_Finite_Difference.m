function value = Implicit_Finite_Difference(S,S_max,K,r,q,sigma,T,OptionType,ExerciseType,N,M)
% Implicit Finite Difference Method
% 
dS = S_max/M;
dt = T/N;
f = zeros(N+1,M+1);

if (OptionType == 'p')      % put
    f(:,1) = K;
    f(:,M+1) = 0;
    for j = 0:M
        f(N+1,j+1) = max(K-j*dS,0);
    end
else                        % call
    f(:,1) = 0;
    f(:,M+1) = K;
    for j = 0:M
        f(N+1,j+1) = max(j*dS-K,0);
    end
end

for k = N:-1:1
    A = zeros(M-1,M-1);
    b = zeros(M-1,1);
    % fill b
    b(1,1) = f(k+1,2)-(0.5*(r-q)*dt-0.5*(sigma^2)*dt)*f(k,1);
    b(M-1,1) = f(k+1,M)-(-0.5*(r-q)*(M-1)*dt-0.5*(sigma^2)*((M-1)^2)*dt)*f(k,M+1);
    for i=2:M-2
        b(i,1)=f(k+1,i+1);
    end
    % fill A
    for j = 2:M-1
        A(j,j-1) = 0.5*(r-q)*j*dt - 0.5*(sigma^2)*(j^2)*dt;
    end
    for j = 1:M-1
        A(j,j) = 1 + (sigma^2)*(j^2)*dt + r*dt;
    end
    for j = 1:M-2
        A(j,j+1) = -0.5*(r-q)*j*dt - 0.5*(sigma^2)*(j^2)*dt;
    end
    x = inv(A)*b;
    for i=2:M
        f(k,i) = x(i-1,1);
    end
    if (ExerciseType =='a')
        if (OptionType == 'p')
            for i=2:M
                if(f(k,i) < K-(i-1)*dS)
                    f(k,i) = K-(i-1)*dS;
                end
            end
        else
            for i=2:M
                if(f(k,i) < (i-1)*dS-K)
                    f(k,i) = (i-1)*dS-K;
                end
            end
        end
    end     
end

value = f(1, S/dS+1);
