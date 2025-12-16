#%% load modules
from backtesting import Strategy
from backtesting.lib import crossover
import pandas as pd

def SMA(array, n):
    return pd.Series(array).rolling(n).mean()

class HL_passage_trailing_stoploss_strategy(Strategy):
    high_period = 20
    low_period = 20
    stoploss_pct_long = 2
    stoploss_pct_short = 2
    _short = True
    
    start_date = 20210601 # 回測起始日期
    contract_size = 200
    
    def init(self):
        high = pd.Series(self.data.High, index=self.data.index)
        low = pd.Series(self.data.Low, index=self.data.index)
        
        self.recent_high = self.I(lambda series, n: series.shift(1).rolling(n).max(), high, self.high_period, name = "recent_high")
        self.recent_low = self.I(lambda series, n: series.shift(1).rolling(n).min(), low, self.low_period, name = "recent_low")

        self.entry_price = None
        self.stoploss_price = None

    def next(self):
        if self.data.index[-1] < pd.to_datetime(self.start_date, format='%Y%m%d'):
            return
        
        close = self.data.Close[-1]
        
        # 進場
        if not self.position:
            # 多單
            if crossover(self.data.Close, self.recent_high):
                self.buy(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = close * (1 - self.stoploss_pct_long * 0.01)
                return
            
            # 空單
            if self._short and crossover(self.recent_low, self.data.Close):
                self.sell(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = close * (1 + self.stoploss_pct_short * 0.01)
                return

        # 移動停損出場
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