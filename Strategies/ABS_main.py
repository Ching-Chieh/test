#%% load modules
from backtesting import Backtest
import pandas as pd
from ABS import ABSStrategy

def prepare_df():
    df = pd.read_csv("long_10min_data_FITX_1.TF.log", sep=" ", usecols=range(6))
    df["datetime"] = pd.to_datetime(df["date"].astype(str) + df["time"].astype(str).str.zfill(4), format="%Y%m%d%H%M")
    df = df.set_index("datetime")
    df.sort_index(inplace=True)
    df[['open', 'high', 'low', 'close']] = df[['open', 'high', 'low', 'close']].astype("float64")
    df.rename(columns={
        "open": "Open",
        "high": "High",
        "low": "Low",
        "close": "Close"
    }, inplace=True)
    return df

df = prepare_df()
df = df[df.index > '2021-04-01']
#%% bt 
cash = 10_000_000_000
bt = Backtest(df, ABSStrategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% try 
# stats = bt.run()
# print(stats)
# def gen_df_trade(trades, df):
#     trades=trades[['Size', 'EntryBar', 'ExitBar', 'EntryPrice', 'ExitPrice', 'PnL', 'Entry_SMA(O,20)']].rename(columns={
#                     "Size": "type",
#                     "PnL": 'Profit or loss',
#                     'Entry_SMA(O,20)': 'sma'
#             })
#     trades['type'] = trades['type'].replace({200: 'long', -200: 'short'})
#     trades[['EntryPrice', 'Profit or loss']] = trades[['EntryPrice', 'Profit or loss']].astype(int)
    
#     df = df.copy().reset_index(drop=True)[['date', 'time']].assign(EntryBar=range(0, len(df)))
#     trades = pd.merge(trades, df, on='EntryBar', how='inner')
#     trades = trades[['type', 'date', 'time', 'EntryPrice', 'ExitPrice', 'Profit or loss', 'sma']]
#     return trades

# trades = gen_df_trade(stats['_trades'], df)
# print(trades)
# print(f"\nNet profit= {stats['Equity Final [$]']-cash:,.0f}")
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

    results = Parallel(n_jobs=n_jobs)(
        delayed(run_bt)(params) for params in tqdm(combos, desc="Optimizing", ncols=100)
    )

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
    "ma_n" : [5, 7, 9], # [5, 10, 15, 20, 25, 30],
    "n" : [5,9,11,13],
    "k_period" : [4,5],
    "d_period" : [4,5],
    "d_threshold" : [40], # [40, 50, 60, 70],
    "stoploss_pct": [1, 2, 3]
}

best_equity, best_params = optimize_multi_parallel(bt, param_grid).values()
print('\nBest parameters:\n', best_params)
print(f"\nNet profit= {best_equity-cash:,.0f}")
