#%% Strategy
from backtesting import Backtest, Strategy
from backtesting.lib import crossover
from ta.trend import CCIIndicator
import pandas as pd

class CCI_cross_strategy(Strategy):
    short_period = 6
    long_period = 12
    stoploss_pct_long = 2
    stoploss_pct_short = 2
    
    start_date = 20210601
    contract_size = 200
    
    def init(self):
        high = pd.Series(self.data.High, index=self.data.index)
        low = pd.Series(self.data.Low, index=self.data.index)
        close = pd.Series(self.data.Close, index=self.data.index)
        
        CCI_object = CCIIndicator(high, low, close, self.short_period)
        self.cci_fast = self.I(CCI_object.cci, name='CCI_fast')
        CCI_object = CCIIndicator(high, low, close, self.long_period)
        self.cci_slow = self.I(CCI_object.cci, name='CCI_slow')
        
        self.entry_price = None
        self.stoploss_price = None

    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        
        close = self.data.Close[-1]

        # 進場
        if not self.position:
            # 多單
            if crossover(self.cci_fast, self.cci_slow):
                self.buy(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = close * (1 - self.stoploss_pct_long * 0.01)
                return
            # 空單
            if crossover(self.cci_slow, self.cci_fast):
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
#%% bt
df = pd.read_csv("15min_data_FITX_1.TF.log", sep=" ", usecols=range(6)) # 20190102 845 ~ 20251031 1330
df = prepare_df(df)
df = df[df.index > '2021-04-01'] # 回測起點 日期: 20210601

cash = 1_000_000_000
bt = Backtest(df, CCI_cross_strategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% try
stats = bt.run()
print('\nNumber of trades=', len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% sambo
stats, heatmap, optimize_result = bt.optimize(
    short_period = [5, 60],
    long_period = [5, 80],
    stoploss_pct_long = [0.5, 3],
    stoploss_pct_short = [0.5, 3],
    constraint=lambda p: p.short_period < p.long_period,
    maximize='Equity Final [$]',
    method='sambo',
    max_tries=1000,
    random_state=0,
    return_heatmap=True,
    return_optimization=True)
#%% best parameters
print("\n", optimize_result)
print(heatmap.sort_values().iloc[-3:])
print("\nNumber of trades=", len(stats['_trades']))
print(f"SQN= {stats.SQN:.2f}")
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% run
stats = bt.run(short_period = 38, long_period = 59, stoploss_pct_long = 2.48, stoploss_pct_short = 0.94)
print('\nNumber of trades=', len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
print(f"SQN= {stats.SQN:.2f}")

