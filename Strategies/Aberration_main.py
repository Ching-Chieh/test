#%% load modules
from backtesting import Backtest
import pandas as pd
from Aberration import AberrationStrategy
#%% df
def prepare_df():
    df = pd.read_csv("1h_data_FITX_1.TF.log", sep=" ", usecols=range(6))
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
    return df  # 'date', 'time', 'Open', 'High', 'Low', 'Close'

df = prepare_df()
df = df[df.index > '2021-01-01']
#%% bt 
cash = 1_000_000_000
bt = Backtest(df, AberrationStrategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% try 
stats = bt.run()
print(stats)
print(f"\nNet profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% gen_df_trade()
def gen_df_trade(trades, df):
    trades=trades[['Size', 'EntryPrice', 'ExitPrice', 'PnL',
                   'Entry_compute_b…(60,30,1)_0', 'Entry_compute_b…(60,30,1)_1', 'Entry_compute_b…(60,30,1)_2',
                   'EntryBar', 'ExitBar']].rename(columns={
                    "Size": "type",
                    "PnL": 'Profit or loss',
                    'Entry_compute_b…(60,30,1)_0': 'middle',
                    'Entry_compute_b…(60,30,1)_1': 'upper',
                    'Entry_compute_b…(60,30,1)_2': 'lower',
            })
    trades['type'] = trades['type'].replace({200: 'long', -200: 'short'})
    trades[['EntryPrice', 'Profit or loss']] = trades[['EntryPrice', 'Profit or loss']].astype(int)
    
    df = df.copy().reset_index(drop=True)[['date', 'time']].assign(EntryBar=range(0, len(df)))
    trades = pd.merge(trades, df, on='EntryBar', how='inner')
    trades = trades[['type', 'date', 'time',
                     'EntryPrice', 'ExitPrice', 'Profit or loss',
                     'upper', 'middle', 'lower',
                     'EntryBar', 'ExitBar']]
    return trades
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
    "take_profit_pct" : frange(1, 3+0.1, 0.5),
    "profit_drawback_pct" : frange(0.2, 2.6+0.1, 0.4),
    "middle_ma_n" : range(10, 60+1, 10),
    "sd_n" : range(5, 30+1, 5), # 標準差期數
    "sd_m" : [0.5, 1, 2, 3],  # 標準差倍數
}

best_equity, best_params = optimize_multi_parallel(bt, param_grid).values()
print('\nBest parameters:\n', best_params)
print(f"\nNet profit= {best_equity-cash:,.0f}")
#%%
# stats = bt.run(**best_params)
stats = bt.run(take_profit_pct= 2.5,
               profit_drawback_pct= 2.2,
               middle_ma_n= 60,
               sd_n= 30,
               sd_m= 1,
               )
print(f"\nNet profit= {stats['Equity Final [$]']-cash:,.0f}")
trades = gen_df_trade(stats['_trades'], df)
print(trades)