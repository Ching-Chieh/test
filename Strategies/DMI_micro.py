#%% load modules
from backtesting import Strategy
from backtesting.lib import crossover
from ta.trend import ADXIndicator
import pandas as pd

class DMIStrategy(Strategy):
    adx_value = 19
    stoploss_pct = 0.4
    start_date = 20251101 # 回測起點 日期
    contract_size = 10

    def init(self):
        high = pd.Series(self.data.High, index=self.data.index)
        low = pd.Series(self.data.Low, index=self.data.index)
        close = pd.Series(self.data.Close, index=self.data.index)
        
        adx_object = ADXIndicator(high=high, low=low, close=close, window=14)
        self.pDI = self.I(adx_object.adx_pos)
        self.nDI = self.I(adx_object.adx_neg)
        self.ADX = self.I(adx_object.adx)
        
        self.entry_price = None
        self.stoploss_price = None
        
    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        
        close = self.data.Close[-1]
        pDI = self.pDI
        nDI = self.nDI
        ADX = self.ADX[-1]

        if not self.position:
            # 多單進場
            if crossover(pDI, nDI) and ADX >= self.adx_value:
                self.buy(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = self.entry_price * (1 - self.stoploss_pct * 0.01)
                return

            # 空單進場
            if crossover(nDI, pDI) and ADX >= self.adx_value:
                self.sell(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = self.entry_price * (1 + self.stoploss_pct * 0.01)
                return
        else:
            # 多單移動停損
            if self.position.is_long:
                if close > self.entry_price:
                    new_stop = close * (1 - self.stoploss_pct * 0.01)
                    if new_stop > self.stoploss_price:
                        self.stoploss_price = new_stop
    
                if close <= self.stoploss_price:
                    self.position.close()
                    self.entry_price = None
                    self.stoploss_price = None
                    return
    
            # 空單移動停損
            if self.position.is_short:
                if close < self.entry_price:
                    new_stop = close * (1 + self.stoploss_pct * 0.01)
                    if new_stop < self.stoploss_price:
                        self.stoploss_price = new_stop
    
                if close >= self.stoploss_price:
                    self.position.close()
                    self.entry_price = None
                    self.stoploss_price = None
                    return