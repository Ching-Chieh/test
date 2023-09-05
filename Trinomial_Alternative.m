function Trinomial_Value = Trinomial_Alternative(S0,K,r,q,sigma,T,OptionType,ExerciseType,NT)
% Trinomial Trees. Alternative precedure.
% % John C. Hull. Options, Futures, and Other Derivatives, Global Edition. 9th p.514 Further Questions 21.29(c)
dt = T/NT;
u = exp((r-0.5*(sigma^2))*dt+sigma*sqrt(3*dt));
m = exp((r-0.5*(sigma^2))*dt);
d = exp((r-0.5*(sigma^2))*dt-sigma*sqrt(3*dt));
pu = 1/6;
pm = 2/3;
pd = 1/6;

S_matrix = zeros(NT+1, 2*(NT+1)-1);
f        = zeros(NT+1, 2*(NT+1)-1);
for i = 1:(NT+1)
    S_matrix(i,i) = S0*(m^(i-1));
end;
for i = 2:(NT+1)
    for j = (i+1):(i*2-1)
        S_matrix(i,j) = S_matrix(i,j-1)/m*u;
    end;
end;
for i = 2:(NT+1)
    for j = (i-1):-1:1
        S_matrix(i,j) = S_matrix(i,j+1)/m*d;
    end
end

for j = 1:(2*(NT+1)-1);
    if (OptionType=='p')
        f(NT+1,j) = max(K-S_matrix(NT+1,j), 0);
    else
        f(NT+1,j) = max(S_matrix(NT+1,j)-K, 0);
    end;
end;

for i = NT:-1:1;
    for j = 1:(2*i-1);
        if (OptionType=='p')
            if (ExerciseType=='a')
                % American put
                EV=max(K-S_matrix(i,j),0);
                f(i,j)=max(EV, exp(-r*dt)*(pd*f(i+1,j)+pm*f(i+1,j+1)+pu*f(i+1,j+2)));
            else
                % European put
                f(i,j)= exp(-r*dt)*(pd*f(i+1,j)+pm*f(i+1,j+1)+pu*f(i+1,j+2));
            end;
        else
            if (ExerciseType=='a')
                % American call
                EV=max(S_matrix(i,j)-K,0);
                f(i,j)=max(EV, exp(-r*dt)*(pd*f(i+1,j)+pm*f(i+1,j+1)+pu*f(i+1,j+2)));
            else
                % European call
                f(i,j)= exp(-r*dt)*(pd*f(i+1,j)+pm*f(i+1,j+1)+pu*f(i+1,j+2));
            end;
        end;
    end;
end;
Trinomial_Value=f(1,1);
