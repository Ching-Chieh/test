#%% load modules
from backtesting import Strategy

def count_5min_slots(start, end):
    def to_minutes(t):
        return (t // 100) * 60 + (t % 100)

    start_min = to_minutes(start)
    end_min   = to_minutes(end)
    
    diff = end_min - start_min
    return diff // 5 + 1

class HLBO_strategy(Strategy):
    stoploss_pct_long = 2
    stoploss_pct_short = 2
    long_mult = 1.2
    short_mult = 1.2
    daily_high_low_time = 925
    _short = True
    
    start_date = 20210601 # 回測起始日期
    contract_size = 200
    
    def init(self):
        self.daily_high = None
        self.daily_low = None
        self.entry_price = None
        self.stoploss_price = None
        
    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        
        if self.data.time[-1] == 845:
            self.daily_high = None
            self.daily_low = None
            
        if self.data.time[-1] == self.daily_high_low_time:
            idx = count_5min_slots(845, self.daily_high_low_time)
            self.daily_high = self.data.High[-idx:].max()
            self.daily_low = self.data.Low[-idx:].min()
        
        close = self.data.Close[-1]
        
        # 進場
        if self.daily_high is not None:
            if not self.position:
                long_entry_condition = close > self.daily_high*(1 + self.long_mult*0.01)
                short_entry_condition = close < self.daily_low*(1 - self.short_mult*0.01)
                # 多單
                if long_entry_condition:
                    self.buy(size=self.contract_size)
                    self.entry_price = close
                    self.stoploss_price = close * (1 - self.stoploss_pct_long * 0.01)
                    return
                
                # 空單
                if self._short and short_entry_condition:
                    self.sell(size=self.contract_size)
                    self.entry_price = close
                    self.stoploss_price = close * (1 + self.stoploss_pct_short * 0.01)
                    return
                
        # 移動停損
        if self.position:
            # 多單
            if self.position.is_long:
                if close > self.entry_price:
                    new_stop = close * (1 - self.stoploss_pct_long * 0.01)
                    if new_stop > self.stoploss_price:
                        self.stoploss_price = new_stop
                if close <= self.stoploss_price:
                    self.position.close()
                    self.entry_price = None
                    self.stoploss_price = None
                    return

            # 空單
            if self.position.is_short:
                if close < self.entry_price:
                    new_stop = close * (1 + self.stoploss_pct_short * 0.01)
                    if new_stop < self.stoploss_price:
                        self.stoploss_price = new_stop
                if close >= self.stoploss_price:
                    self.position.close()
                    self.entry_price = None
                    self.stoploss_price = None
                    return
