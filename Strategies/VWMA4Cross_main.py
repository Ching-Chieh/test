#%% load modules
from backtesting import Backtest
import pandas as pd
from VWMA4Cross import VWMA4Cross_Strategy
#%% functions
def prepare_df(df):
    df["datetime"] = pd.to_datetime(
        df["date"].astype(str) + df["time"].astype(str).str.zfill(4), format="%Y%m%d%H%M"
    )

    df = df.set_index("datetime")
    df.sort_index(inplace=True)
    df = df.rename(columns={
        "open": "Open",
        "high": "High",
        "low": "Low",
        "close": "Close",
        "volume": "Volume"
    })

    return df[["date", "time", "Open", "High", "Low", "Close", "Volume"]]
#%% bt
df = pd.read_csv("20min_data_FITX_1.TF.log", sep=" ", usecols=range(7))
df = prepare_df(df)
df = df[df.index > '2021-04-01']

cash = 1_000_000_000
bt = Backtest(df, VWMA4Cross_Strategy,
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

param_grid = {
    "short_period": [5] + list(range(10, 60+1, 10)),
    "long_period": range(10, 70+1, 5),
    "enter_period": range(5, 70+1, 5),
    "exit_period": range(5, 70+1, 5)
}

best_equity, best_params = optimize_multi_parallel(bt, param_grid).values()
print('\nBest parameters:\n', best_params)
print(f"\nNet profit= {best_equity-cash:,.0f}")
#%% sambo
stats, heatmap, optimize_result = bt.optimize(
    short_period=[5, 60],
    long_period=[5, 70],
    enter_period=[5, 70],
    exit_period=[5, 70],
    constraint=lambda p: p.short_period < p.long_period,
    maximize='Equity Final [$]',
    method='sambo',
    max_tries=600,
    random_state=0,
    return_heatmap=True,
    return_optimization=True)
#%%
print(optimize_result)
print(heatmap.sort_values().iloc[-3:])
#%% best_params
stats = bt.run(short_period = 60,
               long_period = 70,
               enter_period = 47,
               exit_period = 45)
print("\nNumber of trades=", len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")