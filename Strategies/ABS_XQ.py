#%% 1
from backtesting import Backtest, Strategy
import pandas as pd

def SMA(values, n):
    return pd.Series(values).shift(1).rolling(n).mean()

start_date = 20210601
start_time = 845

def prepare_df():
    df = pd.read_csv("long_10min_data_FITX_1.TF.log", sep=" ", usecols=range(6))
    df["datetime"] = pd.to_datetime(df["date"].astype(str) + df["time"].astype(str).str.zfill(4), format="%Y%m%d%H%M")
    df = df.set_index("datetime")
    df.sort_index(inplace=True)
    df.rename(columns={
        "open": "Open",
        "high": "High",
        "low": "Low",
        "close": "Close"
    }, inplace=True)
    return df

df = prepare_df()
df = df[df.index > '2021-04-01'] # datetime index,   date, time, Open, High, Low, Close
# n=9
# k_period=3
# d_period=3

def xq_kd(df, start_date, start_time, n=9, k_period=3, d_period=3):
    idx = df[(df['date'] == start_date) & (df['time'] == start_time)].index[0]
    idx_pos = df.index.get_loc(idx)
    df = df.iloc[idx_pos - 50 - (n-1):].copy()
    # 配合XQ預先執行筆數50，n=9 XQ預先執行筆數的第一筆的rsv是用那一筆+前8筆資料計算得到
    
    high = df['High']
    low = df['Low']
    close = df['Close']
    
    low_min = low.rolling(n).min()
    high_max = high.rolling(n).max()
    
    rsv = (close - low_min) / (high_max - low_min) * 100
    rsv = rsv.where(high_max != low_min, 50)

    k = pd.Series(index=rsv.index, dtype=float)
    d = pd.Series(index=rsv.index, dtype=float)

    k.iloc[n-1] = 50
    d.iloc[n-1] = 50

    for i in range(n, len(rsv)):
        k.iloc[i] = (rsv.iloc[i] + (k_period-1)*k.iloc[i-1]) / k_period
        d.iloc[i] = (k.iloc[i] + (d_period-1)*d.iloc[i-1]) / d_period
    
    # df['k'] = k
    df['d'] = d
    return df


df = xq_kd(df, start_date, start_time)
# df = df[df.index > str(start_date)]

class ABSStrategy(Strategy):
    ma_n = 20
    # n = 9
    # k_period = 3
    # d_period = 3
    d_threshold = 50
    stoploss_pct = 2
    start_date = 20210601 # 回測起點 日期
    
    def init(self):
        self.absvalue = abs(self.data.Open - self.data.Close)
        self.sma = self.I(SMA, self.absvalue, self.ma_n)
        
    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        
        open = self.data.Open[-1]
        close = self.data.Close[-1]
        d = self.data.d[-1]
        absvalue = self.absvalue[-1]
        sma = self.sma[-1]
        
        if not self.position:
            # 多單進場
            if (
                d > self.d_threshold and
                close > open and
                absvalue > sma
            ):
                self.buy(size=200)
                self.entry_price = close
                self.stoploss_price = self.entry_price * (1 - self.stoploss_pct * 0.01)
                return
            '''
            # 空單進場
            if (
                d < self.d_threshold and
                close < open and
                absvalue > sma
            ):
                self.sell(size=200)
                self.entry_price = close
                self.stoploss_price = self.entry_price * (1 + self.stoploss_pct * 0.01)
                return
            '''
        else:
            # 多單移動停損
            if self.position.is_long:
                if close > self.entry_price:
                    new_stop = close * (1 - self.stoploss_pct * 0.01)
                    if new_stop > self.stoploss_price:
                        self.stoploss_price = new_stop
    
                if close <= self.stoploss_price:
                    self.position.close()
                    self.stoploss_price = None
                    return
            '''
            # 空單移動停損
            if self.position.is_short:
                if close < self.entry_price:
                    new_stop = close * (1 + self.stoploss_pct * 0.01)
                    if new_stop < self.stoploss_price:
                        self.stoploss_price = new_stop
    
                if close >= self.stoploss_price:
                    self.position.close()
                    self.stoploss_price = None
                    return
            '''
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
#                    "Size": "type",
#                    "PnL": 'Profit or loss',
#                    'Entry_SMA(O,20)': 'sma'
#             })
#     trades['type'] = trades['type'].replace({200: 'long', -200: 'short'})
#     trades[['EntryPrice', 'Profit or loss']] = trades[['EntryPrice', 'Profit or loss']].astype(int)
    
#     df = df.copy().reset_index(drop=True)[['date', 'time', 'd']].assign(EntryBar=range(0, len(df)))
#     trades = pd.merge(trades, df, on='EntryBar', how='inner')
#     trades = trades[['type', 'date', 'time', 'EntryPrice', 'ExitPrice', 'Profit or loss', 'sma', 'd']]
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
    "ma_n" : [5, 10, 15, 20, 25, 30],
    "d_threshold" : [40, 45, 50, 55, 60, 65, 70],
    "stoploss_pct": [1, 1.5, 2, 2.5, 3]
}

best_equity, best_params = optimize_multi_parallel(bt, param_grid).values()
print('\nBest parameters:\n', best_params)
print(f"\nNet profit= {best_equity-cash:,.0f}")
