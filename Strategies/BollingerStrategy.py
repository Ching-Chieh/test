from backtesting import Strategy
import pandas as pd
import ta

class BollingerStrategy(Strategy):
    period = 20
    n = 2 # sd倍數
    start_date = 20210601
    contract_size = 200
    

    def init(self):
        close = pd.Series(self.data.Close, index=self.data.index)
        
        bb = ta.volatility.BollingerBands(
            close=close,
            window=self.period,
            window_dev=self.n
        )

        self.bb_high = self.I(bb.bollinger_hband, name='bollinger_upper')
        self.bb_low = self.I(bb.bollinger_lband, name='bollinger_lower')

    def next(self):
        if self.data.index[-1] < pd.to_datetime(str(self.start_date), format="%Y%m%d"):
            return
        
        close = self.data.Close

        if not self.position:
            if close[-2] > self.bb_low[-2] and close[-1] < self.bb_low[-1]:
                self.buy(size=self.contract_size)
                return

        else:
            if self.position.is_long:
                if close[-2] > self.bb_high[-2] and close[-1] < self.bb_high[-1]:
                    self.position.close()
                    return
