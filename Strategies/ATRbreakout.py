#%% load modules
from backtesting import Strategy
from backtesting.lib import crossover
import pandas as pd
import numpy as np

def SMA(series, period):
    return pd.Series(series).rolling(period).mean().values

def true_range(high, low, close):
    high = np.array(high)
    low = np.array(low)
    close = np.array(close)

    prev_close = np.roll(close, 1)
    prev_close[0] = close[0]

    tr = np.maximum(high - low, np.maximum(abs(high - prev_close), abs(low - prev_close)))
    return tr

def ATR(high, low, close, period):
    tr = true_range(high, low, close)
    atr = SMA(tr, period)
    return atr

def calc_upper(sma, atr, mult):
    return sma + atr * mult

def calc_lower(sma, atr, mult):
    return sma - atr * mult

class ATR_breakout_Strategy(Strategy):
    sma_period = 20
    atr_period = 20
    upper_mult = 2
    lower_mult = 2
    start_date = 20210601 # 回測起點 日期
    contract_size = 200
    
    def init(self):
        close = self.data.Close
        high = self.data.High
        low = self.data.Low

        self.sma = self.I(SMA, close, self.sma_period)
        self.atr = self.I(ATR, high, low, close, self.atr_period)

        self.upper = self.I(calc_upper, self.sma, self.atr, self.upper_mult)
        self.lower = self.I(calc_lower, self.sma, self.atr, self.lower_mult)

    def next(self):
        if self.data.index[-1] < pd.to_datetime(str(self.start_date), format="%Y%m%d"):
            return

        long_entry_condition = crossover(self.data.Close, self.upper)
        short_entry_condition = crossover(self.lower, self.data.Close)
        
        if not self.position:
            # 多單進場
            if long_entry_condition:
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
                if long_entry_condition:
                    self.position.close()
                    return
            
