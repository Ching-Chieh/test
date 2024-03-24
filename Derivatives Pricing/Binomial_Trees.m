function Binomial_Value = Binomial_Trees(S0,K,r,q,sigma,T,OptionType,ExerciseType,NT)
% Binomial Trees. Cox, Ross, and Rubinstein (1979) approach.
% John C. Hull. Options, Futures, and Other Derivatives, Global Edition. 9th p.474
dt=T/NT;
u=exp(sigma*sqrt(dt));
d=1/u;
a=exp((r-q)*dt);
p=(a-d)/(u-d);

f=zeros(NT+1, NT+1);
for j = 0:NT;
    if (OptionType=='p')
        f(NT+1,j+1)=max(K-S0*(u^j)*(d^(NT-j)),0);
    else
        f(NT+1,j+1)=max(S0*(u^j)*(d^(NT-j))-K,0);
    end;
end;

for i = (NT-1):-1:0;
    for j = 0:i;
        if (OptionType=='p')
            if (ExerciseType=='a')
                % American put
                EV=max(K-S0*(u^j)*(d^(i-j)),0);
                f(i+1,j+1)=max(EV, exp(-r*dt)*(p*f(i+2,j+2)+(1-p)*f(i+2,j+1)));
            else
                % European put
                f(i+1,j+1)= exp(-r*dt)*(p*f(i+2,j+2)+(1-p)*f(i+2,j+1));
            end;
        else
            if (ExerciseType=='a')
                % American call
                EV=max(S0*(u^j)*(d^(i-j))-K,0);
                f(i+1,j+1)=max(EV, exp(-r*dt)*(p*f(i+2,j+2)+(1-p)*f(i+2,j+1)));
            else
                % European call
                f(i+1,j+1)= exp(-r*dt)*(p*f(i+2,j+2)+(1-p)*f(i+2,j+1));
            end;
        end;
    end;
end;
Binomial_Value=f(1,1);
                
                
                
