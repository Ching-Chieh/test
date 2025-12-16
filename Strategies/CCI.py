#%% load modules
from backtesting import Strategy
from ta.trend import CCIIndicator
import pandas as pd

class CCI_strategy(Strategy):
    # CCI 向上突破 AA (-120) 作多，CCI 向上突破 BB (-70) 出場
    # CCI 向下跌破 DD (120) 作空，CCI 向下跌破  CC (70) 出場
    DD = 120
    CC = 70
    BB = -70
    AA = -120
    cci_window = 10
    _short = True
    
    start_date = 20210601 # 回測起始日期
    contract_size = 200
    
    def init(self):
        high = pd.Series(self.data.High, index=self.data.index)
        low = pd.Series(self.data.Low, index=self.data.index)
        close = pd.Series(self.data.Close, index=self.data.index)
        CCI_object = CCIIndicator(high, low, close, self.cci_window)
        self.cci = self.I(CCI_object.cci, name='CCI')
        
    def next(self):
        if self.data.index[-1] < pd.to_datetime(self.start_date, format='%Y%m%d'):
            return
        if not (self.AA < self.BB < self.CC < self.DD):
            return
        
        # 進場
        if not self.position:
            # CCI(cci_n) cross above AA;
            long_entry_condition = self.cci[-2] < self.AA and self.cci[-1] > self.AA
            # CCI(cci_n) cross below DD;
            short_entry_condition = self.cci[-2] > self.DD and self.cci[-1] < self.DD
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
            # CCI(cci_n) cross above BB;
            if self.position.is_long:
                if self.cci[-2] < self.BB and self.cci[-1] > self.BB:
                    self.position.close()
                    return

            # 空單
            # CCI(cci_n) cross below CC;
            if self.position.is_short:
                if self.cci[-2] > self.CC and self.cci[-1] < self.CC:
                    self.position.close()
                    return
