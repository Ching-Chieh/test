#%% load modules
from backtesting import Strategy
from backtesting.lib import crossover
import pandas as pd

class Donchian_Channel_Strategy(Strategy):
    n_long = 20
    n_short = 10
    start_date = 20210601 # 回測起點 日期
    
    def init(self):
        
        self.upper_long = self.I(lambda h: pd.Series(h).shift(1).rolling(self.n_long).max(), self.data.High)
        self.lower_long = self.I(lambda l: pd.Series(l).shift(1).rolling(self.n_long).min(), self.data.Low)

        self.upper_short = self.I(lambda h: pd.Series(h).shift(1).rolling(self.n_short).max(), self.data.High)
        self.lower_short = self.I(lambda l: pd.Series(l).shift(1).rolling(self.n_short).min(), self.data.Low)

    def next(self):
        if self.n_short >= self.n_long:
            return
        if self.data.index[-1] < pd.to_datetime(str(self.start_date), format="%Y%m%d"):
            return

        if not self.position:
            # 多單進場
            # close cross above upper_long
            if crossover(self.data.Close, self.upper_long):
                self.buy(size=200)
                return
            '''
            # 空單進場
            # close cross below lower_long
            if crossover(self.lower_long, self.data.Close):
                self.sell(size=200)
                return
            '''
        else:
            # 多單出場
            # close cross below lower_short
            if self.position.is_long:
                if crossover(self.lower_short, self.data.Close):
                    self.position.close()
                    return
            '''
            # 空單出場
            # close cross above upper_short
            if self.position.is_short:
                if crossover(self.data.Close, self.upper_short):
                    self.position.close()
                    return
            '''