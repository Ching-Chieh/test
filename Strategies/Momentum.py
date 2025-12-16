from backtesting import Strategy
import pandas as pd

def SMA(array, period):
    return pd.Series(array).rolling(period).mean()

def Momentum(series, period):
    return series - series.shift(period)

class Momentum_Strategy(Strategy):
    period = 75
    sma_period = 95
    baseline = 20
    
    start_date = 20210601
    contract_size = 200

    def init(self):
        close = pd.Series(self.data.Close, index=self.data.index)
        self.mtm = self.I(Momentum, close, self.period, name='momentum')
        self.sma = self.I(SMA, self.mtm, self.sma_period, name='momentum_sma')

    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        
        # 進場
        if not self.position:
            # mtm cross below baseline
            if self.mtm[-2] > self.baseline and self.mtm[-1] < self.baseline:
                self.buy(size=self.contract_size)
                return

        # 出場
        else:
            # mtm cross below ma
            if self.mtm[-2] > self.sma[-2] and self.mtm[-1] < self.sma[-1]:
                self.position.close()
                return
