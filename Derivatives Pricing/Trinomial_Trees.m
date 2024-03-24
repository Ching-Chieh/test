function Trinomial_Value = Trinomial_Trees(S0,K,r,q,sigma,T,OptionType,ExerciseType,NT)
% Trinomial Trees.
% John C. Hull. Options, Futures, and Other Derivatives, Global Edition. 9th p.489
dt=T/NT;
u=exp(sigma*sqrt(3*dt));
d=1/u;
pu = sqrt(dt/(12*sigma^2))*(r-q-0.5*sigma^2)+1/6;
pm = 2/3;
pd = -sqrt(dt/(12*sigma^2))*(r-q-0.5*sigma^2)+1/6;

f=zeros(NT+1,2*(NT+1)-1);
for j = 1:(2*(NT+1)-1);
    if (OptionType=='p')
        f(NT+1,j) = max(K-S0*(u^(j-1))*(d^NT),0);
    else
        f(NT+1,j) = max(S0*(u^(j-1))*(d^NT)-K,0);
    end;
end;

for i = NT:-1:1;
    for j = 1:(2*i-1);
        if (OptionType=='p')
            if (ExerciseType=='a')
                % American put
                EV=max(K-S0*(u^(j-1))*(d^(i-1)),0);
                f(i,j)=max(EV, exp(-r*dt)*(pd*f(i+1,j)+pm*f(i+1,j+1)+pu*f(i+1,j+2)));
            else
                % European put
                f(i,j)= exp(-r*dt)*(pd*f(i+1,j)+pm*f(i+1,j+1)+pu*f(i+1,j+2));
            end;
        else
            if (ExerciseType=='a')
                % American call
                EV=max(S0*(u^(j-1))*(d^(i-1))-K,0);
                f(i,j)=max(EV, exp(-r*dt)*(pd*f(i+1,j)+pm*f(i+1,j+1)+pu*f(i+1,j+2)));
            else
                % European call
                f(i,j)= exp(-r*dt)*(pd*f(i+1,j)+pm*f(i+1,j+1)+pu*f(i+1,j+2));
            end;
        end;
    end;
end;
Trinomial_Value=f(1,1);
