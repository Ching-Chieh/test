#%% functions
import pandas as pd
import numpy as np

def plus5(time):
    h = time // 100
    m = time % 100
    m = m + 5
    if m == 60:
        m -= 60
        h += 1
    return h*100 + m

def time_to_freq(series, frequency):
    min845 = 8 * 60 + 45
    min850 = 8 * 60 + 50
    h = series // 100
    m = series % 100
    total_min = h * 60 + m
    t2 = ((total_min - min850) // frequency + 1) * frequency + min845

    return (t2 // 60) * 100 + (t2 % 60)

def calc_rsi(price: pd.Series, window: int) -> pd.Series:
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
#%% 5min_data_FITX_1.TF.log
df_5 = pd.read_csv("5min_data_FITX_1.TF.log", sep=" ", usecols=range(7))
df_5 = df_5.rename(columns={col: col + "5" for col in df_5.columns if col != "date"})
df_5['time5'] = df_5['time5'].map(plus5)

rsi_window = 6
freq = 30

df_30 = (
    df_5
    .assign(time30=time_to_freq(df_5['time5'], 30))
    .groupby(["date", "time30"])
    .agg(
        open30=("open5", "first"),
        high30=("high5", "max"),
        low30=("low5", "min"),
        close30=("close5", "last"),
        volume30=("volume5", "sum")
        )
    .reset_index()
)
df_30['rsi30'] = calc_rsi(df_30["close30"], rsi_window)
df_5["rsi5"] = calc_rsi(df_5["close5"], rsi_window)

da = df_5.merge(df_30, how='left', left_on=["date", "time5"], right_on=["date", "time30"])
da.drop('time30', axis=1, inplace=True)
da[['open30', 'high30', 'low30', 'close30', 'rsi30']] = da[['open30', 'high30', 'low30', 'close30', 'rsi30']].ffill()

da["datetime"] = pd.to_datetime(da["date"].astype(str) + da["time5"].astype(str).str.zfill(4), format="%Y%m%d%H%M")
da = da.set_index("datetime")
da.sort_index(inplace=True)
da.head(10)










