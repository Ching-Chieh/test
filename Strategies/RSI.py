#%% load modules
from backtesting import Strategy
from ta.momentum import RSIIndicator
import pandas as pd

class RSIStrategy(Strategy):
    rsi_high = 70
    # rsi_low = 30
    rsi_window = 14
    stoploss_pct = 2
    start_date = 20210601 # 回測起始日期
    contract_size = 200

    def init(self):
        close = pd.Series(self.data.Close, index=self.data.index)
        rsi_object = RSIIndicator(close, self.rsi_window)
        self.rsi = self.I(rsi_object.rsi)
        
        self.entry_price = None
        self.stoploss_price = None
        
    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        
        close = self.data.Close[-1]
        rsi = self.rsi
        
        if not self.position:
            # 多單進場
            if rsi[-2] < self.rsi_high and rsi[-1] >= self.rsi_high:
                self.buy(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = self.entry_price * (1 - self.stoploss_pct * 0.01)
                return
            '''
            # 空單進場
            if rsi[-2] > self.rsi_low and rsi[-1] <= self.rsi_low:
                self.sell(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = self.entry_price * (1 + self.stoploss_pct * 0.01)
                return
            '''
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
            '''
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
            '''