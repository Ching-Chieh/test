#%% Strategy
from backtesting import Strategy, Backtest
import ta
import pandas as pd

def SMA(values, n):
    return pd.Series(values).rolling(n).mean()

def MACD_SMA(price, window_fast = 12, window_slow = 26, window_signal = 9):
    macd = SMA(price, window_fast) - SMA(price, window_slow)
    signal = SMA(macd, window_signal)
    macd_hist = macd - signal
    return macd.values, signal.values, macd_hist.values

class MACD_strong_trend_strategy(Strategy):
    window_fast = 12
    window_slow = 26
    window_signal = 9
    stoploss_pct_long = 2
    stoploss_pct_short = 2
    macd_ma_type = "EMA" # "SMA"
    
    start_date = 20210601
    contract_size = 200
    
    
    def init(self):
        close = pd.Series(self.data.Close, index=self.data.index)

        if self.macd_ma_type == "EMA":
            macd_object = ta.trend.MACD(close,
                                        window_fast=self.window_fast,
                                        window_slow=self.window_slow,
                                        window_sign=self.window_signal)
            self.macd = self.I(macd_object.macd, name="macd")
            self.signal = self.I(macd_object.macd_signal, name="signal")
            self.macd_hist = self.I(macd_object.macd_diff, name="macd_hist")
        
        elif self.macd_ma_type == "SMA":
            self.macd, self.signal, self.macd_hist = self.I(MACD_SMA,
                                                            close,
                                                            window_fast=self.window_fast,
                                                            window_slow=self.window_slow,
                                                            window_signal=self.window_signal,
                                                            name=["macd", "signal", "macd_hist"]) 
        
        self.entry_price = None
        self.stoploss_price = None
        
    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        if self.window_fast >= self.window_slow:
            return
        
        close = self.data.Close[-1]

        if not self.position:
            # 多單進場
            if self.macd[-1] > 0 and self.signal[-1] > 0 and self.macd_hist[-1] > 0:
                self.buy(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = close * (1 - self.stoploss_pct_long * 0.01)
                return

            # 空單進場
            if self.macd[-1] < 0 and self.signal[-1] < 0 and self.macd_hist[-1] < 0:
                self.sell(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = close * (1 + self.stoploss_pct_short * 0.01)
                return

        # 移動停損
        else:
            # 多單
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

            # 空單
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
    trades = trades[['Size', 'EntryBar', 'ExitBar', 'EntryPrice', 'ExitPrice',
                   'Entry_macd', 'Entry_signal', 'Entry_macd_hist', 'PnL']].rename(columns={
                   "Size": "type",
                   "Entry_macd": "macd",
                   "Entry_signal": "signal",
                   "Entry_macd_hist": "macd_hist",
                   "PnL": 'Profit or loss'
            })
    trades['type'] = trades['type'].replace({200: 'long', -200: 'short'})
    trades = pd.merge(trades, df[['date']].assign(EntryBar=range(len(df))), on='EntryBar', how='inner')
    trades = trades[['type', 'date', 'EntryPrice', 'ExitPrice', 'macd', 'signal', 'macd_hist', 'Profit or loss', 'EntryBar', 'ExitBar']]
    trades[['macd', 'signal', 'macd_hist']] = trades[['macd', 'signal', 'macd_hist']].round(1)
    return trades
#%% bt
df = pd.read_csv("10min_data_FITX_1.TF.log", sep = " ", usecols=range(6))
df = prepare_df(df) # 回測起始日期: 20210601
df = df[df.index >= '2021-04-01']

cash = 1_000_000_000
bt = Backtest(df, MACD_strong_trend_strategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% try
stats = bt.run()
print("\nNumber of trades=", len(stats._trades))
df_trades = generate_df_trades(stats._trades)
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% sambo
stats, heatmap, optimize_result = bt.optimize(
    window_fast=[3, 40],     # 12
    window_slow=[3, 50],     # 26
    window_signal=[3, 50],   # 9
    stoploss_pct_long=[0.2, 3],
    stoploss_pct_short=[0.2, 3],
    constraint=lambda p: p.window_fast < p.window_slow,
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
#%% summary
stats = bt.run(window_fast = 12, window_slow = 26, window_signal = 9, stoploss_pct_long = 2, stoploss_pct_short = 2)
df_trades = generate_df_trades(stats._trades)
# 毛利
gross_profit = df_trades[df_trades['Profit or loss'] > 0]['Profit or loss'].sum()
# 毛損
gross_loss = df_trades[df_trades['Profit or loss'] < 0]['Profit or loss'].sum()
# 淨利
net_profit = gross_profit + gross_loss
# 多單損益
PL_long = df_trades[df_trades['type'] == 'long']['Profit or loss'].sum()
# 空單損益
PL_short = df_trades[df_trades['type'] == 'short']['Profit or loss'].sum()
def sign(x):
    return 1 if x > 0 else -1 if x < 0 else 0
# 獲利因子 = 毛利/ABS(毛損)×SIGN(淨利)
profit_factor = gross_profit/abs(gross_loss)*sign(net_profit)
# 交易次數
number_of_trades = len(df_trades)
# 獲利交易次數
number_of_winning_trades = len(df_trades[df_trades['Profit or loss'] > 0])
# 虧損交易次數
number_of_losing_trades = len(df_trades[df_trades['Profit or loss'] < 0])
# 勝率
win_rate = number_of_winning_trades / number_of_trades
# 賺賠比 = ABS(平均獲利交易/平均虧損交易), 平均獲利交易=毛利/獲利交易次數
reward_risk_ratio = abs((gross_profit/number_of_winning_trades) / (gross_loss/number_of_losing_trades))
# 最大區間虧損 max_drawdown
def calc_max_drawdown(PL: pd.Series):
    cumulative_PL = PL.cumsum()
    cum_max = cumulative_PL.cummax()
    drawdown = cum_max - cumulative_PL
    max_drawdown = drawdown.max()
    return max_drawdown
max_drawdown = calc_max_drawdown(df_trades['Profit or loss'])
print(f"\nNet Profit= {net_profit:,.0f}")
print(f"Profit Factor= {profit_factor:.2f}")
print("Number of trades=", number_of_trades)
print(f"Win rate= {win_rate:.2%}")
print(f"Reward-risk ratio= {reward_risk_ratio:.2f}")
print(f"Max drawdown= {max_drawdown:,.0f}")
print(f"Profit for long trades= {PL_long:,.0f}")
print(f"Profit for short trades= {PL_short:,.0f}")
print(f"SQN= {stats.SQN:.2f}")

