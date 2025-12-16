#%% load modules
from backtesting import Backtest
import pandas as pd
from USStrategy import USStrategy
from USStrategy_prepare_df import prepare_df
#%% functions
def gen_df_trade(trades, df):
    trades=trades[['Size', 'EntryBar', 'ExitBar', 'EntryPrice', 'ExitPrice', 'PnL']].rename(columns={
                   "Size": "type",
                   "PnL": 'Profit or loss'
            })
    trades['type'] = trades['type'].replace({200: 'long', -200: 'short'})
    trades['EntryPrice'] = trades['EntryPrice'].astype(int)
    
    df = df.copy()
    df = df.reset_index()[['datetime', 'DJI', 'GSPC', 'IXIC', 'SOX', 'TSM']].assign(EntryBar=range(0, len(df)))
    df['date'] = df['datetime'].dt.date
    df['time'] = df['datetime'].dt.strftime('%H%M').astype(int)
    df.drop(columns=['datetime'], inplace=True)
    df[['DJI', 'GSPC', 'IXIC', 'SOX', 'TSM']] = df[['DJI', 'GSPC', 'IXIC', 'SOX', 'TSM']].map(lambda x: f"{x*100:.0f}%")
    
    trades = pd.merge(trades, df, on='EntryBar', how='inner')
    trades = trades[['date', 'time', 'type', 'EntryPrice', 'ExitPrice', 'Profit or loss', 'DJI', 'GSPC', 'IXIC', 'SOX', 'TSM', 'EntryBar', 'ExitBar']]
    return trades

#%% bt
df = prepare_df()

cash = 1_000_000
bt = Backtest(df, USStrategy,
              cash=cash,
              margin=1/16,
              # commission=0.002,
              trade_on_close=True,
              finalize_trades=True)
#%% try
stats = bt.run()
print(stats)
trades = gen_df_trade(stats['_trades'], df)
print(trades)
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

x = [2,3,4] # frange(0.5, 4+0.1, 0.5) # 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4
param_grid = {
    "dji_ret" : x,
    "gspc_ret" : x,
    "ixic_ret" : x,
    "sox_ret" : x,
    "tsm_ret" : x,
    "stoploss_pct": [1,2,3],
    "entry_time" : [850, 905, 915] # [845, 850, 900, 905, 910, 915]
}

best_equity, best_params = optimize_multi_parallel(bt, param_grid).values()
print('\nBest parameters:\n', best_params)
#%% best parameters
stats = bt.run(**best_params)
print(stats)
trades = gen_df_trade(stats['_trades'], df)
print(trades)
print(f"\nNet profit= {stats['Equity Final [$]']-cash:,.0f}")