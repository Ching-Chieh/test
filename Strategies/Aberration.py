#%% load modules
from backtesting import Strategy
from backtesting.lib import crossover
import pandas as pd

def SMA(values, n):
    return pd.Series(values).rolling(n).mean()

def compute_bands(high, low, middle_ma_n, sd_n, sd_m):

    highlow = 0.5 * (high.shift(1) + low.shift(1))
    middle = SMA(highlow, middle_ma_n)
    std = middle.rolling(sd_n).std(ddof=1)
    
    upper = middle + sd_m * std
    lower = middle - sd_m * std
    
    return middle, upper, lower

class AberrationStrategy(Strategy):
    take_profit_pct = 1.8
    profit_drawback_pct = 0.9
    middle_ma_n = 20
    sd_n = 10   # 標準差期數
    sd_m = 0.5  # 標準差倍數
    start_date = 20210601 # 回測起點 日期
    contract_size = 200
    
    def init(self):
        high = pd.Series(self.data.High, index=self.data.index)
        low = pd.Series(self.data.Low, index=self.data.index)
        self.middle, self.upper, self.lower = self.I(compute_bands, high, low, self.middle_ma_n, self.sd_n, self.sd_m)
        
        self.entry_price = None
        self.take_profit_price = None
        self.profit_drawback_price = None
        
    def next(self):
        if self.profit_drawback_pct >= self.take_profit_pct:
            return
        
        if self.data.date[-1] < self.start_date:
            return
        
        close = self.data.Close[-1]
        
        if not self.position and self.data.time[-1] < 1245:
            # 多單進場
            if crossover(self.data.Close, self.upper):
                self.buy(size=self.contract_size)
                self.entry_price = close
                return
            '''
            # 空單進場
            if crossover(self.lower, self.data.Close):
                self.sell(size=self.contract_size)
                self.entry_price = close
                return
            '''
        # 移動停利, 停損
        else:
            # 多單
            if self.position.is_long:
                if self.take_profit_price is None and close >= self.entry_price*(1 + self.take_profit_pct*0.01):
                    self.take_profit_price = close
                    self.profit_drawback_price = self.take_profit_price*(1 - self.profit_drawback_pct*0.01)
                    return
                
                if self.take_profit_price is not None:
                    if close <= self.profit_drawback_price:
                        self.position.close()
                        self.entry_price = None
                        self.take_profit_price = None
                        self.profit_drawback_price = None
                        return
                    
                    elif close > self.take_profit_price:
                        self.take_profit_price = close
                        self.profit_drawback_price = self.take_profit_price*(1 - self.profit_drawback_pct*0.01)
                        return
                    
                elif close <= self.middle:
                    self.position.close()
                    self.entry_price = None
                    self.take_profit_price = None
                    self.profit_drawback_price = None
                    return
            '''
            # 空單
            if self.position.is_short:
                if self.take_profit_price is None and close <= self.entry_price*(1 - self.take_profit_pct*0.01):
                    self.take_profit_price = close
                    self.profit_drawback_price = self.take_profit_price*(1 + self.profit_drawback_pct*0.01)
                    return
                
                if self.take_profit_price is not None:
                    if close >= self.profit_drawback_price:
                        self.position.close()
                        self.entry_price = None
                        self.take_profit_price = None
                        self.profit_drawback_price = None
                        return
                    
                    elif close < self.take_profit_price:
                        self.take_profit_price = close
                        self.profit_drawback_price = self.take_profit_price*(1 + self.profit_drawback_pct*0.01)
                        return
                    
                elif close >= self.middle:
                    self.position.close()
                    self.entry_price = None
                    self.take_profit_price = None
                    self.profit_drawback_price = None
                    return

            '''