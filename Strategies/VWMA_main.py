#%% load modules
from backtesting import Backtest
import pandas as pd
from VWMA import VWMA_Strategy
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
bt = Backtest(df, VWMA_Strategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% try
stats = bt.run()
print(f"\nNet profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% optimize_multi_parallel
from itertools import product
from joblib import Parallel, delayed
from tqdm import tqdm

def optimize_multi_parallel(bt, param_grid, n_jobs=-1): # -1: use all CPUs
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
        return None

    best_equity, best_params = max(results, key=lambda x: x[0])
    return {"best_equity": best_equity, "best_params": best_params}

def frange(start, stop, step):
    numbers = []
    current = start
    while current < stop:
        numbers.append(current)
        current += step
    return numbers

param_grid = {
    "ma_short": [5] + list(range(6, 60+1, 2)),
    "ma_long": range(10, 80+1, 2),
}

best_equity, best_params = optimize_multi_parallel(bt, param_grid).values()
print('\nBest parameters:\n', best_params)
print(f"\nNet profit= {best_equity-cash:,.0f}")
#%% best_params
# stats = bt.run(**best_params)
stats = bt.run(ma_short = best_params['ma_short'],   # 8
               ma_long = best_params['ma_long'])     # 12
print(f"\nNet profit= {stats['Equity Final [$]']-cash:,.0f}")
