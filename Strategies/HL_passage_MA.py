#%% load modules
from backtesting import Strategy
from backtesting.lib import crossover
import pandas as pd

def SMA(array, n):
    return pd.Series(array).rolling(n).mean()

class HL_passage_MA_strategy(Strategy):
    high_period = 20
    low_period = 20
    long_exit_ma_period = 5
    short_exit_ma_period = 5
    _short = True
    
    start_date = 20210601 # 回測起始日期
    contract_size = 200
    
    def init(self):
        high = pd.Series(self.data.High, index=self.data.index)
        low = pd.Series(self.data.Low, index=self.data.index)
        close = pd.Series(self.data.Close, index=self.data.index)
        
        self.long_exit_ma = self.I(SMA, close, self.long_exit_ma_period, name = "long_exit_ma")
        self.short_exit_ma = self.I(SMA, close, self.short_exit_ma_period, name = "short_exit_ma")
        self.recent_high = self.I(lambda series, n: series.shift(1).rolling(n).max(), high, self.high_period, name = "recent_high")
        self.recent_low = self.I(lambda series, n: series.shift(1).rolling(n).min(), low, self.low_period, name = "recent_low")

    def next(self):
        if self.data.index[-1] < pd.to_datetime(self.start_date, format='%Y%m%d'):
            return
        
        # 進場
        if not self.position:
            # 多單
            if crossover(self.data.Close, self.recent_high):
                self.buy(size=self.contract_size)
                return
            
            # 空單
            if self._short and crossover(self.recent_low, self.data.Close):
                self.sell(size=self.contract_size)
                return

        # 出場
        else:
            # 多單
            if self.position.is_long:
                if crossover(self.data.Close, self.long_exit_ma):
                    self.position.close()
                    return
 
            # 空單
            if self.position.is_short:
                if crossover(self.short_exit_ma, self.data.Close):
                    self.position.close()
                    return