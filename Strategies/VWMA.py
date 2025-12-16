#%% load modules
from backtesting import Strategy
from backtesting.lib import crossover
import pandas as pd

def VWMA(price: pd.Series, volume: pd.Series, n: int) -> pd.Series:
    pv = price * volume
    vwma_series = pv.rolling(n).sum() / volume.rolling(n).sum()
    
    return vwma_series

class VWMA_Strategy(Strategy):
    ma_short = 5
    ma_long = 10
    start_date = 20210601 # 回測起點 日期
    
    def init(self):
        close = pd.Series(self.data.Close, index=self.data.index)
        volume = pd.Series(self.data.Volume, index=self.data.index)
        
        self.vwma_short = self.I(VWMA, close, volume, self.ma_short)
        self.vwma_long  = self.I(VWMA, close, volume, self.ma_long)
        
    def next(self):
        if self.ma_short >= self.ma_long:
            return
        if self.data.date[-1] < self.start_date:
            return
        
        cond1 = crossover(self.vwma_short, self.vwma_long)
        cond2 = crossover(self.vwma_long, self.vwma_short)
        
        if not self.position:
            # 多單進場
            if cond1:
                self.buy(size=200)
                return

            # 空單進場
            if cond2:
                self.sell(size=200)
                return
        else:
            # 多單出場
            if self.position.is_long:
                if cond2:
                    self.position.close()
                    return
    
            # 空單出場
            if self.position.is_short:
                if cond1:
                    self.position.close()
                    return