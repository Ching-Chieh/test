#%%
from backtesting import Backtest
from MultiTF_MA import MultiTF_MA_Strategy_function
import pandas as pd

def load_csv(filepath):
    df = pd.read_csv(filepath, sep=" ", usecols=range(7))
    df["date"] = df["date"].astype(str)
    df["date"] = pd.to_datetime(df["date"], format="%Y%m%d")
    df["datetime"] = df["date"] + pd.to_timedelta(df["h"], unit="h") + pd.to_timedelta(df["m"], unit="m")
    return df[['datetime', 'open', 'high', 'low', 'close']]

df10 = load_csv("data_10min_FITX_1.TF.log")\
    .rename(columns={'open': 'Open', 'high': 'High', 'low': 'Low', 'close': 'Close'})\
    .set_index('datetime') # datetime index, Open, High, Low, Close
df10 = df10[df10.index > '2021-04-01']
print(len(df10))

df60 = load_csv("data_60min_FITX_1.TF.log") # datetime, open, high, low, close
df60 = df60[df60['datetime'] > '2021-01-01']
print(len(df60))
#%%
cash = 1_000_000_000
strategy = MultiTF_MA_Strategy_function(df60)
bt = Backtest(df10, strategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% try
stats = bt.run()
print("\nNumber of trades:", len(stats['_trades']))
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

param_grid = {
    "fast10": range(10, 50+1, 10),
    "slow10": range(10, 80+1, 10),
    "fast60": range(10, 50+1, 10),
    "slow60": range(10, 80+1, 10)
}
print(len(list(product(*param_grid.values()))))
best_equity, best_params = optimize_multi_parallel(bt, param_grid).values()
print('\nBest parameters:\n', best_params)
print(f"\nNet profit= {best_equity-cash:,.0f}")
#%% sambo
stats, heatmap, optimize_result = bt.optimize(
    fast10=[10, 50],
    slow10=[10, 80],
    fast60=[10, 50],
    slow60=[10, 80],
    constraint=lambda p: (p.fast10 < p.slow10) and (p.fast60 < p.slow60),
    maximize='Equity Final [$]',
    method='sambo',
    max_tries=40,
    random_state=0,
    return_heatmap=True,
    return_optimization=True)
#%% best_params
stats = bt.run(fast10 = , slow10 = , fast60 =  , slow60 = )
print("\nNumber of trades:", len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
