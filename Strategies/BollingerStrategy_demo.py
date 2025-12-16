from backtesting import Strategy
import pandas as pd
import ta

class BollingerStrategy(Strategy):
    period = 20
    n = 2 # sd倍數
    start_date = 20210601
    contract_size = 200
    

    def init(self):
        # print('init ------------------------------------------------------')
        # print(self.data.index)
        # print(self.data.df.index)
        # print(self.data.time)
        # print(self.data.Close)
        # print(type(self.data.time))  # <class 'backtesting._util._Array'>
        # print(type(self.data.Close)) # <class 'backtesting._util._Array'>
        # print(self.data.pip)
        # print(self.data.date.s)  # pd.Series
        # print(self.data.time.s)  # pd.Series
        # print(self.data.Close.s) # pd.Series
        # print(self.data.df)
        # dict1=self.data.__dict__
        # print(dict1.keys(),'\n')
        # print(dict1['_Data__len'],'\n')
        # dict2 = dict1['_Data__arrays']
        # print(dict2.keys(), '\n')
        # print(dict2['date'], '\n')
        
        # print(dict2['time'])
        # print(type(dict2['time']), '\n')
        
        # print(dict2['Close'])
        # print(type(dict2['Close']), '\n')
        
        # print(dict2['__index'], '\n')
        
        
        
        close = pd.Series(self.data.Close, index=self.data.index)
        
        bb = ta.volatility.BollingerBands(
            close=close,
            window=self.period,
            window_dev=self.n
        )

        self.bb_high = self.I(bb.bollinger_hband, name='bollinger_upper')
        self.bb_low = self.I(bb.bollinger_lband, name='bollinger_lower')
        self.log = ""
        self.last_bar = len(self.data)
        print("last_bar:", self.last_bar)
        
    def next(self):
        # print('next ------------------------------------------------------')
        # print(self.data.index[-1])
        # print(type(self.data.index[-1]))
        if self.data.index[-1] < pd.to_datetime(str(self.start_date), format="%Y%m%d"):
            return
        
        if len(self.data) % 100 == 0:
            closed_pl = sum(trade.pl for trade in self.closed_trades)
            open_pl = sum(
                (self.data.Close[-1] - trade.entry_price) * (1 if trade.is_long else -1)
                for trade in self.trades
            )
    
            net_pl = closed_pl + open_pl
            log = f"\nBar {len(self.data)}: Net P/L = {net_pl:,.0f}"
            self.log += log
            
        
        # for trade in self.trades:
        #     print("Active trade entry price:", trade.entry_price)
        #     print("Active trade entry bar:", trade.entry_bar)
        
        # for trade in self.closed_trades:
        #     print("Closed trade entry price:", trade.entry_price)
        #     print("Closed at bar:", trade.exit_bar)
        
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
        
        if len(self.data) == self.last_bar:
            print(self.log)
#%% load modules
from backtesting import Backtest
#%% functions
def prepare_df(df):
    df["datetime"] = pd.to_datetime(
        df["date"].astype(str) + df["time"].astype(str).str.zfill(4), format="%Y%m%d%H%M"
    )

    df = df.set_index("datetime")
    df.sort_index(inplace=True)
    df = df.rename(columns={
        "open": "Open",
        "high": "High",
        "low": "Low",
        "close": "Close"
    })

    return df[["date", "time", "Open", "High", "Low", "Close"]]
#%% bt
df = pd.read_csv("15min_data_FITX_1.TF.log", sep=" ", usecols=range(6)) # 20190102 845 ~ 20251031 1330
df = prepare_df(df)
df = df[df.index > '2021-04-01'] # 回測起點 日期: 20210601

cash = 1_000_000_000
bt = Backtest(df, BollingerStrategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% try
stats = bt.run()
print("\nNumber of trades:", len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")