#%% Strategy
from backtesting import Backtest, Strategy
from ta.momentum import WilliamsRIndicator
import pandas as pd

class Williams_strategy(Strategy):
    period = 20
    long_out = -20
    long_in = -40
    short_in = -70
    short_out = -90
    
    start_date = 20210601
    contract_size = 200

    def init(self):
        high = pd.Series(self.data.High, index=self.data.index)
        low = pd.Series(self.data.Low, index=self.data.index)
        close = pd.Series(self.data.Close, index=self.data.index)
        Williams_object = WilliamsRIndicator(high, low, close, self.period)
        self.w = self.I(Williams_object.williams_r, name="Williams")

    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        
        w = self.w
        # 進場
        if not self.position:
            # w cross above long_in
            if w[-2] < self.long_in and w[-1] > self.long_in:
                self.buy(size=self.contract_size)
                return
            # w cross below short_in
            if w[-2] > self.short_in and w[-1] < self.short_in:
                self.sell(size=self.contract_size)
                return

        # 出場
        else:
            # w cross below long_out
            if w[-2] > self.long_out and w[-1] < self.long_out:
                self.position.close()
                return
            # w cross above short_out
            if w[-2] < self.short_out and w[-1] > self.short_out:
                self.position.close()
                return
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

def generate_df_trades(trades):
    trades=trades[['Size', 'EntryBar', 'ExitBar', 'EntryPrice', 'ExitPrice',
                   'Entry_Williams', 'PnL']].rename(columns={
                   "Size": "type",
                   "Entry_Williams": "Williams",
                   "PnL": 'Profit or loss'
            })
    trades['type'] = trades['type'].replace({200: 'long', -200: 'short'})
    trades=trades.merge(df[['date', 'time']].assign(EntryBar=range(len(df))), on='EntryBar', how='left')
    trades=trades.merge(
        df[['date', 'time']]\
            .rename(columns = {'date':'ExitDate', 'time':'ExitTime'})\
            .assign(ExitBar=range(len(df))),
            on='ExitBar', how='left'
        )
    trades=trades[['type', 'date', 'time', 'EntryPrice', 'ExitDate', 'ExitTime', 'ExitPrice', 'Williams', 'Profit or loss']]
    trades['Williams'] = trades['Williams'].round(2)
    return trades
#%% bt
df = pd.read_csv("10min_data_FITX_1.TF.log", sep=" ", usecols=range(6))
df = prepare_df(df)
df = df[df.index > "2021-04-01"]

cash = 1_000_000_000
bt = Backtest(df, Williams_strategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% try
stats = bt.run()
print("\nNumber of trades=", len(stats['_trades']))
print(f"SQN= {stats.SQN:.2f}")
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% sambo
stats, heatmap, optimize_result = bt.optimize(
    period=[3, 50],
    long_out=[-40, -5], #  -20
    long_in=[-49, -30], # -40
    short_in=[-85, -55], # -70
    short_out=[-99, -65], # -90
    constraint=lambda p: p.short_out < p.short_in < p.long_in < p.long_out,
    maximize='Equity Final [$]',
    method='sambo',
    max_tries=1000,
    random_state=0,
    return_heatmap=True,
    return_optimization=True)
#%% best parameters
print("\n", optimize_result)
print(heatmap.sort_values().iloc[-3:])
print("\nNumber of trades=", len(stats['_trades']))
print(f"SQN= {stats.SQN:.2f}")
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%%
stats = bt.run(period = 37, long_out = -39, long_in = -48, short_in = -73, short_out = -82)
print("\nNumber of trades=", len(stats['_trades']))
print(f"SQN= {stats.SQN:.2f}")
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
df_trades = generate_df_trades(stats._trades)
import numpy as np
df_trades["long_in"] = np.where(df_trades["type"] == "long", -48, np.nan)
df_trades["short_in"] = np.where(df_trades["type"] == "short", -73, np.nan)
df_trades = df_trades[['type',
                       'date', 'time', 'EntryPrice',
                       'ExitDate', 'ExitTime', 'ExitPrice',
                       'long_in', 'short_in', 'Williams',
                       'Profit or loss']]
df_trades['Profit or loss'] = df_trades['Profit or loss'] - 82
df_trades.index = range(1, len(df_trades)+1)

