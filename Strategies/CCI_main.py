#%% load modules
from backtesting import Backtest
import pandas as pd
from CCI import CCI_strategy
#%% functions
def prepare_df(df):
    df["date"] = pd.to_datetime(df['date'], format='%Y%m%d')
    df.set_index("date", drop=False, inplace=True)
    df.sort_index(inplace=True)
    df = df.rename(columns={
        "open": "Open",
        "high": "High",
        "low": "Low",
        "close": "Close"
    })

    return df[["date", "Open", "High", "Low", "Close"]]

def generate_df_trades(trades):
    trades = trades[['Size', 'EntryBar', 'ExitBar', 'EntryPrice', 'ExitPrice',
                   'Entry_CCI', 'PnL']].rename(columns={
                   "Size": "type",
                   "Entry_CCI": "CCI",
                   "PnL": 'Profit or loss'
            })
    trades['type'] = trades['type'].replace({200: 'long', -200: 'short'})
    trades = pd.merge(trades, df[['date']].assign(EntryBar=range(len(df))), on='EntryBar', how='inner')
    trades = trades[['type', 'date', 'EntryPrice', 'ExitPrice', 'CCI', 'Profit or loss', 'EntryBar', 'ExitBar']]
    trades['CCI'] = trades['CCI'].round(1)
    return trades
#%% bt
df = pd.read_excel("day_data_FITX_1.TF.xlsx", usecols=range(5)) # 20190102 ~ 20251031
df = prepare_df(df) # 回測起始日期: 20210601

cash = 1_000_000_000
bt = Backtest(df, CCI_strategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% sambo
stats, heatmap, optimize_result = bt.optimize(
    DD=[80, 130],    # 100
    CC=[30, 70],     # 50
    BB=[-70, -30],   # -50
    AA=[-120, -80],  # -100
    cci_window=[5, 20],
    constraint=lambda p: p.AA < p.BB < p.CC < p.DD,
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
stats = bt.run(DD = 128, CC = 48, BB = -46, AA = -97, cci_window = 8)
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

