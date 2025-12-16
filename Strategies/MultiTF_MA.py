#%%
from backtesting import Strategy
from backtesting.lib import crossover
import pandas as pd

def MultiTF_MA_Strategy_function(df60):
    class MultiTF_MA_Strategy(Strategy):
        fast10 = 18
        slow10 = 20
        fast60 = 50
        slow60 = 58
        
        start_date = 20210601
        contract_size = 200
        
        def init(self):
            close10 = self.data.Close
    
            self.sma_fast_10 = self.I(lambda x: pd.Series(x).rolling(self.fast10).mean(), close10)
            self.sma_slow_10 = self.I(lambda x: pd.Series(x).rolling(self.slow10).mean(), close10)
    
            df60_copy = df60.copy()
    
            df60_copy[f"sma{self.fast60}_60min"] = df60_copy["close"].rolling(self.fast60).mean()
            df60_copy[f"sma{self.slow60}_60min"] = df60_copy["close"].rolling(self.slow60).mean()
    
            df = pd.merge_asof(
                pd.DataFrame({"datetime": self.data.index}),
                df60_copy[["datetime", f"sma{self.fast60}_60min", f"sma{self.slow60}_60min"]],
                on="datetime",
                direction="backward"
            )
    
            self.sma_fast_60 = self.I(lambda x: x, df[f"sma{self.fast60}_60min"])
            self.sma_slow_60 = self.I(lambda x: x, df[f"sma{self.slow60}_60min"])
    
        def next(self):
            if self.data.index[-1] < pd.to_datetime(str(self.start_date), format="%Y%m%d"):
                return
            if self.fast10 >= self.slow10 or self.fast60 >= self.slow60:
                return
            
            long_entry_condition = crossover(self.sma_fast_10, self.sma_slow_10)
            short_entry_condition = crossover(self.sma_slow_10, self.sma_fast_10)
            
            if not self.position:
                if self.sma_fast_60[-1] > self.sma_slow_60[-1] and long_entry_condition:
                    self.buy(size=self.contract_size)
                    return
                elif self.sma_fast_60[-1] < self.sma_slow_60[-1] and short_entry_condition:
                    self.sell(size=self.contract_size)
                    return
            else:
                if self.position.is_long and short_entry_condition:
                    self.position.close()
                    return
                
                elif self.position.is_short and long_entry_condition:
                    self.position.close()
                    return
    return MultiTF_MA_Strategy
