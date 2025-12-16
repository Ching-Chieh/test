#%% Strategy
from backtesting import Strategy, Backtest
from backtesting.lib import crossover
from talib import STOCH
import pandas as pd

class KD_strategy(Strategy):
    fastk_period = 9
    slowk_period = 3
    slowd_period = 3
    high_value = 70
    low_value = 30
    stoploss_pct_long = 2
    stoploss_pct_short = 2

    start_date = 20210601
    contract_size = 200
    
    def init(self):
        high = pd.Series(self.data.High, index=self.data.index)
        low = pd.Series(self.data.Low, index=self.data.index)
        close = pd.Series(self.data.Close, index=self.data.index)
        # slowk, slowd = STOCH(high, low, close, fastk_period=5, slowk_period=3, slowk_matype=0, slowd_period=3, slowd_matype=0)
        self.k, self.d = self.I(STOCH,
                                high, low, close,
                                self.fastk_period,
                                self.slowk_period,
                                0,
                                self.slowd_period,
                                0,
                                name=['k', 'd'])
        
        
        self.entry_price = None
        self.stoploss_price = None
        
    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        
        k = self.k[-1]
        d = self.d[-1]
        close = self.data.Close[-1]
        
        if not self.position:
            # 多單進場
            if k >= self.high_value and d >= self.high_value and crossover(self.d, self.k):
                self.buy(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = close * (1 - self.stoploss_pct_long * 0.01)
                return

            # 空單進場
            if k <= self.low_value and d <= self.low_value and crossover(self.k, self.d):
                self.sell(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = close * (1 + self.stoploss_pct_short * 0.01)
                return

        # 移動停損
        else:
            # 多單
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

            # 空單
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
#%% freq
freq = 30
#%% bt
df = pd.read_csv(str(freq) + "min_data_FITX_1.TF.log", sep=" ", usecols=range(6))
df = prepare_df(df)
df = df[df.index > '2021-04-01'] # 回測起始日期: 20210601

cash = 1_000_000_000
bt = Backtest(df, KD_strategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% try
stats = bt.run()
print("\nNumber of trades=", len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% sambo
stats, heatmap, optimize_result = bt.optimize(
    fastk_period=[3, 20],
    slowk_period=[3, 20],
    slowd_period=[3, 20],
    high_value=[65, 95],
    low_value=[10, 45],
    stoploss_pct_long=[0.3, 3],
    stoploss_pct_short=[0.3, 3],
    maximize='Equity Final [$]',
    method='sambo',
    max_tries=1000,
    random_state=0,
    return_heatmap=True,
    return_optimization=True)
#%%
print(optimize_result)
print(heatmap.sort_values().iloc[-3:])
print("\nNumber of trades=", len(stats['_trades']))
print(stats.SQN)
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% best parameters
stats = bt.run(fastk_period = 30, slowk_period = 30, slowd_period = 17,
               high_value = 69, low_value = 25,
               stoploss_pct_long = 2.9, stoploss_pct_short = 0.95)
print("\nNumber of trades=", len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
