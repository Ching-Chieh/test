#%% load modules
from backtesting import Backtest
import pandas as pd
from Turtle_trading import Turtle_trading_strategy
#%% functions
def prepare_df(df):
    df["date"] = pd.to_datetime(df['date'], format='%Y%m%d')
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
df = pd.read_excel("day_data_FITX_1.TF.xlsx", usecols=range(5)) # 20190102 ~ 20251031
df = prepare_df(df) # 回測起始日期: 20210601

cash = 1_000_000_000
bt = Backtest(df, Turtle_trading_strategy,
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
    "entry_high_period": range(5, 100+1, 5),
    "entry_low_period": range(5, 100+1, 5),
    "exit_high_period": range(3, 80+1, 5),
    "exit_low_period": range(3, 80+1, 5),
}

print(len(list(product(*param_grid.values()))))
#%%
best_equity, best_params = optimize_multi_parallel(bt, param_grid).values()
print('\nBest parameters:\n', best_params)
print(f"Net profit= {best_equity-cash:,.0f}")
#%% sambo
stats, heatmap, optimize_result = bt.optimize(
    entry_high_period=[5, 100],
    entry_low_period=[5, 100],
    exit_high_period=[3, 80],
    exit_low_period=[3, 80],
    constraint=lambda p: (p.entry_high_period > p.exit_high_period) and (p.entry_low_period > p.exit_low_period),
    maximize='Equity Final [$]',
    method='sambo',
    max_tries=1000,
    random_state=0,
    return_heatmap=True,
    return_optimization=True)
#%% best parameters
stats = bt.run(entry_high_period = 5, entry_low_period = 38, exit_high_period = 3, exit_low_period = 37)
print("\nNumber of trades=", len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
