#%% load modules
from backtesting import Strategy

class USStrategy(Strategy):
    dji_ret = 1
    gspc_ret = 1
    ixic_ret = 1
    sox_ret = 1
    tsm_ret = 1
    stoploss_pct = 3
    entry_time = 905

    def init(self):
        pass
    
    def next(self):
        close = self.data.Close[-1]
        current_time = self.data.index[-1]

        if (
            current_time.hour == self.entry_time // 100 and
            current_time.minute == self.entry_time % 100 and
            not self.position
        ):
            long_cond = all(
                self.data[col][-1] >= getattr(self, f"{col.lower()}_ret") * 0.01
                for col in ['DJI', 'GSPC', 'IXIC', 'SOX', 'TSM']
            )
            short_cond = all(
                self.data[col][-1] <= -getattr(self, f"{col.lower()}_ret") * 0.01
                for col in ['DJI', 'GSPC', 'IXIC', 'SOX', 'TSM']
            )

            if long_cond:
                self.buy(size=200)
                self.entry_price = close
                self.stoploss_price = self.entry_price * (1 - self.stoploss_pct * 0.01)
                return

            if short_cond:
                self.sell(size=200)
                self.entry_price = close
                self.stoploss_price = self.entry_price * (1 + self.stoploss_pct * 0.01)
                return

    
        if self.position:
            # 多單移動停損
            if self.position.is_long:
                if close > self.entry_price:
                    new_stop = close * (1 - self.stoploss_pct * 0.01)
                    if new_stop > self.stoploss_price:
                        self.stoploss_price = new_stop
    
                if close <= self.stoploss_price:
                    self.position.close()
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
                    self.stoploss_price = None
                    return