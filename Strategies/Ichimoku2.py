#%% load modules
from backtesting import Strategy
import pandas as pd

print("回測起點 日期:", 20210601)

def func(high: pd.Series, low: pd.Series, n: int) -> pd.Series:
    series = 0.5 * (pd.Series(high).rolling(n).max() + pd.Series(low).rolling(n).min())
    return series

class Ichimoku2_Strategy(Strategy):
    s = 9
    l = 26
    exit_high_n = 2
    
    start_date = 20210601 # 回測起點 日期
    contract_size = 200
    
    def init(self):
        high = pd.Series(self.data.High, index=self.data.index)
        low = pd.Series(self.data.Low, index=self.data.index)
        
        self.conversion_line = self.I(func, high, low, self.s)
        self.base_line       = self.I(func, high, low, self.l)
        
    def next(self):
        if self.s >= self.l:
            return
        
        if self.data.date[-1] < self.start_date:
            return
        
        close = self.data.Close[-1]
        conversion_line = self.conversion_line
        base_line = self.base_line
        
        short_entry_condition = conversion_line[-2] > base_line[-2] and conversion_line[-1] <= base_line[-1]
        if not self.position:
            # 多單進場
            if conversion_line[-2] < base_line[-2] and conversion_line[-1] >= base_line[-1]:
                self.buy(size=self.contract_size)
                return

            # 空單進場
            if short_entry_condition:
                self.sell(size=self.contract_size)
                return
        else:
            # 多單出場
            if self.position.is_long:
                if short_entry_condition:
                    self.position.close()
                    return
    
            # 空單出場
            if self.position.is_short:
                highest = self.data.High[-1-self.exit_high_n:-1].max()
                if close > highest:
                    self.position.close()
                    return