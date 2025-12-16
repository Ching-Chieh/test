#%% load modules
from backtesting import Backtest
import pandas as pd
from HL_passage_MA import HL_passage_MA_strategy
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
bt = Backtest(df, HL_passage_MA_strategy,
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
    "high_period": list(range(3, 19+1, 2)),
    "low_period": list(range(3, 19+1, 2)),
    "long_exit_ma_period": [5] + list(range(10, 50+1, 10)),
    "short_exit_ma_period": [5] + list(range(10, 50+1, 10)),
}

print(len(list(product(*param_grid.values()))))
best_equity, best_params = optimize_multi_parallel(bt, param_grid).values()
print('\nBest parameters:\n', best_params)
print(f"Net profit= {best_equity-cash:,.0f}")
#%% sambo
stats, heatmap, optimize_result = bt.optimize(
    high_period=[3, 20],
    low_period=[3, 20],
    long_exit_ma_period=[5, 50],
    short_exit_ma_period=[5, 50],
    # constraint=lambda p: p.n_exit < p.n_enter < p.n1 < p.n2,
    maximize='Equity Final [$]',
    method='sambo',
    max_tries=1000,
    random_state=0,
    return_heatmap=True,
    return_optimization=True)
#%% best parameters
stats = bt.run(high_period = 5, low_period = 3, long_exit_ma_period = 20, short_exit_ma_period = 20)
print("\nNumber of trades=", len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
