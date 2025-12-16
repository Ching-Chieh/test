#%% load modules
from backtesting import Strategy
from backtesting.lib import crossover
from ta.trend import ADXIndicator
import pandas as pd

def SMA(values, n):
    return pd.Series(values).rolling(n).mean()

class DMI_MA_Strategy(Strategy):
    adx_value = 19
    ma_short = 30 
    ma_long = 55
    start_date = 20210601 # 回測起點 日期
    contract_size = 200
    
    def init(self):
        high = pd.Series(self.data.High, index=self.data.index)
        low = pd.Series(self.data.Low, index=self.data.index)
        close = pd.Series(self.data.Close, index=self.data.index)
        
        adx_object = ADXIndicator(high=high, low=low, close=close, window=14)
        self.pDI = self.I(adx_object.adx_pos)
        self.nDI = self.I(adx_object.adx_neg)
        self.ADX = self.I(adx_object.adx)
        self.sma_short = self.I(SMA, self.data.Close, self.ma_short)
        self.sma_long = self.I(SMA, self.data.Close, self.ma_long)
        
    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        
        if not self.position:
            # 多單進場
            if crossover(self.pDI, self.nDI) and self.ADX[-1] >= self.adx_value:
                self.buy(size=self.contract_size)
                return

            # 空單進場
            if crossover(self.nDI, self.pDI) and self.ADX[-1] >= self.adx_value:
                self.sell(size=self.contract_size)
                return
        else:
            # 多單出場
            if self.position.is_long:
                # sma_short cross below sma_long
                if crossover(self.sma_long, self.sma_short):
                    self.position.close()
                    return
    
            # 空單出場
            if self.position.is_short:
                # sma_short cross above sma_long
                if crossover(self.sma_short, self.sma_long):
                    self.position.close()
                    return