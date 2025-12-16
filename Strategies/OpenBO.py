#%% load modules
from backtesting import Strategy

class OpenBO_strategy(Strategy):
    stoploss_pct_long = 2
    stoploss_pct_short = 2
    long_mult = 1.2
    short_mult = 1.2
    _short = True
    
    start_date = 20210601 # 回測起始日期
    contract_size = 200
    
    def init(self):
        self.entry_price = None
        self.stoploss_price = None
        
    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        
        close = self.data.Close[-1]
        
        # 進場
        if not self.position:
            long_entry_condition = close > self.data.daily_open[-1]*(1 + self.long_mult*0.01)
            short_entry_condition = close < self.data.daily_open[-1]*(1 - self.short_mult*0.01)
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
