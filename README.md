# Some Snippets
R, Python, MATLAB, and RATS programs

## Trading Strategies (Python, XScript)
1. Commodity: FITX*1
2. Contracts: 1
3. Period: 2021-06-01 ~ 2025-10-31
4. Benchmark: Buy-and-Hold Strategy
5. Net Profit: 2,276,000

| No. | Strategies | Net Profit | Profit Factor | Number of Trades | Win Rate | Reward-Risk Ratio | Max Drawdown | Profit for Long Trades | Profit for Short Trades | SQN | Frequency | Remarks |
|:---|:---------------------------|-----------:|----:|------:|---------:|------------------:|-------------:|----------------:|------------------------:|----:|----------:|:--------|
|     1 | Foreign OI                              | 2,665,286    | 1.81            |                 77 | 38.96%     | 2.83                | -1,140,727     | 2,665,286                |                           | 1.69  | 5min        |               |
|     2 | HL Channel Breakout                     | 2,618,212    | 1.61            |                134 | 43.28%     | 2.11                | -957,988       | 2,618,212                |                           | 1.79  | 5min        |               |
|     3 | RSI Trend Following                     | 2,410,562    | 1.97            |                 59 | 40.68%     | 2.88                | -1,032,599     | 2,410,562                |                           | 1.77  | 5min        |               |
|     4 | Basis Trading                           | 3,217,622    | 1.75            |                129 | 42.64%     | 2.35                | -968,102       | 3,217,622                |                           | 2.27  | 5min        |               |
|     5 | TSMC Large Order Flow Strength          | 2,669,477    | 1.7             |                121 | 40.50%     | 2.49                | -958,854       | 2,669,477                |                           | 1.88  | 5min        |               |
|     6 | TW50 Large Order Flow Strength          | 2,888,087    | 1.68            |                116 | 39.66%     | 2.56                | -1,044,272     | 2,888,087                |                           | 1.88  | 5min        |               |
|     7 | TSMC TW50 Large Order Flow Strength     | 2,812,142    | 1.91            |                 69 | 42.03%     | 2.64                | -1,205,420     | 2,812,142                |                           | 1.76  | 5min        |               |
|     8 | Two-Bar Pattern                         | 2,595,942    | 1.95            |                 69 | 40.58%     | 2.85                | -1,034,476     | 2,595,942                |                           | 1.94  | day         |               |
|     9 | DMI with Moving Average                 | 3,472,070    | 1.48            |                565 | 47.08%     | 1.67                | -519,322       | 2,158,790                | 1,313,280                 | 2.55  | 5min        |               |
|    10 | FITE FITF Spread Trading                | 2,989,692    | 1.27            |               1294 | 40.88%     | 1.83                | -539,640       | 3,820,746                | -831,054                  | 1.33  | 30min       |               |
|    11 | Donchian Channel                        | 2,400,006    | 3.96            |                 17 | 52.94%     | 3.52                | -758,087       | 2,400,006                |                           | 1.54  | day         |               |
|    12 | Dual-Timeframe RSI Channel              | 2,360,338    | 1.71            |                191 | 67.54%     | 0.82                | -1,443,866     | 2,360,338                |                           | 2.12  | 5min        |               |
|    13 | Weekly Entry-Exit Strategy              | 2,316,888    | 2.08            |                116 | 68.10%     | 0.97                | -617,174       | 2,316,888                |                           | 3.07  | week        |               |
|    14 | Keltner Channel                         | 2,988,502    | 2.5             |                 89 | 44.94%     | 3.06                | -356,338       | 2,127,202                | 861,300                   | 2.53  | 30min       |               |
|    15 |                                         |              |                 |                  0 |            |                     |                |                          |                           |       |             |               |
|    16 | Bid-Ask Ratio                           | 2,893,779    | 1.75            |                110 | 42.73%     | 2.34                | -1,298,774     | 2,893,779                |                           | 1.88  | 5min        |               |
|    17 | Institutional Options OI                | 2,810,281    | 1.95            |                 99 | 46.46%     | 2.25                | -971,909       | 2,176,701                | 633,580                   | 2.25  | 5min        |               |
|    18 | Ichimoku Cloud Simplified               | 3,601,758    | 1.34            |               1381 | 38.52%     | 2.15                | -485,626       | 2,933,376                | 668,382                   | 2.88  | 20min       | Day and night |
|    19 | Ichimoku Cloud                          | 3,173,394    | 1.23            |               1983 | 39.99%     | 1.85                | -712,474       | 2,558,734                | 614,660                   | 2.59  | 20min       | Day and night |
|    20 | Stochastic Oscillator                   | 2,497,945    | 1.48            |                147 | 43.54%     | 1.91                | -1,730,114     | 2,497,945                |                           | 1.71  | 10min       |               |
|    21 | RSI                                     | 2,895,873    | 1.58            |                143 | 41.26%     | 2.25                | -1,182,675     | 2,895,873                |                           | 1.9   | 5min        |               |
|    22 | RSI Swing Trading                       | 3,754,234    | 2.66            |                 63 | 42.86%     | 3.55                | -703,112       | 3,754,234                |                           | 2.56  | 5min        |               |
|    23 | RSI-KD Intraday Trading                 | 2,766,879    | 1.49            |                160 | 43.75%     | 1.92                | -1,678,497     | 2,766,879                |                           | 1.76  | 5min        |               |
|    24 | MACD Strong Trend Trading               | 3,802,204    | 1.81            |                278 | 42.09%     | 2.49                | -920,040       | 3,281,548                | 520,656                   | 2.25  | 5min        |               |
|    25 | Filtered MACD                           | 3,824,416    | 2.29            |                212 | 46.23%     | 2.66                | -387,522       | 2,661,220                | 1,163,196                 | 3.2   | 5min        |               |
|    26 | Commodity Channel Index                 | 3,868,600    | 3.41            |                 85 | 63.53%     | 1.96                | 396,400        | 3,287,400                | 581,200                   | 2.91  | day         | Python        |
|    27 |                                         |              |                 |                  0 |            |                     |                |                          |                           |       |             |               |
|    28 | Directional Movement Index              | 3,149,984    | 1.43            |                388 | 43.30%     | 1.88                | -853,412       | 2,170,448                | 979,536                   | 2.15  | 5min        |               |
|    29 | Filtered DMI Trading System             | 2,911,136    | 2.69            |                 52 | 51.92%     | 2.49                | -482,369       | 2,389,222                | 521,914                   | 2.09  | 10min       |               |
|    30 | Momentum                                | 3,084,314    | 2.1             |                223 | 65.92%     | 1.09                | -359,564       | 3,084,314                |                           | 3.76  | 15min       |               |
|    31 |                                         |              |                 |                  0 |            |                     |                |                          |                           |       |             |               |
|    32 | Williams                                | 2,044,126    | 1.21            |               1157 | 59.46%     | 0.83                | -770,957       | 1,631,640                | 412,486                   | 1.64  | 10min       |               |
|    33 |                                         |              |                 |                  0 |            |                     |                |                          |                           |       |             |               |
|    34 | CDP Intraday Trading                    | 2,537,046    | 1.53            |                197 | 61.93%     | 0.94                | -1,110,912     | 1,793,266                | 743,780                   | 1.88  | 10min       |               |
|    35 |                                         |              |                 |                  0 |            |                     |                |                          |                           |       |             |               |
|    36 | Turtle Trading Rules                    | 2,684,884    | 2.22            |                 38 | 36.84%     | 3.81                | -1,075,656     | 2,564,242                | 120,642                   | 1.18  | day         |               |
|    37 | High Low Channel with Moving Average    | 2,501,630    | 1.96            |                 85 | 36.47%     | 3.42                | -1,550,040     | 2,408,238                | 93,392                    | 2.0   | day         |               |
|    38 | LWBO (Larry Williams Breakout)          | 2,987,550    | 1.73            |                125 | 44.00%     | 2.2                 | -728,420       | 2,785,234                | 202,316                   | 2.06  | 5min        |               |
|    39 | OpenBO                                  | 2,922,842    | 1.36            |                419 | 40.57%     | 2.0                 | -1,002,716     | 2,587,278                | 335,564                   | 1.94  | 5min        |               |
|    40 | HLBO                                    | 3,362,966    | 1.88            |                137 | 45.99%     | 2.21                | -796,080       | 2,637,058                | 725,908                   | 2.31  | 5min        |               |
|    41 | Aberration Swing Trading                | 2,809,332    | 2.77            |                 74 | 37.84%     | 4.54                | -758,271       | 2,809,332                |                           | 2.61  | hour        |               |
|    42 | ABS Swing Trading                       | 2,885,640    | 1.83            |                 80 | 40.00%     | 2.74                | -1,178,107     | 2,885,640                |                           | 1.81  | 10min       |               |
|    43 | Gap Large Volume Strategy               | 2,363,650    | 2.53            |                 75 | 42.67%     | 3.4                 | -643,322       | 2,167,884                | 195,766                   | 2.15  | 5min        |               |
|    44 | Contrarian Bollinger Band Strategy      | 2,719,086    | 1.63            |                277 | 70.76%     | 0.68                | -782,728       | 2,719,086                |                           | 2.72  | 15min       |               |
|    45 | Volume Ratio and Bid-Ask Ratio          | 2,435,616    | 1.7             |                112 | 44.64%     | 2.1                 | -499,692       | 1,908,044                | 527,572                   | 1.95  | 5min        |               |
|    46 | VWMA Crossing Strategy                  | 2,427,910    | 1.77            |                345 | 33.33%     | 3.54                | -421,317       | 1,711,570                | 716,340                   | 2.59  | 20min       |               |
|    47 | ATR Channel Breakout                    | 4,015,298    | 9.0             |                 11 | 63.64%     | 5.14                | -867,882       | 3,318,108                | 697,190                   | 1.9   | day         |               |
|    48 | Midline Breakout                        | 3,142,890    | 1.65            |                155 | 44.52%     | 2.06                | -913,439       | 3,142,890                |                           | 2.09  | 5min        |               |
|    49 | High Low Channel with Trailing Stoploss | 2,654,234    | 1.94            |                 63 | 42.86%     | 2.58                | -1,069,302     | 2,032,812                | 621,422                   | 1.69  | day         |               |
|    50 | Momentum 2                              | 2,519,104    | 2.49            |                128 | 60.94%     | 1.6                 | -482,856       | 2,519,104                |                           | 3.25  | 15min       |               |
|    51 | CCI Crossing Strategy                   | 4,461,582    | 1.99            |                149 | 42.95%     | 2.65                | -999,030       | 3,389,680                | 1,071,902                 | 2.78  | 15min       |               |
|    52 | AO_1                    | 5,885,066    | 2.33            |                187 | 47.59%     | 2.56                | -724,168       | 4,124,924                | 1,760,142                 | 3.77  | 10min       |               |
|    53 | AO_3                    | 5,549,364    | 2.65            |                 98 | 45.92%     | 3.12                | -553,292       | 4,135,310                | 1,414,054                 | 3.41  | 5min        |               |
|    54 | ROCEMA                                  | 3,072,276    | 2.76            |                 82 | 48.78%     | 2.89                | -691,466       | 2,227,304                | 844,972                   | 2.55  | 20min       |               |
|    55 | Momentum Surge Strategy                 | 3,783,038    | 2.07            |                141 | 47.52%     | 2.29                | -433,076       | 3,007,820                | 775,218                   | 2.47  | 20min       |               |

## Derivatives Pricing
  1. Black–Scholes–Merton Model
  2. Binomial Trees
  3. Binomial Trees Alternative Procedure
  4. Trinomial Trees
  5. Trinomial Trees Alternative Procedure
  6. Implicit Finite Difference Method (R, MATLAB)
  7. Explicit Finite Difference Method (R, MATLAB, Python, C++)
  8. Control Variate Technique for European Call
  9. Calculate implied hazard rate from market CDS spread
  10. VaR of a four-index portfolio
  11. RiskMetrics' lambda
  12. Variance-Gamma Model
  13. Vasicek Model
  14. Vasieck / CIR / CKLS
  15. Constant Elasticity of Variance (CEV) Model
  16. Vasicek Worst Case Default Rate
  17. Asian Options
  18. Simulate Heston Model / Rough Heston / Heston Closed-Form Solution for Call Options
  19. Zero rate bootstrap (OOP S4 and R6)
  20. Valuation of a Synthetic CDO (include Gauss-Hermite quadrature)
  21. Valuation of kth-to-Default CDS (R, Python)
  22. Imply correlation from the market quotes for CDO tranches (Compound correlation and Base correlation)
  23. Static options replication for an up-and-out call (include all Barrier options analytic formulae)
  24. Kou, S. (2002). Jump diffusion model for option pricing
  25. Longstaff and Schwartz (2001), Least-Squares Approach
## Time Series
  1. Simulate and Estimate GARCH(1,1) without using packages
  2. Simulate and Estimate EGARCH(1,1) without using packages
  3. Simulate Autoregressive Conditional Duration (ACD) Model
  4. Apply Autoregressive Conditional Duration (ACD) Model to the range of stock price
  5. Conditional Heteroscedastic ARMA (CHARMA) Model
  6. Time-Varying Correlation (Univariate GARCH)
  7. Time-Varying CAPM (Univariate GARCH and State Space Modelling)
  8. Multivariate Volatility Models
     * EWMA
     * DVEC
     * BEKK, Diagonal BEKK
     * Constant Correlation Model
     * Time-Varying Correlation Models
     * Time-Varying Correlation Models (Cholesky Reparameterization)
     * Dynamic Conditional Correlation Models
     * Factor Volatility Model
  9. Asymptotic Principal Component Analysis
  10. Smooth Transition AR (STAR) Model (Various optimization methods)
  11. Statistical Arbitrage Pairs Trading (Cointegration)
  12. Stochastic Volatility
      * State-Space Modelling
      * Markov Chain Monte Carlo
  13. Gibbs Sampling for parameters of linear regression with AR(2) errors
  14. Portfolio strategies (Shrinkage GMV, Sparse-hedging approach)
## Corporate Finance (Work in progress)
  1. Calculation of Crash Risk Measures
  2. Calculation of Organizational Capital
  3. Estimation of Discretionary Accruals (Modified Jones Model and Leave-One-Out Regression)
## Others
   * Prediction of TSMC Price (Python, undergraduate ML course project)
