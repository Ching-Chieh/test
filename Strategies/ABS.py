#%% load modules
from backtesting import Strategy
from talib import STOCH, SMA

class ABSStrategy(Strategy):
    ma_n = 20
    n = 9
    k_period = 3
    d_period = 3
    d_threshold = 50
    stoploss_pct = 2
    start_date = 20210601 # 回測起點 日期
    
    def init(self):
# slowk, slowd = STOCH(high, low, close, fastk_period=5, slowk_period=3, slowk_matype=0, slowd_period=3, slowd_matype=0)

        self.k, self.d = self.I(STOCH, self.data.High, self.data.Low, self.data.Close, self.n, self.k_period, 0, self.d_period, 0)
        self.absvalue = abs(self.data.Open - self.data.Close)
        self.sma = self.I(SMA, self.absvalue, self.ma_n)
        
        self.entry_price = None
        self.stoploss_price = None
        
    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        
        open = self.data.Open[-1]
        close = self.data.Close[-1]
        d = self.d[-1]
        absvalue = self.absvalue[-1]
        sma = self.sma[-1]
        
        if not self.position:
            # 多單進場
            if (
                d > self.d_threshold and
                close > open and
                absvalue > sma
            ):
                self.buy(size=200)
                self.entry_price = close
                self.stoploss_price = self.entry_price * (1 - self.stoploss_pct * 0.01)
                return
            '''
            # 空單進場
            if (
                d < self.d_threshold and
                close < open and
                absvalue > sma
            ):
                self.sell(size=200)
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
