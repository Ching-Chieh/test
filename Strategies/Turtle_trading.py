#%% load modules
from backtesting import Strategy
from backtesting.lib import crossover
import pandas as pd

def calc_highest(high, period):
    return pd.Series(high).shift(1).rolling(period).max()

def calc_lowest(low, period):
    return pd.Series(low).shift(1).rolling(period).min()
    
class Turtle_trading_strategy(Strategy):
    entry_high_period = 20
    entry_low_period = 20
    exit_high_period = 10
    exit_low_period = 10
    _short = True
    
    start_date = 20210601 # 回測起始日期
    contract_size = 200
    
    def init(self):
        high = pd.Series(self.data.High, index=self.data.index)
        low = pd.Series(self.data.Low, index=self.data.index)
        
        self.entry_high = self.I(calc_highest, high, self.entry_high_period, name = "entry_high")
        self.entry_low  = self.I(calc_lowest, low, self.entry_low_period, name = "entry_low")
        
        self.exit_high = self.I(calc_highest, high, self.exit_high_period, name = "exit_high")
        self.exit_low  = self.I(calc_lowest, low, self.exit_low_period, name = "exit_low")

    def next(self):
        if self.data.index[-1] < pd.to_datetime(self.start_date, format='%Y%m%d'):
            return
        if self.exit_high_period >= self.entry_high_period or self.exit_low_period >= self.entry_low_period:
            return
        
        # 進場
        if not self.position:
            # 多單
            if crossover(self.data.Close, self.entry_high):
                self.buy(size=self.contract_size)
                return
            
            # 空單
            if self._short and crossover(self.entry_low, self.data.Close):
                self.sell(size=self.contract_size)
                return

        # 出場
        else:
            # 多單
            if self.position.is_long:
                if crossover(self.exit_low, self.data.Close):
                    self.position.close()
                    return
 
            # 空單
            if self.position.is_short:
                if crossover(self.data.Close, self.exit_high):
                    self.position.close()
                    return