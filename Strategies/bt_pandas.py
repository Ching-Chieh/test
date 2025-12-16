import datetime
import backtrader as bt
import backtrader.feeds as btfeeds


import pandas as pd
df = pd.read_csv("10min_data_FITX_1.TF.log", sep=" ", usecols=range(7))
df["date"] = pd.to_datetime(
    df["date"].astype(str) + df["time"].astype(str).str.zfill(4), format="%Y%m%d%H%M"
)
df.drop('time', inplace=True, axis=1)
data = bt.feeds.PandasData(
    dataname=df,
    open='open',
    high='high',
    low='low',
    close='close',
    volume='volume',
    openinterest=-1
)
cerebro = bt.Cerebro()
cerebro.adddata(data)

for i in range(5):
    print('Date:', data.datetime.date(i),
          'Open:', data.open[i],
          'High:', data.high[i],
          'Low:', data.low[i],
          'Close:', data.close[i],
          'Volume:', data.volume[i])