#%% load modules
from backtesting import Backtest
import pandas as pd
from LWBO import LWBO_strategy
#%% functions
def prepare_df(df):
    df = df.rename(columns={
        "open": "Open",
        "high": "High",
        "low": "Low",
        "close": "Close"
    })
    
    # daily
    daily = df.groupby('date').agg({
        'High': 'max',
        'Low':  'min'
    })
    daily.reset_index(drop=False, inplace=True)
    daily['dailyrange_lastday'] = (daily['High'] - daily['Low']).shift(1)
    
    # merge
    df = df.merge(daily[['date', 'dailyrange_lastday']], how='left', on='date')
    df["datetime"] = pd.to_datetime(
        df["date"].astype(str) + df["time"].astype(str).str.zfill(4), format="%Y%m%d%H%M"
    )
    df = df.set_index("datetime")
    df.sort_index(inplace=True)
    
    return df[["date", "time", "Open", "High", "Low", "Close", "dailyrange_lastday"]]
#%% bt
df = pd.read_csv("5min_data_FITX_1.TF.log", sep=" ", usecols=range(6)) # 20190102 845 ~ 20251031 1340
df = prepare_df(df)
df = df[df.index > '2021-04-01'] # 回測起始日期: 20210601

cash = 1_000_000_000
bt = Backtest(df, LWBO_strategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% try
stats = bt.run()
print("\nNumber of trades=", len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% optimize_multi_parallel
from itertools import product
from joblib import Parallel, delayed
from tqdm import tqdm

def optimize_multi_parallel(bt, param_grid, n_jobs=-1):
    keys = list(param_grid.keys())
    values = list(param_grid.values())

    def run_bt(params):
        try:
            stats = bt.run(**params)
            if stats['_trades'].empty:
                return None
            equity = stats['Equity Final [$]']
            return equity, params
        except Exception as e:
            print(f"Skipping {params} due to error: {e}")
            return None

    combos = [dict(zip(keys, combo)) for combo in product(*values)]
    results = Parallel(n_jobs=n_jobs)(delayed(run_bt)(params) for params in tqdm(combos, desc="Optimizing", ncols=100))
    results = [r for r in results if r is not None]

    if not results:
        print("No valid parameter combination produced trades.")
        return {"best_equity": None, "best_params": None}

    best_equity, best_params = max(results, key=lambda x: x[0])
    return {"best_equity": best_equity, "best_params": best_params}

import numpy as np
param_grid = {
    "stoploss_pct_long": np.arange(0.5, 3+0.001, 0.5).round(1).tolist(),
    "stoploss_pct_short": np.arange(0.5, 3+0.001, 0.5).round(1).tolist(),
    "mult": np.arange(0.1, 2.9+0.001, 0.4).round(1).tolist(),
    "daily_high_low_time": range(905, 945+1, 5),
    # "_short": [True, False]
}
print(len(list(product(*param_grid.values()))))
best_equity, best_params = optimize_multi_parallel(bt, param_grid).values()
print('\nBest parameters:\n', best_params)
print(f"Net profit= {best_equity-cash:,.0f}")
#%% sambo
stats, heatmap, optimize_result = bt.optimize(
    stoploss_pct_long=[0.5, 3],
    stoploss_pct_short=[0.5, 3],
    mult=[0.1, 2.9],
    constraint=lambda p: p.short_period < p.long_period,
    maximize='Equity Final [$]',
    method='sambo',
    max_tries=600,
    random_state=0,
    return_heatmap=True,
    return_optimization=True)
#%% best parameters
stats = bt.run(stoploss_pct_long = 2, stoploss_pct_short = 3, mult = 0.1, daily_high_low_time = 905)
print("\nNumber of trades=", len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
