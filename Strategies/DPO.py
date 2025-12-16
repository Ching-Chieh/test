#%% Strategy
from backtesting import Strategy, Backtest
import pandas as pd

def DPO(series, period=20):
    shift_period = int(period/2 + 1)
    sma = series.rolling(period).mean()
    return series.shift(shift_period) - sma

def find_recent_peak(value, window=2): # window = 2: left 2 bars and right 2 bars
    n = len(value)

    for i in range(n - window - 1, window - 1, -1):
        left = value[i-window:i]
        right = value[i+1:i+window+1]

        if (
            value[i] == max(value[i-window:i+window+1]) and
            value[i] > max(left) and
            value[i] > max(right)
            ):
            bars_ago = n - 1 - i
            return bars_ago

    return None

def find_recent_trough(value, window=2):
    n = len(value)

    for i in range(n - window - 1, window - 1, -1):
        left = value[i-window:i]
        right = value[i+1:i+window+1]

        if (
            value[i] == min(value[i-window:i+window+1]) and
            value[i] < min(left) and
            value[i] < min(right)
            ):
            bars_ago = n - 1 - i
            return bars_ago

    return None

# Detrended price oscillator
class DPO_trend_strategy(Strategy):
    dpo_period = 20
    sma_fast_period = 20
    sma_slow_period = 50
    
    start_date = 20210601
    contract_size = 200
    
    def init(self):
        close = pd.Series(self.data.Close, index=self.data.index)
        self.sma_fast = self.I(lambda x: x.rolling(self.sma_fast_period).mean(), close, name="sma_fast")
        self.sma_slow = self.I(lambda x: x.rolling(self.sma_slow_period).mean(), close, name="sma_slow")
        self.dpo = self.I(DPO, close, self.dpo_period)
        
    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        if self.sma_fast_period >= self.sma_slow_period:
            return
        
        sma_fast = self.sma_fast[-1]
        sma_slow = self.sma_slow
        close = self.data.Close[-1]
        
        if not self.position:
            if (
                sma_slow[-3] < sma_slow[-1] and          # increasing long-term MA
                find_recent_trough(self.dpo, 2) == 2 and # pullback: recent_trough is 2 bars ago
                close > sma_fast
                ):
                self.buy(size=self.contract_size)
                return

            if (
                sma_slow[-3] > sma_slow[-1] and          # decreasing long-term MA
                find_recent_peak(self.dpo, 2) == 2 and   # pullback: recent_peak is 2 bars ago
                close < sma_fast
                ):
                self.sell(size=self.contract_size)
                return

        else:
            if self.position.is_long:
                if find_recent_peak(self.dpo, 2) == 2 and close < sma_fast:
                    self.position.close()
                    return
            if self.position.is_short:
                if find_recent_trough(self.dpo, 2) == 2 and close > sma_fast:
                    self.position.close()
                    return
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
#%% freq=5
freq = 5
#%% bt
df = pd.read_csv(str(freq) + "min_data_FITX_1.TF.log", sep=" ", usecols=range(6))
df = prepare_df(df)
df = df[df.index > '2021-04-01'] # 回測起始日期: 20210601

cash = 1_000_000_000
bt = Backtest(df, DPO_trend_strategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% sambo
stats, heatmap, optimize_result = bt.optimize(
    dpo_period=[5, 50],
    sma_fast_period=[5, 25],
    sma_slow_period=[30, 60],
    constraint=lambda p: p.sma_fast_period < p.sma_slow_period,
    maximize='Equity Final [$]',
    method='sambo',
    max_tries=1000,
    random_state=0,
    return_heatmap=True,
    return_optimization=True)
#%% freq = 5
print("freq:", freq)
print(optimize_result)
print(heatmap.sort_values().iloc[-3:])
print("\nNumber of trades:", len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% freq = 5 best parameters
stats = bt.run(dpo_period = 20, sma_fast_period = 20, sma_slow_period = 50)
print("\nNumber of trades:", len(stats['_trades']))
print(f"SQN: {stats.SQN:.2f}")
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% freq=10
freq = 10
#%% bt
df = pd.read_csv(str(freq) + "min_data_FITX_1.TF.log", sep=" ", usecols=range(6))
df = prepare_df(df)
df = df[df.index > '2021-04-01'] # 回測起始日期: 20210601

cash = 1_000_000_000
bt = Backtest(df, DPO_trend_strategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% sambo
stats, heatmap, optimize_result = bt.optimize(
    dpo_period=[5, 50],
    sma_fast_period=[5, 25],
    sma_slow_period=[30, 60],
    constraint=lambda p: p.sma_fast_period < p.sma_slow_period,
    maximize='Equity Final [$]',
    method='sambo',
    max_tries=1000,
    random_state=0,
    return_heatmap=True,
    return_optimization=True)
#%% freq = 10
print("freq:", freq)
print(optimize_result)
print(heatmap.sort_values().iloc[-3:])
print("\nNumber of trades:", len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% freq = 10 best parameters
stats = bt.run(dpo_period = 20, sma_fast_period = 20, sma_slow_period = 50)
print("\nNumber of trades:", len(stats['_trades']))
print(f"SQN: {stats.SQN:.2f}")
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% freq=20
freq = 20
#%% bt
df = pd.read_csv(str(freq) + "min_data_FITX_1.TF.log", sep=" ", usecols=range(6))
df = prepare_df(df)
df = df[df.index > '2021-04-01'] # 回測起始日期: 20210601

cash = 1_000_000_000
bt = Backtest(df, DPO_trend_strategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% sambo
stats, heatmap, optimize_result = bt.optimize(
    dpo_period=[5, 50],
    sma_fast_period=[5, 25],
    sma_slow_period=[30, 60],
    constraint=lambda p: p.sma_fast_period < p.sma_slow_period,
    maximize='Equity Final [$]',
    method='sambo',
    max_tries=1000,
    random_state=0,
    return_heatmap=True,
    return_optimization=True)
#%% freq = 20
print("freq:", freq)
print(optimize_result)
print(heatmap.sort_values().iloc[-3:])
print("\nNumber of trades:", len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% freq = 20 best parameters
stats = bt.run(dpo_period = 20, sma_fast_period = 20, sma_slow_period = 50)
print("\nNumber of trades:", len(stats['_trades']))
print(f"SQN: {stats.SQN:.2f}")
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
