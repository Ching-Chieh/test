#%% load modules
from backtesting import Backtest
import pandas as pd
from Multi_RSI import Multi_RSI_strategy
#%% functions
def plus5(time):
    h = time // 100
    m = time % 100
    m = m + 5
    if m == 60:
        m -= 60
        h += 1
    return h*100 + m

def time_to_freq(series, frequency):
    min845 = 8 * 60 + 45
    min850 = 8 * 60 + 50
    h = series // 100
    m = series % 100
    total_min = h * 60 + m
    t2 = ((total_min - min850) // frequency + 1) * frequency + min845

    return (t2 // 60) * 100 + (t2 % 60)

def prepare_df(df):
    df['time'] = df['time'].map(plus5)
    df.rename(columns={'time': 'time5'}, inplace=True)
    
    df["datetime"] = pd.to_datetime(
        df["date"].astype(str) + df["time5"].astype(str).str.zfill(4), format="%Y%m%d%H%M"
    )

    df = df.set_index("datetime")
    df.sort_index(inplace=True)
    df = df.rename(columns={
        "open": "Open",
        "high": "High",
        "low": "Low",
        "close": "Close"
    })
    df['time30'] = time_to_freq(df['time5'], 30)
    
    return df[["date", "time5", "Open", "High", "Low", "Close", "time30"]] # datetime index

#%% bt
df = pd.read_csv("5min_data_FITX_1.TF.log", sep=" ", usecols=range(6)) # 20190102 845 ~ 20251031 1340
df = prepare_df(df)  # datetime index, date, time5, Open, High, Low, Close, time30
df = df[df.index > '2021-04-01'] # 回測起始日期: 20210601

cash = 1_000_000_000
bt = Backtest(df, Multi_RSI_strategy,
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
    "A": range(40, 85+1), # 75
    "B": range(30, 75+1), # 60
    "C": range(20, 65+1), # 40
    "D": range(10, 55+1), # 25
    # "rsi_window_5min": range(3, 50+1),
    # "rsi_window_30min": range(3, 50+1),
    # "_short": [True, False]
}
print(len(list(product(*param_grid.values()))))
best_equity, best_params = optimize_multi_parallel(bt, param_grid).values()
print('\nBest parameters:\n', best_params)
print(f"Net profit= {best_equity-cash:,.0f}")
#%% sambo
stats, heatmap, optimize_result = bt.optimize(
    A=[40, 85],
    B=[30, 75],
    C=[20, 65],
    D=[10, 55],
    constraint=lambda p: p.A > p.B > p.C > p.D,
    maximize='Equity Final [$]',
    method='sambo',
    max_tries=1000,
    random_state=0,
    return_heatmap=True,
    return_optimization=True)
#%% short
print(Multi_RSI_strategy._short)
#%% sambo result
print("\n", optimize_result)
print(heatmap.sort_values().iloc[-3:])
print("\nNumber of trades=", len(stats['_trades']))
print(f"SQN= {stats.SQN:.2f}")
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% best parameters
stats = bt.run(A = 80, B = 54)
print("\nNumber of trades=", len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
