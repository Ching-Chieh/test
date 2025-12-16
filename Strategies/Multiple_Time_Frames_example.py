#%% functions
import pandas as pd
import numpy as np

def SMA(array, n):
    return pd.Series(array).rolling(n).mean()

def RSI(price: pd.Series, window: int) -> pd.Series:
    price_change = price.diff()

    gain = price_change.clip(lower=0)
    loss = -price_change.clip(upper=0)

    roll_gain = gain.rolling(window).sum()
    roll_loss = loss.rolling(window).sum()

    rsi = np.where(
        roll_gain + roll_loss == 0,
        0,
        roll_gain / (roll_gain + roll_loss) * 100
    )
    return pd.Series(rsi, index=price.index)
#%% System
from backtesting import Strategy, Backtest

class System(Strategy):
    d_rsi = 30
    w_rsi = 30
    level = 70
    
    def init(self):
        self.ma10 = self.I(SMA, self.data.Close, 10)
        self.ma20 = self.I(SMA, self.data.Close, 20)
        self.ma50 = self.I(SMA, self.data.Close, 50)
        self.ma100 = self.I(SMA, self.data.Close, 100)
        
        close = pd.Series(self.data.Close, index=self.data.index)
        self.daily_rsi = self.I(RSI, close, self.d_rsi)
        
        df_daily = self.data.df[['Close']].copy() # datetime index, Close
        
        df_daily['date'] = df_daily.index
        df_daily['year'] = df_daily['date'].dt.year
        df_daily['week'] = df_daily['date'].dt.isocalendar().week
        df_weekly = (
            df_daily
            .groupby(["year", "week"])
            .agg(close_weekly=("Close", "last"))
            .reset_index()
        )
        df_weekly['rsi_weekly'] = RSI(df_weekly["close_weekly"], self.w_rsi)
        df_weekly = df_weekly[['year', 'week', 'rsi_weekly']]

        da = df_daily.merge(df_weekly, how='left', on=["year", "week"])
        da['rsi_weekly'] = da['rsi_weekly'].ffill()
        da.set_index('date', inplace=True) # datetime index, Close, year, week, rsi_weekly
        rsi_weekly = da['rsi_weekly']
        
        self.weekly_rsi = self.I(lambda x: x, rsi_weekly, name="weekly_rsi")
        
    def next(self):
        price = self.data.Close[-1]
        
        if (not self.position and
            self.daily_rsi[-1] > self.level and
            self.weekly_rsi[-1] > self.level and
            self.weekly_rsi[-1] > self.daily_rsi[-1] and
            self.ma10[-1] > self.ma20[-1] > self.ma50[-1] > self.ma100[-1] and
            price > self.ma10[-1]):
            
            self.buy(sl=.92 * price)
        
        elif price < .98 * self.ma10[-1]:
            self.position.close()
#%% backtesting
from backtesting.test import GOOG
bt = Backtest(GOOG, System, commission=.002, finalize_trades=True)
#%% sambo
stats, heatmap, optimize_result = bt.optimize(
    d_rsi=[10, 35],
    w_rsi=[10, 35],
    level=[30, 80],
    maximize='Equity Final [$]',
    method='sambo',
    max_tries=1000,
    random_state=0,
    return_heatmap=True,
    return_optimization=True)
#%% optimize_result
print("\n", optimize_result)
print(heatmap.sort_values().iloc[-3:])
print("\nNumber of trades=", len(stats['_trades']))
print(f"SQN= {stats.SQN:.2f}")
print(f"Net profit= {stats['Equity Final [$]']-10000:,.0f}")
print(f"Final equity= {stats['Equity Final [$]']:,.0f}")
#%% run
stats = bt.run(d_rsi=30, w_rsi=10, level=58)
print("\nNumber of trades=", len(stats['_trades']))
print(f"SQN= {stats.SQN:.2f}")
print(f"Net profit= {stats['Equity Final [$]']-10000:,.0f}")
print(f"Final equity= {stats['Equity Final [$]']:,.0f}")
