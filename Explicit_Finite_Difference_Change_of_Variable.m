function value = Explicit_Finite_Difference_Change_of_Variable(S,K,r,q,sigma,T,OptionType,ExerciseType,N,M)
% Explicit Finite Difference Change of Variable
% John C. Hull. Options, Futures, and Other Derivatives, Global Edition. 9th p.506
dt = T/N;
dZ = sigma*sqrt(3*dt);
f = zeros(N+1,M+1);

if (OptionType == 'p')      % put
    f(:,1) = K;
    f(:,M+1) = 0;
    for j = 0:M
        f(N+1,j+1) = max(K-exp(j*dZ),0);
    end
else                        % call
    f(:,1) = 0;
    f(:,M+1) = K;
    for j = 0:M
        f(N+1,j+1) = max(exp(j*dZ)-K,0);
    end
end



for i = N-1:-1:0
    for j = M-1:-1:1
        alpha = ( -dt/(2*dZ)*(r-q-0.5*(sigma^2))  +  dt/(2*(dZ^2))*(sigma^2) ) / (1+r*dt);
        beta = ( 1-(sigma^2)*dt/(dZ^2) ) / (1+r*dt);
        gamma = ( dt/(2*dZ)*(r-q-0.5*(sigma^2))  +  dt/(2*(dZ^2))*(sigma^2) ) / (1+r*dt);
        if (OptionType == 'p')
            if (ExerciseType=='a')
                % American put
                intrinsic_value = max( K-exp(j*dZ) ,0);
                f(i+1,j+1) = max(   alpha*f(i+2,j) + beta*f(i+2,j+1) + gamma*f(i+2,j+2) , intrinsic_value);
            else
                % European put
                f(i+1,j+1) = alpha*f(i+2,j) + beta*f(i+2,j+1) + gamma*f(i+2,j+2);
            end
        else
            if (ExerciseType=='a')
                % American call
                intrinsic_value = max( exp(j*dZ)-K,0);
                f(i+1,j+1) = max(   alpha*f(i+2,j) + beta*f(i+2,j+1) + gamma*f(i+2,j+2) , intrinsic_value);
            else
                % European call
                f(i+1,j+1) = alpha*f(i+2,j) + beta*f(i+2,j+1) + gamma*f(i+2,j+2);
            end
        end
    end
end
value = f(1, round(log(S)/dZ)+1);
