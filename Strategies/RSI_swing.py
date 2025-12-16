#%% load modules
from backtesting import Strategy
from backtesting.lib import crossover
from ta.momentum import RSIIndicator
import pandas as pd

def count_5min_slots(start, end):
    def to_minutes(t):
        return (t // 100) * 60 + (t % 100)

    start_min = to_minutes(start)
    end_min   = to_minutes(end)
    
    diff = end_min - start_min
    return diff // 5 + 1

class RSI_swing_strategy(Strategy):
    stoploss_pct = 2
    rsi_short_len = 6
    rsi_long_len = 12
    daily_high_low_time = 905
    
    start_date = 20210601
    contract_size = 200
    
    def init(self):
        close = pd.Series(self.data.Close, index=self.data.index)
        
        rsi_short_object = RSIIndicator(close, self.rsi_short_len)
        self.rsi_short = self.I(rsi_short_object.rsi)
        rsi_long_object = RSIIndicator(close, self.rsi_long_len)
        self.rsi_long = self.I(rsi_long_object.rsi)

        self.daily_high = None
        self.daily_low = None
        
        self.entry_price = None
        self.stoploss_price = None
        
    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        if self.rsi_short_len >= self.rsi_long_len:
            return
        
        low = self.data.Low
        close = self.data.Close[-1]
        
        if self.data.time[-1] == 845:
            self.daily_high = None
            self.daily_low = None
        
        if self.data.time[-1] == self.daily_high_low_time:
            idx = count_5min_slots(845, self.daily_high_low_time)
            self.daily_high = self.data.High[-idx:].max()
            self.daily_low = self.data.Low[-idx:].min()
        
        if not self.position and self.daily_high is not None and len(self.data.Close) >= 4:
            # 多單進場
            # rsi_short cross below rsi_long
            if (crossover(self.rsi_long, self.rsi_short) and
                close < self.daily_low and
                low[-1] <= low[-4:-1].min()
            ):
                self.buy(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = close * (1 - self.stoploss_pct * 0.01)
                return

        # 移動停損
        if self.position:
            # 多單
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