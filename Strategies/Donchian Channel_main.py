#%% load modules
from backtesting import Backtest
import pandas as pd
from Donchian_Channel import Donchian_Channel_Strategy
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
df = pd.read_excel("day_data_FITX_1.TF.xlsx")
df = prepare_df(df)

cash = 1_000_000_000
bt = Backtest(df, Donchian_Channel_Strategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% try
stats = bt.run()
print(f"\nNet profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% optimize
# stats = bt.optimize(adx_value=range(10, 40+1, 2),
#                     ma_short=range(5, 40+1, 5),
#                     ma_long=range(10, 60+1, 5),
#                     maximize='Equity Final [$]',
#                     constraint=lambda param: param.ma_short < param.ma_long)
# print(f"\nNet profit= {stats['Equity Final [$]']-cash:,.0f}")
# print(stats._strategy)
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

param_grid = {
    "n_long": range(6, 80+1, 2),
    "n_short": range(4, 70+1, 2)
}

best_equity, best_params = optimize_multi_parallel(bt, param_grid).values()
print('\nBest parameters:\n', best_params)
print(f"\nNet profit= {best_equity-cash:,.0f}")
#%% best_params
# stats = bt.run(**best_params)
# stats = bt.run(n_long = best_params['n_long'],   # 20
               # n_short = best_params['n_short']) # 16
stats = bt.run(n_long = 20, n_short = 16)
print(f"\nNet profit= {stats['Equity Final [$]']-cash:,.0f}")
