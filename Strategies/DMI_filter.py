#%% load modules
from backtesting import Strategy
from backtesting.lib import crossover
from ta.trend import ADXIndicator, sma_indicator
import pandas as pd

class DMIFilterStrategy(Strategy):
    stoploss_pct = 2
    value = 20
    start_date = 20210601
    contract_size = 200
    
    def init(self):
        high = pd.Series(self.data.High, index=self.data.index)
        low = pd.Series(self.data.Low, index=self.data.index)
        close = pd.Series(self.data.Close, index=self.data.index)

        # DMI
        adx_object = ADXIndicator(high=high, low=low, close=close, window=14)
        self.pDI = self.I(adx_object.adx_pos)
        self.nDI = self.I(adx_object.adx_neg)

        # macd_dif (use SMA instead of EMA)
        def macd_dif(close):
            dif = sma_indicator(close, window=12) - sma_indicator(close, window=26)
            dem = sma_indicator(dif, window=9)
            return dif - dem
        
        self.macd_dif = self.I(macd_dif, close)

        self.daily_high = None
        self.daily_low = None
        
        self.entry_price = None
        self.stoploss_price = None
        
    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        
        high = self.data.High
        low = self.data.Low
        close = self.data.Close[-1]
        macd_dif = self.macd_dif
        
        if self.data.time[-1] == 845:
            self.daily_high = None
            self.daily_low = None
        
        if self.data.time[-1] == 905:
            self.daily_high = self.data.High[-3:].max()
            self.daily_low = self.data.Low[-3:].min()
        

        if (not self.position) and (self.daily_high is not None) and (len(self.data.Close) >= 4):
            # 多單進場
            if (close > self.daily_high and
                macd_dif[-3] < macd_dif[-2] < macd_dif[-1] and
                high[-1] >= high[-4:-1].max() + self.value and
                crossover(self.pDI, self.nDI)
            ):
                self.buy(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = close * (1 - self.stoploss_pct * 0.01)
                return

            # 空單進場
            if (close < self.daily_low and
                macd_dif[-3] > macd_dif[-2] > macd_dif[-1] and
                low[-1] <= low[-4:-1].min() - self.value and
                crossover(self.nDI, self.pDI)
            ):
                self.sell(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = close * (1 + self.stoploss_pct * 0.01)
                return

        # 移動停損
        if self.position:
            # 多單
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

            # 空單
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
