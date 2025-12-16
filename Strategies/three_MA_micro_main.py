#%% load modules
from backtesting import Backtest
import pandas as pd
from three_MA_micro import three_MA_Strategy
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
        "close": "Close"
    })

    return df[["date", "time", "Open", "High", "Low", "Close"]]
#%% bt
df = pd.read_csv("10min_data_FITMN_1.TF.log", sep=" ", usecols=range(6)) # 有夜盤 20240729 845 ~ 20251121 1335
df = prepare_df(df)
# df = df[df.index > '2025-03-01'] # 回測起點 日期: 20240901

cash = 1_000_000_000
bt = Backtest(df, three_MA_Strategy,
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
    "ma_s": range(5, 25+1, 5),
    "ma_m": range(10, 65+1, 5),
    "ma_l": range(15, 85+1, 5),
}
print(len(list(product(*param_grid.values()))))
best_equity, best_params = optimize_multi_parallel(bt, param_grid).values()
print('\nBest parameters:\n', best_params)
print(f"\nNet profit= {best_equity-cash:,.0f}")
#%% best_params
# stats = bt.run(**best_params)
stats = bt.run(ma_s = best_params['ma_s'], # 5
               ma_m = best_params['ma_m'],  # 25
               ma_l = best_params['ma_l'])   # 30
stats = bt.run(ma_s = 5, ma_m = 25, ma_l = 30)
print(f"\nNet profit= {stats['Equity Final [$]']-cash:,.0f}")
