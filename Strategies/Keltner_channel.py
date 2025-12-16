from backtesting import Strategy
import pandas as pd
from ta.volatility import AverageTrueRange

def SMA(values, n):
    return pd.Series(values).rolling(n).mean()

def calc_ATR(high, low, close, window):
    return AverageTrueRange(pd.Series(high), pd.Series(low), pd.Series(close), window).average_true_range()

def calc_upper(sma, atr, mult):
    return sma + mult * atr

def calc_lower(sma, atr, mult):
    return sma - mult * atr

class Keltner_channel_strategy(Strategy):
    ma_period = 20
    atr_period = 14
    atr_mult_upper = 1.5
    atr_mult_lower = 1.5
    stoploss_pct_long = 2
    stoploss_pct_short = 2
    _short = True
    
    start_date = 20210601
    contract_size = 200
    
    def init(self):
        high = pd.Series(self.data.High, index=self.data.index)
        low = pd.Series(self.data.Low, index=self.data.index)
        close = pd.Series(self.data.Close, index=self.data.index)
        
        self.atr = self.I(calc_ATR, high, low, close, self.ma_period, name="ATR")
        self.middle = self.I(SMA, close, self.atr_period, name="middle")
        self.upper = self.I(calc_upper, self.middle, self.atr, self.atr_mult_upper, name="upper")
        self.lower = self.I(calc_lower, self.middle, self.atr, self.atr_mult_lower, name="lower")
        
        self.entry_price = None
        self.stoploss_price = None
        
    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        
        high = self.data.High
        low = self.data.Low
        close = self.data.Close
        upper = self.upper
        lower = self.lower
        middle = self.middle
        
        if not self.position:
            # 多單進場
            if (middle[-3] < close[-3] < upper[-3] and
                upper[-2] < close[-2] and
                upper[-1] < close[-1] and high[-2] < close[-1]
            ):
                self.buy(size=self.contract_size)
                self.entry_price = close[-1]
                self.stoploss_price = close[-1] * (1 - self.stoploss_pct_long * 0.01)
                return

            # 空單進場
            if self._short:
                if (lower[-3] < close[-3] < middle[-3] and
                    close[-2] < lower[-2] and
                    close[-1] < lower[-1] and close[-1] < low[-2]
                ):
                    self.sell(size=self.contract_size)
                    self.entry_price = close[-1]
                    self.stoploss_price = close[-1] * (1 + self.stoploss_pct_short * 0.01)
                    return

        else:
            close = self.data.Close[-1]
            
            # 多單移動停損
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

            # 空單移動停損
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