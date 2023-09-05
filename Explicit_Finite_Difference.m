function value = Explicit_Finite_Difference(S,S_max,K,r,q,sigma,T,OptionType,ExerciseType,N,M)
% Explicit Finite Difference Method.
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



for i = N-1:-1:0
    for j = M-1:-1:1
        a = ( -0.5*(r-q)*j*dt + 0.5*(sigma^2)*(j^2)*dt ) / (1+r*dt);
        b = ( 1-(sigma^2)*(j^2)*dt ) / (1+r*dt);
        c = ( 0.5*(r-q)*j*dt + 0.5*(sigma^2)*(j^2)*dt ) / (1+r*dt);
        if (OptionType == 'p')
            if (ExerciseType=='a')
                % American put
                intrinsic_value = max( K-j*dS,0);
                f(i+1,j+1) = max(   a*f(i+2,j) + b*f(i+2,j+1) + c*f(i+2,j+2) , intrinsic_value);
            else
                % European put
                f(i+1,j+1) = a*f(i+2,j) + b*f(i+2,j+1) + c*f(i+2,j+2);
            end
        else
            if (ExerciseType=='a')
                % American call
                intrinsic_value = max( j*dS-K,0);
                f(i+1,j+1) = max(   a*f(i+2,j) + b*f(i+2,j+1) + c*f(i+2,j+2) , intrinsic_value);
            else
                % European call
                f(i+1,j+1) = a*f(i+2,j) + b*f(i+2,j+1) + c*f(i+2,j+2);
            end
        end
    end
end
value = f(1, S/dS+1);
