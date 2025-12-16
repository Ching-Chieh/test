#%% load modules
from backtesting import Strategy
from backtesting.lib import crossover
import pandas as pd

def SMA(values, n):
    return pd.Series(values).rolling(n).mean()

print("回測起點 日期:", 20240901)

class three_MA_Strategy(Strategy):
    ma_s = 5
    ma_m = 25
    ma_l = 30
    start_date = 20240901 # 回測起點 日期
    contract_size = 10
    
    def init(self):
        self.SMA_S = self.I(SMA, self.data.Close, self.ma_s)
        self.SMA_M = self.I(SMA, self.data.Close, self.ma_m)
        self.SMA_L = self.I(SMA, self.data.Close, self.ma_l)
        
    def next(self):
        if (self.ma_s >= self.ma_m or
            self.ma_s >= self.ma_l or
            self.ma_m >= self.ma_l
            ):
            return
        
        if self.data.date[-1] < self.start_date:
            return
        
        SMA_S = self.SMA_S[-1]
        SMA_M = self.SMA_M[-1]
        SMA_L = self.SMA_L[-1]
        close = self.data.Close[-1]
        
        cond_1 = crossover(self.SMA_S, self.SMA_M)
        cond_2 = crossover(self.SMA_M, self.SMA_S)
        
        if not self.position:
            # 多單進場
            if (SMA_S > SMA_M > SMA_L and
                close > SMA_L and
                cond_1
                ):
                self.buy(size=self.contract_size)
                return

            # 空單進場
            if (SMA_S < SMA_M < SMA_L and
                close < SMA_L and
                cond_2
                ):
                self.sell(size=self.contract_size)
                return
        else:
            # 多單出場
            if self.position.is_long:
                if cond_2:
                    self.position.close()
                    return
    
            # 空單出場
            if self.position.is_short:
                if cond_1:
                    self.position.close()
                    return