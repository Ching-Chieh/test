#include <iostream>
#include <cmath>
#include <stdexcept>
#include <functional>

double N(double x) {
    return 0.5 * erfc(-x * M_SQRT1_2);
}

double BS(char type, double S, double K, double T, double sigma, double r) {
    double d1 = (log(S / K) + (r + 0.5 * sigma * sigma) * T) / (sigma * sqrt(T));
    double d2 = d1 - sigma * sqrt(T);
    
    if (type == 'c') {
        return S * N(d1) - K * exp(-r * T) * N(d2);
    } else if (type == 'p') {
        return K * exp(-r * T) * N(-d2) - S * N(-d1);
    } else {
        throw std::invalid_argument("Option type must be 'c' or 'p'");
    }
}

double newton_solver(std::function<double(double)> f, double x0, double tol = 1e-8, int max_iter = 100) {
    double h = 1e-6;

    for (int i = 0; i < max_iter; ++i) {
        double fx = f(x0);
        double fpx = (f(x0 + h) - f(x0 - h)) / (2 * h);

        if (fabs(fpx) < 1e-12) {
            throw std::runtime_error("Derivative is zero, cannot proceed");
        }

        double x1 = x0 - fx / fpx;

        if (fabs(x1 - x0) < tol) {
            return x1;
        }

        x0 = x1;
    }

    throw std::runtime_error("Exceeded maximum number of iterations, did not converge");
}

double calculate_IV(double sigma0, double price, char type, double S, double K, double T, double r) {
    auto f = [=](double sigma) {
        return price - BS(type, S, K, T, sigma, r);
    };

    return newton_solver(f, sigma0);
}

int main() {
    std::cout << "----------------------------------------------------" << std::endl;

    char type = 'c';
    double S = 42;
    double K = 40;
    double T = 0.5;
    double r = 0.1;

    double market_price = 4.759422;
    double sigma_guess = 0.1;

    try {
        double implied_vol = calculate_IV(sigma_guess, market_price, type, S, K, T, r);
        std::cout << "Implied Volatility: " << implied_vol << std::endl;
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
    }

    std::cout << "----------------------------------------------------" << std::endl;
    return 0;
}
