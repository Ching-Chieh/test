#%% load modules
from backtesting import Backtest
import pandas as pd
from RSI import RSIStrategy
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

def generate_df_trades(trades):
    trades=trades[['Size', 'EntryBar', 'ExitBar', 'EntryPrice', 'ExitPrice', 'Entry_rsi', 'PnL']].rename(columns={
                   "Size": "type",
                   "Entry_rsi": "RSI",
                   "PnL": 'Profit or loss'
            })
    trades['type'] = trades['type'].replace({200: 'long', -200: 'short'})
    trades=trades.merge(df[['date', 'time']].assign(EntryBar=range(len(df))), on='EntryBar', how='inner')
    trades=trades[['type', 'date', 'time', 'EntryPrice', 'RSI', 'Profit or loss', 'ExitPrice', 'EntryBar', 'ExitBar']]
    trades['RSI'] = trades['RSI'].round(1)
    return trades

#%% bt
df = pd.read_csv("long_5min_data_FITX_1.TF.log", sep=" ", usecols=range(6)) # 20190102 845 ~ 20251031 1340
df = prepare_df(df)
df = df[df.index > '2021-04-01'] # 回測起始日期: 20210601

cash = 1_000_000_000
bt = Backtest(df, RSIStrategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% try
stats = bt.run()
print('\nNumber of trades=', len(stats['_trades']))
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

def frange(start, stop, step):
    numbers = []
    current = start
    while current < stop:
        numbers.append(current)
        current += step
    return numbers

param_grid = {
    "rsi_high": range(65, 85+1, 5),       # 65, 70, 75, 80, 85
    # "rsi_low": range(20, 40+1, 5),        # 20, 25, 30, 35, 40
    "rsi_window": range(10, 18+1, 2),     # 10, 12, 14, 16, 18
    "stoploss_pct": frange(1, 3+0.1, 0.5) # 1, 1.5, 2, 2.5, 3
}

best_equity, best_params = optimize_multi_parallel(bt, param_grid).values()
print(f"\nNet profit= {best_equity-cash:,.0f}")
print('\nBest parameters:\n', best_params)
#%% best parameters
stats = bt.run(rsi_high = 75, # rsi_low = 30,
               rsi_window = 18, stoploss_pct = 3)
print('\nNumber of trades=', len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
