#%% load modules
from backtesting import Strategy
from backtesting.lib import crossover
import pandas as pd

def VWMA(price: pd.Series, volume: pd.Series, n: int) -> pd.Series:
    pv = price * volume
    vwma_series = pv.rolling(n).sum() / volume.rolling(n).sum()
    
    return vwma_series

class VWMA4Cross_Strategy(Strategy):
    short_period = 30
    long_period = 60
    enter_period = 20
    exit_period = 10
    
    start_date = 20210601 # 回測起點 日期
    contract_size = 200
    
    def init(self):
        close = pd.Series(self.data.Close, index=self.data.index)
        volume = pd.Series(self.data.Volume, index=self.data.index)
        
        self.vwma_short_period = self.I(VWMA, close, volume, self.short_period)
        self.vwma_long_period  = self.I(VWMA, close, volume, self.long_period)
        self.vwma_enter        = self.I(VWMA, close, volume, self.enter_period)
        self.vwma_exit         = self.I(VWMA, close, volume, self.exit_period)
        
    def next(self):
        if self.short_period >= self.long_period:
            return
        if self.data.date[-1] < self.start_date:
            return
        
        cond1 = self.vwma_short_period > self.vwma_long_period and crossover(self.data.Close, self.vwma_enter)
        cond2 = self.vwma_short_period < self.vwma_long_period and crossover(self.vwma_enter, self.data.Close)
        
        if not self.position:
            # 多單進場
            if cond1:
                self.buy(size=self.contract_size)
                return

            # 空單進場
            if cond2:
                self.sell(size=self.contract_size)
                return
        else:
            # 多單出場
            if self.position.is_long:
                if crossover(self.vwma_exit, self.data.Close):
                    self.position.close()
                    return
    
            # 空單出場
            if self.position.is_short:
                if crossover(self.data.Close, self.vwma_exit):
                    self.position.close()
                    return