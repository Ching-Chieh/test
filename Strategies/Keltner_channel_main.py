#%% load modules
from backtesting import Backtest
import pandas as pd
from Keltner_channel import Keltner_channel_strategy
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
                     'Entry_ATR', 'Entry_lower', 'Entry_middle', 'Entry_upper', 'PnL']].rename(columns={
                   "Size": "type",
                   "PnL": "Profit or loss",
                   "Entry_ATR": "ATR",
                   "Entry_lower": "lower",
                   "Entry_middle": "middle",
                   "Entry_upper": "upper",
            })
    trades['type'] = trades['type'].replace({200: 'long', -200: 'short'})
    trades = pd.merge(trades, df[['date', 'time']].assign(EntryBar=range(len(df))), on='EntryBar', how='inner')
    trades = trades[['type', 'date', 'time', 'EntryPrice', 'ExitPrice', 'ATR', 'lower', 'middle', 'upper', 'Profit or loss', 'EntryBar', 'ExitBar']]
    trades[['ATR', 'lower', 'middle', 'upper']] = trades[['ATR', 'lower', 'middle', 'upper']].round(1)
    return trades
#%% bt
df = pd.read_csv("30min_data_FITX_1.TF.log", sep=" ", usecols=range(6))
df = prepare_df(df)
df = df[df.index > '2021-04-01'] # 回測起點 日期: 20210601

cash = 1_000_000_000
bt = Backtest(df, Keltner_channel_strategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% try
stats = bt.run()
df_trades = generate_df_trades(stats['_trades'])
print("\nNumber of trades:", len(df_trades))
print(f"Win rate= {(df_trades['Profit or loss'] > 0).sum()/len(df_trades):.0%}")
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% sambo
stats, heatmap, optimize_result = bt.optimize(
    ma_period=[5, 50],
    atr_period=[5, 50],
    atr_mult_upper=[0.5, 3],
    atr_mult_lower=[0.5, 3],
    stoploss_pct_long=[0.5, 3],
    stoploss_pct_short=[0.5, 3],
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
#%% best_params
stats = bt.run(ma_period = 50, atr_period = 42,
               atr_mult_upper = 1.76, atr_mult_lower = 1.62,
               stoploss_pct_long = 3, stoploss_pct_short = 0.5)
df_trades = generate_df_trades(stats._trades)
print("\nNumber of trades=", len(df_trades))
print("Number of long trades=", len(df_trades[df_trades['type'] == 'long']))
print("Number of short trades=", len(df_trades[df_trades['type'] == 'short']))
print(f"SQN= {stats.SQN:.2f}")
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
