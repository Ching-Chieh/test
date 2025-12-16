#%%
import pandas as pd
import numpy as np

def calc_rsi(price, window):
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


def time_to_freq(time_series, frequency):
    min845 = 8 * 60 + 45

    h = time_series // 100
    m = time_series % 100
    total_min = h * 60 + m

    t2 = ((total_min - min845) // frequency) * frequency + min845

    return (t2 // 60) * 100 + (t2 % 60)


df_5 = pd.read_csv("5min_data_FITX_1.TF.log", sep=" ", usecols=range(7))
df_5 = df_5.rename(columns={col: col + "5" for col in df_5.columns if col != "date"})

rsi_window = 6
freq = 30

df_5["rsi5"] = calc_rsi(df_5["close5"], rsi_window)
df_5["time30"] = time_to_freq(df_5["time5"], freq)
grouped = df_5.groupby(["date", "time30"])

df_30 = grouped.apply(
    lambda g: pd.Series({
        "open30": g["open5"].iloc[0],
        "high30": g["high5"].max(),
        "low30":  g["low5"].min(),
        "close30": g["close5"].iloc[-1],
        "volume30": g["volume5"].sum()
    })
).reset_index()

df_30["rsi30"] = calc_rsi(df_30["close30"], window=rsi_window)

print(df_5)
print(df_30)

#%% polars
import polars as pl
import numpy as np

def calc_rsi_pl(df: pl.DataFrame, col: str, window: int, out_col: str):
    return df.with_columns([
        (pl.col(col).diff().clip(lower_bound=0)).rolling_sum(window).alias("gain"),
        (-pl.col(col).diff().clip(upper_bound=0)).rolling_sum(window).alias("loss"),
    ]).with_columns([
        pl.when(pl.col("gain") + pl.col("loss") == 0)
          .then(0)
          .otherwise(pl.col("gain") / (pl.col("gain") + pl.col("loss")) * 100)
          .alias(out_col)
    ]).drop(["gain", "loss"])


def time_to_freq_pl(df, time_col: str, freq: int):
    tmp = 8 * 60 + 45
    return df.with_columns([
        (
            (
                (
                    (((pl.col(time_col) // 100) * 60 + (pl.col(time_col) % 100)) - tmp) // freq
                ) * freq + tmp
            ).alias("t2")
        )
    ]).with_columns([
        ((pl.col("t2") // 60) * 100 + (pl.col("t2") % 60)).alias("time30")
    ]).drop("t2")


df_5 = pl.read_csv("long_5min_data_FITX_1.TF.log", separator=" ", has_header=True).drop("")


df_5 = df_5.rename({col: col + "5" for col in df_5.columns if col != "date"})
df_5 = calc_rsi_pl(df_5, "close5", 6, "rsi5")
df_5 = time_to_freq_pl(df_5, "time5", 30)

df_30 = (
    df_5.group_by(["date", "time30"])
    .agg([
        pl.col("open5").first().alias("open30"),
        pl.col("high5").max().alias("high30"),
        pl.col("low5").min().alias("low30"),
        pl.col("close5").last().alias("close30"),
        pl.col("volume5").sum().alias("volume30"),
    ])
)

df_30 = calc_rsi_pl(df_30, "close30", 6, "rsi30")
print(df_5)
print(df_30)

