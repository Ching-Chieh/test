#%% load modules
from backtesting import Backtest
import pandas as pd
from spread import Spread_Strategy
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

    return df[["date", "time", "Open", "High", "Low", "Close", "close_TSE"]]
def gen_df_trade(trades):
    trades=trades[['Size', 'EntryBar', 'ExitBar', 'EntryPrice', 'ExitPrice', 'Entry_cal_spread', 'PnL']].rename(columns={
                   "Size": "type",
                   "Entry_cal_spread": "spread",
                   "PnL": "Profit or loss"
            })
    trades['type'] = trades['type'].replace({200: 'long', -200: 'short'})
    trades=pd.merge(trades, df[['date', 'time']].assign(EntryBar=range(0, len(df))), on='EntryBar', how='inner')
    trades=trades[['type', 'date', 'time', 'EntryPrice', 'ExitPrice', 'spread', 'Profit or loss', 'EntryBar', 'ExitBar']]
    # trades[['', '']] = trades[['', '']].apply(lambda x: x.round(1))
    return trades
#%% bt
df = pd.read_csv("5min_期現貨價差交易data.log", sep=" ", usecols=range(7)) # 20210528 1025 ~ 20251031 1340
df = prepare_df(df)     # 回測起點 日期: 20210601

cash = 1_000_000_000
bt = Backtest(df, Spread_Strategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% try
# stats = bt.run()
# print("\nNumber of trades:", len(stats['_trades']))
# print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
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
        return {"best_equity": None, "best_params": None}

    best_equity, best_params = max(results, key=lambda x: x[0])
    return {"best_equity": best_equity, "best_params": best_params}

import numpy as np
param_grid = {
    "spread_param": range(-400, 400+1, 5),
    "stoploss_pct": np.arange(0.4, 4+0.001, 0.4).tolist() # [0.4, 0.8, 1.2, 1.6, 2, 2.4, 2.8, 3.2, 3.6, 4]
}
print(len(list(product(*param_grid.values()))))
best_equity, best_params = optimize_multi_parallel(bt, param_grid).values()
print('\nBest parameters:\n', best_params)
print(f"\nNet profit= {best_equity-cash:,.0f}")
#%% best_params
# stats = bt.run(**best_params)
stats = bt.run(spread_param = -115, stoploss_pct = 2)
print(f"\nNet profit= {stats['Equity Final [$]']-cash:,.0f}") # 2,903,600
