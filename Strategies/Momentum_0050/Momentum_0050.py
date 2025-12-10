#%% 1
# import numpy as np
import pandas as pd
# import yfinance as yf

tickers = (
    pd.read_excel(r"C:\Users\Jimmy\Desktop\策略\Momentum_0050\2025Q3_0050_constituents.xlsx")["ticker"]
    .iloc[:30]
    .sort_values()
    )
tickers = [f"{t}.TW" for t in tickers]

#
# prices = yf.download(tickers, start='2016-01-01', end='2025-12-01', auto_adjust=False)
# prices = prices['Adj Close']
# prices.to_excel("prices_python.xlsx")

df = pd.read_excel("prices_python.xlsx", index_col=0)
df.columns = df.columns.str.replace(r'\.TW$', '', regex=True)
df = df.sort_index().ffill()

# check
print(df.isna().sum()[df.isna().sum() > 0])
print(df['6669'][df['6669'].isna()].tail(10)) # 2017-11-10

return_df = (
    df
    .loc["2017-11-30":]
    .pct_change()
    .dropna()
)
# return_df:  2017-12-01 ~ 2025-11-28 完整96個月
month_return_df = (
    return_df
    .copy()
    .resample("ME")
    .agg(lambda x: (x+1).prod() - 1)
)
#%% 2
# aa = pd.Series(range(1,5+1))
# aa.shift(1).rolling(3).apply(lambda x: (1 + x).prod - 1)

# bb = pd.DataFrame(dict(x=range(1,5+1), y=range(11,15+1)))
# bb.shift(1).rolling(3).apply(lambda x: (x+1).prod() - 1)
N=3
past_Nm_return_df = (
    month_return_df
    .copy()
    .shift(1)
    .rolling(N)
    .apply(lambda x: (x+1).prod() - 1)
    .dropna()
)
da = pd.DataFrame(past_Nm_return_df.iloc[0])
da["group"] = pd.qcut(da.iloc[:, 0], 5, labels=False)

long_stocks  = da[da['group'] == 4].index.tolist()
short_stocks = da[da['group'] == 0].index.tolist()

date_str = past_Nm_return_df.index[0].strftime('%Y-%m-%d')

x = month_return_df.loc[date_str].loc[long_stocks].mean()
y = month_return_df.loc[date_str].loc[short_stocks].mean()
print(round(x - y, 4))

z = month_return_df.loc[date_str].mean()
print(round(z, 4))
#%% f1
def f1(N):
    past_Nm_return_df = (
        month_return_df
        .copy()
        .shift(1)
        .rolling(N)
        .apply(lambda x: (x+1).prod() - 1)
        .dropna()
    )
    
    momentum_ret = []
    buy_and_hold_ret = []

    for i in range(len(past_Nm_return_df)):
        da = pd.DataFrame(past_Nm_return_df.iloc[i])
        da["group"] = pd.qcut(da.iloc[:, 0], 5, labels=False)

        long_stocks  = da[da['group'] == 4].index.tolist()
        short_stocks = da[da['group'] == 0].index.tolist()
        
        date_str = past_Nm_return_df.index[i].strftime('%Y-%m-%d')

        x = month_return_df.loc[date_str].loc[long_stocks].mean()
        y = month_return_df.loc[date_str].loc[short_stocks].mean()
        momentum_ret.append(x - y)

        z = month_return_df.loc[date_str].mean()
        buy_and_hold_ret.append(z)
    
    num1 = sum(x > y for x, y in zip(momentum_ret, buy_and_hold_ret))
    num2 = len(momentum_ret)
    ratio = num1 / num2
    print(f"N: {N}, momentum 贏 buy-and-hold 比例: {num1}/{num2}= {ratio:.1%}")
for N in [2,3,4,5,6]:
    f1(N)
#%% f2
aa = pd.Series(range(1,10+1))
aa.shift(2).rolling(3).sum()

def f2(N):
    past_Nm_return_df = (
        month_return_df
        .copy()
        .shift(2)
        .rolling(N)
        .apply(lambda x: (x+1).prod() - 1)
        .dropna()
    )
    
    momentum_ret = []
    buy_and_hold_ret = []

    for i in range(len(past_Nm_return_df)):
        da = pd.DataFrame(past_Nm_return_df.iloc[i])
        da["group"] = pd.qcut(da.iloc[:, 0], 5, labels=False)

        long_stocks  = da[da['group'] == 4].index.tolist()
        short_stocks = da[da['group'] == 0].index.tolist()
        
        date_str = past_Nm_return_df.index[i].strftime('%Y-%m-%d')

        x = month_return_df.loc[date_str].loc[long_stocks].mean()
        y = month_return_df.loc[date_str].loc[short_stocks].mean()
        momentum_ret.append(x - y)

        z = month_return_df.loc[date_str].mean()
        buy_and_hold_ret.append(z)
    
    num1 = sum(x > y for x, y in zip(momentum_ret, buy_and_hold_ret))
    num2 = len(momentum_ret)
    ratio = num1 / num2
    print(f"N: {N}, momentum 贏 buy-and-hold 比例: {num1}/{num2}= {ratio:.1%}")
for N in [2,3,4,5,6]:
    f2(N)