#%% load modules
from backtesting import Strategy
from ta.momentum import RSIIndicator
import pandas as pd

class Multi_RSI_strategy(Strategy):
    # 多方策略: 30分RSI 突破 60(B)買進，5分RSI 跌破 75(A)出場
    # 空方策略: 30分RSI 跌破 40(C)放空，5分RSI 突破 25(D)回補
    A = 75
    B = 60
    C = 40
    D = 25
    rsi_window_5min = 14
    rsi_window_30min = 14
    _short = False
    
    start_date = 20210601 # 回測起始日期
    contract_size = 200
    
    def init(self):
        close = pd.Series(self.data.Close, index=self.data.index)
        RSI_object = RSIIndicator(close, self.rsi_window_5min)
        self.rsi5 = self.I(RSI_object.rsi, name='rsi5')
        
        df5 = self.data.df[['date', 'time5', 'Close', 'time30']].copy() # datetime index, date, time5, Close, time30
        
        df30 = (
            df5
            .groupby(["date", "time30"])
            .agg(close30=("Close", "last"))
            .reset_index()
        )
        df30['rsi30'] = RSIIndicator(df30["close30"], self.rsi_window_30min).rsi()
        da = df5.merge(df30, how='left', left_on=["date", "time5"], right_on=["date", "time30"])
        da = da[['date', 'time5', 'rsi30']]
        da['rsi30'] = da['rsi30'].ffill()
        da["datetime"] = pd.to_datetime(da["date"].astype(str) + da["time5"].astype(str).str.zfill(4), format="%Y%m%d%H%M")
        da.set_index("datetime", inplace=True)
        rsi30 = da['rsi30']
        
        self.rsi30 = self.I(lambda x: x, rsi30, name='rsi30')
        
    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        if not (self.A > self.B > self.C > self.D):
            return
        
        # 進場
        if not self.position:
            # xfMin_RSI("30", GetField("Close","30"), 14) cross above 60(B);
            long_entry_condition = self.rsi30[-2] < self.B and self.rsi30[-1] > self.B
            # xfMin_RSI("30", GetField("Close","30"), 14) cross below 40(C);
            short_entry_condition = self.rsi30[-2] > self.C and self.rsi30[-1] < self.C
            # 多單
            if long_entry_condition:
                self.buy(size=self.contract_size)
                return
            
            # 空單
            if self._short and short_entry_condition:
                self.sell(size=self.contract_size)
                return
        
        # 出場
        else:
            # 多單
            if self.position.is_long:
                # RSI(close, 14) cross below 75(A);
                if self.rsi5[-2] > self.A and self.rsi5[-1] < self.A:
                    self.position.close()
                    return

            # 空單
            if self.position.is_short:
                # RSI(close, 14) cross above 25(D);
                if self.rsi5[-2] < self.D and self.rsi5[-1] > self.D:
                    self.position.close()
                    return
