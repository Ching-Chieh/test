import backtrader as bt
from backtrader.indicators import SimpleMovingAverage, DMI
import pandas as pd

class SMA_MACD(bt.Indicator):
    lines = ('macd_dif',)
    params = (
        ('fast', 12),
        ('slow', 26),
        ('signal', 9),
    )

    def __init__(self):
        sma_fast = SimpleMovingAverage(self.datas[0], period=self.p.fast)
        sma_slow = SimpleMovingAverage(self.datas[0], period=self.p.slow)

        dif = sma_fast - sma_slow
        dem = SimpleMovingAverage(dif, period=self.p.signal)

        self.lines.macd_dif = dif - dem


class DMIFilterStrategy(bt.Strategy):
    params = dict(
        stoploss_pct=2,
        value=20,
    )

    def __init__(self):
        dmi = DMI(self.datas[0], period=14)
        self.pDI = dmi.plusDI
        self.nDI = dmi.minusDI
        
        self.macd = SMA_MACD(self.datas[0].close)
        
        self.datahigh = self.datas[0].high
        self.datalow = self.datas[0].low
        self.dataclose = self.datas[0].close

        self.daily_high = None
        self.daily_low = None

        self.entry_price = None
        self.stoploss_price = None

    def next(self):
        t = self.datas[0].datetime.time(0)

        if t.hour == 8 and t.minute == 45:
            self.daily_high = None
            self.daily_low = None

        if t.hour == 9 and t.minute == 5:
            self.daily_high = max(datahigh.get(size=3))
            self.daily_low = min(datalow.get(size=3))

        if not (self.position and self.daily_high):
            if len(self.macd.macd_dif) >= 3:

                # 多單
                if (dataclose[0] > self.daily_high and
                    macd_dif[-2] < macd_dif[-1] < macd_dif[0] and
                    datahigh[0] >= max(datahigh.get(size=4)[:3]) + self.p.value and
                    self.pDI[0] > self.nDI[0]):

                    self.buy(size=200)
                    self.entry_price = dataclose[0]
                    self.stoploss_price = dataclose[0] * (1 - self.p.stoploss_pct / 100)
                    return

                # 空單
                if (dataclose[0] < self.daily_low and
                    macd_dif[-2] > macd_dif[-1] > macd_dif[0] and
                    datalow[0] <= min(datalow.get(size=4)[:3]) - self.p.value and
                    self.pDI[0] < self.nDI[0]):

                    self.sell(size=200)
                    self.entry_price = dataclose[0]
                    self.stoploss_price = dataclose[0] * (1 + self.p.stoploss_pct / 100)
                    return

        # 移動停損
        if self.position:

            if self.position.size > 0:  # 多單
                if dataclose[0] > self.entry_price:
                    new_stop = dataclose[0] * (1 - self.p.stoploss_pct / 100)
                    self.stoploss_price = max(self.stoploss_price, new_stop)

                if dataclose[0] <= self.stoploss_price:
                    self.close()
                    self.stoploss_price = None
                    return

            elif self.position.size < 0:  # 空單
                if dataclose[0] < self.entry_price:
                    new_stop = dataclose[0] * (1 + self.p.stoploss_pct / 100)
                    self.stoploss_price = min(self.stoploss_price, new_stop)

                if dataclose[0] >= self.stoploss_price:
                    self.close()
                    self.stoploss_price = None
                    return
