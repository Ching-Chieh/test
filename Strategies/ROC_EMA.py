#%% Strategy
from backtesting import Strategy, Backtest
from talib import EMA
import pandas as pd

def ROC_EMA(series: pd.Series, nROC, nEMA):
    x = EMA(series, nEMA)
    return (x / x.shift(nROC) - 1) * 100

class ROCEMA_strategy(Strategy):
    nROC = 50
    nEMA = 15
    ntrend = 100
    stoploss_pct_long = 2
    stoploss_pct_short = 2

    start_date = 20210601
    contract_size = 200
    
    def init(self):
        close = pd.Series(self.data.Close, index=self.data.index)
        self.rocema = self.I(ROC_EMA, close, self.nROC, self.nEMA, name='ROCEMA')
        self.trend = self.I(EMA, close, self.ntrend, name='trend')
        
        self.entry_price = None
        self.stoploss_price = None
        
    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        
        close = self.data.Close[-1]
        
        if not self.position:
            if self.rocema[-2] <= 0 and self.rocema[-1] > 0 and close > self.trend[-1]:
                self.buy(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = close * (1 - self.stoploss_pct_long * 0.01)
                return

            if self.rocema[-2] >= 0 and self.rocema[-1] < 0 and close < self.trend[-1]:
                self.sell(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = close * (1 + self.stoploss_pct_short * 0.01)
                return

        else:
            if self.position.is_long:
                if close > self.entry_price:
                    new_stop = close * (1 - self.stoploss_pct_long * 0.01)
                    if new_stop > self.stoploss_price:
                        self.stoploss_price = new_stop
                if close <= self.stoploss_price:
                    self.position.close()
                    self.entry_price = None
                    self.stoploss_price = None
                    return

            if self.position.is_short:
                if close < self.entry_price:
                    new_stop = close * (1 + self.stoploss_pct_short * 0.01)
                    if new_stop < self.stoploss_price:
                        self.stoploss_price = new_stop
                if close >= self.stoploss_price:
                    self.position.close()
                    self.entry_price = None
                    self.stoploss_price = None
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
#%% freq=10
freq = 10
#%% bt
df = pd.read_csv(str(freq) + "min_data_FITX_1.TF.log", sep=" ", usecols=range(6))
df = prepare_df(df)
df = df[df.index > '2021-04-01'] # 回測起始日期: 20210601

cash = 1_000_000_000
bt = Backtest(df, ROCEMA_strategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% sambo
stats, heatmap, optimize_result = bt.optimize(
    nROC=[5, 100],
    nEMA=[5, 100],
    ntrend=[5, 120],
    stoploss_pct_long=[0.1, 3],
    stoploss_pct_short=[0.1, 3],
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
stats = bt.run(nROC = 5, nEMA = 87, ntrend = 120, stoploss_pct_long = 3, stoploss_pct_short = 1.69)
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
bt = Backtest(df, ROCEMA_strategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% sambo
stats, heatmap, optimize_result = bt.optimize(
    nROC=[5, 100],
    nEMA=[5, 100],
    ntrend=[5, 120],
    stoploss_pct_long=[0.1, 3],
    stoploss_pct_short=[0.1, 3],
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
stats = bt.run(nROC = 5, nEMA = 45, ntrend = 103, stoploss_pct_long = 3, stoploss_pct_short = 0.68)
print("\nNumber of trades:", len(stats['_trades']))
print(f"SQN: {stats.SQN:.2f}")
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")