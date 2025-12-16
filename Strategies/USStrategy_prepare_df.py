def prepare_df():
    import yfinance as yf
    from numpy import log
    import pandas as pd
    
    def fetch_index_returns(symbols, method="pct"):
        df = yf.download(symbols, start="2018-12-25")["Close"]
    
        df.columns = df.columns.get_level_values(0)
        df.columns.name = None
    
        if method == "pct":
            df = df.pct_change()
        elif method == "log":
            df = log(df / df.shift(1))
        else:
            raise ValueError("method must be 'pct' or 'log'")
    
        df = df.reset_index()
        df = df.dropna()
        df.columns = df.columns.str.lstrip('^')
        return df
    
    symbols = ["^DJI", "^IXIC", "^GSPC", "^SOX", "TSM"]
    
    df1 = fetch_index_returns(symbols)
    # df1.to_csv("daily_market.csv", index=False)
    
    # df1 = pd.read_csv("daily_market.csv")
    df2 = pd.read_csv("5min_data_FITX_1.TF.log", sep=" ", usecols=range(8-1))
    
    df1['Date'] = pd.to_datetime(df1['Date'])
    
    df2['date_dt'] = pd.to_datetime(df2['date'].astype(str))
    df2['match_date'] = df2['date_dt'] - pd.Timedelta(days=1)
    
    df = pd.merge_asof(
        df2.sort_values('match_date'),
        df1.sort_values('Date'),
        left_on='match_date',
        right_on='Date',
        direction='backward'
    )
    
    df.drop(columns=['date_dt', 'match_date', 'Date'], inplace=True)
    # rows_with_na = df[df.isna().any(axis=1)]
    # print(rows_with_na)
    
    df["time"] = df["time"].astype(str).str.zfill(4)
    df["datetime"] = pd.to_datetime(
        df["date"].astype(str) + df["time"], format="%Y%m%d%H%M"
    )
    df = df.set_index("datetime")
    df.sort_index(inplace=True)
    df.drop(columns=['date', 'time'], inplace=True)
    df = df.rename(columns={
        "open": "Open",
        "high": "High",
        "low": "Low",
        "close": "Close",
        "volume": "Volume"
    })
    return df
'''
subset = df[['TSM', 'DJI', 'GSPC', 'IXIC', 'SOX']]
print(subset.max().round(2),'\n')
print(subset.min().round(2))
filtered_df = df[df['TSM'] < -0.1]
print(filtered_df.groupby(filtered_df.index.date).head(1))
filtered_df = df[df['DJI'] < -0.1]
print(filtered_df.groupby(filtered_df.index.date).head(1))


'''