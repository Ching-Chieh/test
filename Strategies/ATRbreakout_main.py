#%% load modules
from backtesting import Backtest
import pandas as pd
from ATRbreakout import ATR_breakout_Strategy
#%% functions
def prepare_df(df):
    df["date"] = pd.to_datetime(df["date"].astype(str), format="%Y%m%d")
    df = df.set_index("date")
    df.sort_index(inplace=True)
    df = df.rename(columns={
        "open": "Open",
        "high": "High",
        "low": "Low",
        "close": "Close"
    })

    return df[["Open", "High", "Low", "Close"]]
#%% bt
df = pd.read_excel("day_data_FITX_1.TF.xlsx") # 20190102 ~ 20251031
df = prepare_df(df) # 20210601 回測起點 日期

cash = 1_000_000_000
bt = Backtest(df, ATR_breakout_Strategy,
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
        return None

    best_equity, best_params = max(results, key=lambda x: x[0])
    return {"best_equity": best_equity, "best_params": best_params}

param_grid = {
    "sma_period": [5, 10, 20, 30, 40, 50, 60],
    "atr_period": [5, 10, 20, 30, 40, 50, 60],
    "upper_mult": [1,2,3,4,5],
    "lower_mult": [1,2,3,4,5]
}
print(len(list(product(*param_grid.values()))))
best_equity, best_params = optimize_multi_parallel(bt, param_grid).values()
print('\nBest parameters:\n', best_params)
print(f"\nNet profit= {best_equity-cash:,.0f}")
#%% best_params
stats = bt.run(sma_period = 10, atr_period = 54, upper_mult = 2, lower_mult = 3)
print(f"\nNet profit= {stats['Equity Final [$]']-cash:,.0f}")
