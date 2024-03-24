#include <iostream>
#include <cstdlib>
#include <cmath>
using namespace std;
double explicit_finite(double,double,double,double,double,double,double,char,char,int,int);
int main(void)
{
	double S = 50, S_max = 100, K = 50, r = 0.1, q = 0, sigma = 0.4, T = double(5)/12;
	char OptionType ='p', ExerciseType = 'a';
	int N = 10, M = 20;
	double ans = explicit_finite(S, S_max, K, r, q, sigma, T, OptionType, ExerciseType, N, M);
	cout<<ans<<endl;
	system("pause");
	return 0;
}

double explicit_finite(double S, double S_max, double K, double r, double q, double sigma, double T \
, char OptionType, char ExerciseType, int N, int M)
{
    double dS = S_max/M;
    double dt = T/N;
    double f[N+1][M+1] = {0};
    
    if(OptionType == 'p')          // put
	{
        for(int i=0;i<N+1;i++)
        {
        	f[i][0] = K;
        	f[i][M] = 0;
		}
        for(int j=0;j<M+1;j++)
            f[N][j] = max(K-j*dS, double(0));
	}
    else                           // call
	{
        for(int i=0;i<N+1;i++)
        {
        	f[i][0] = 0;
        	f[i][M] = K;
		}
        for(int j=0;j<M+1;j++)
            f[N][j] = max(j*dS-K, double(0));
    }
    for(int i=N-1;i>=0;i--)
    {
        for(int j=M-1;j>=1;j--)
        {
            double a = ( -0.5*(r-q)*j*dt + 0.5*pow(sigma,2)*pow(j,2)*dt ) / (1+r*dt);
            double b = ( 1-pow(sigma,2)*pow(j,2)*dt ) / (1+r*dt);
            double c = ( 0.5*(r-q)*j*dt + 0.5*pow(sigma,2)*pow(j,2)*dt ) / (1+r*dt);
            if(OptionType == 'p')
            {
            	if(ExerciseType == 'a')
            	{
            		// American put
                    double intrinsic_value = max( K-j*dS, double(0));
                    f[i][j] = max(   a*f[i+1][j-1] + b*f[i+1][j] + c*f[i+1][j+1] , intrinsic_value);
				}
                else           // European put
                    f[i][j] = a*f[i+1][j-1] + b*f[i+1][j] + c*f[i+1][j+1];
			}
            else
            {
            	if(ExerciseType == 'a')
                {
                	// American call
                    double intrinsic_value = max( j*dS-K, double(0));
                    f[i][j] = max(   a*f[i+1][j-1] + b*f[i+1][j] + c*f[i+1][j+1] , intrinsic_value);
				}
                else    // European call
                    f[i][j] = a*f[i+1][j-1] + b*f[i+1][j] + c*f[i+1][j+1];
			}
        }
    }
    int ind = int(S/dS);
    return f[0][ind];
}
