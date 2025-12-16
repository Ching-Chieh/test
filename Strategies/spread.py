#%% load modules
from backtesting import Strategy
import pandas as pd

print("回測起點 日期:", 20210601)

def cal_spread(close: pd.Series, close_TSE: pd.Series) -> pd.Series:
    return close - close_TSE

class Spread_Strategy(Strategy):
    spread_param = -100
    stoploss_pct = 2
    start_date = 20210601 # 回測起點 日期
    contract_size = 200
    
    def init(self):
        close = pd.Series(self.data.Close, index=self.data.index)
        close_TSE = pd.Series(self.data.close_TSE, index=self.data.index)
        self.spread = self.I(cal_spread, close, close_TSE)
        
        self.entry_price = None
        self.stoploss_price = None
        
    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        
        close = self.data.Close[-1]
        
        if not self.position:
            # 多單進場
            if self.spread[-2] < self.spread_param and self.spread[-1] > self.spread_param:
                self.buy(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = self.entry_price * (1 - self.stoploss_pct * 0.01)
                return
            '''
            # 空單進場
            if :
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