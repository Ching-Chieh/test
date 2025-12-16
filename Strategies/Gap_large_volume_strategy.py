#%% 大盤日成交量 TSE_daily_volume: date, TSE_daily_vol
import pandas as pd
TSE_daily_volume = pd.read_excel("Volume_TSE.TW.xlsx") # 20190102 ~ 20251031
#%% 大盤日估計量 TSE_est_volume 在時間點 900, 905, ~ 925: date, time, est_daily_vol
TSE_est_volume = pd.read_excel("5min_大盤日估計量_TSE.TW.xlsx") # 20191115 900 ~ 20251031	1325
TSE_est_volume = TSE_est_volume[TSE_est_volume['time'].isin(range(900, 925+1, 5))]
#%% fut
df = pd.read_csv("5min_data_FITX_1.TF.log", sep=" ", usecols=range(6)) # 20190102 845 ~ 20251031 1340
df = df.rename(columns={
    "open": "Open",
    "high": "High",
    "low": "Low",
    "close": "Close"
})
# closeD_prev, OpenD
df_daily = df.groupby('date').agg(closeD=("Close", "last")).reset_index()
df_daily['closeD_prev'] = df_daily['closeD'].shift(1)
df_daily.drop('closeD', axis=1, inplace=True) # date, closeD_prev
df = df.merge(df_daily, how='left', on='date')
# df = df[df['date'] > 20210401]
#%% da
da = (
      df\
      .merge(TSE_daily_volume, how='left', on='date')\
      .merge(TSE_est_volume, how='left', on=['date', 'time'])\
      )

da["datetime"] = pd.to_datetime(
    da["date"].astype(str) + da["time"].astype(str).str.zfill(4), format="%Y%m%d%H%M"
)
da.set_index("datetime", inplace=True)
da.sort_index(inplace=True)
# da # datetime index; date, time, Open, High, Low, Close, closeD_prev, TSE_daily_vol, est_daily_vol
#%% test
# self_data_df = da.copy()
# data_daily = (
#     self_data_df[['date', 'TSE_daily_vol']]\
#     .copy()\
#     .reset_index(drop=True)\
#     .groupby('date')\
#     .agg(TSE_vol=("TSE_daily_vol", "first"))\
#     .reset_index()
#     )
# data_daily['avg_vol'] = data_daily['TSE_vol'].shift(1).rolling(50).mean()
# data_daily = data_daily[['date', 'avg_vol']]
# result = self_data_df.merge(data_daily, how='left', on='date')
# result = result[result['date'] >= 20191115]
# result["datetime"] = pd.to_datetime(
#     result["date"].astype(str) + result["time"].astype(str).str.zfill(4), format="%Y%m%d%H%M"
# )
# result.set_index("datetime", inplace=True)
# result.sort_index(inplace=True)
# result
#%% Strategy
from backtesting import Backtest, Strategy
class Gap_large_volume_strategy(Strategy):
    avg_vol_period = 50 # days
    avg_vol_mult = 1
    large_vol_time = 910 # 900, 905, 910, 915, 920, 925
    stoploss_pct_long = 2
    stoploss_pct_short = 2
    
    start_date = 20210601
    contract_size = 200
    
    def init(self):
        # datetime index; date, time, Open, High, Low, Close, closeD_prev, TSE_daily_vol, est_daily_vol
        self_data_df = self.data.df.copy()
        data_daily = (
            self_data_df[['date', 'TSE_daily_vol']]\
            .copy()\
            .reset_index(drop=True)\
            .groupby('date')\
            .agg(TSE_vol=("TSE_daily_vol", "first"))\
            .reset_index()
            )
        data_daily['avg_vol'] = data_daily['TSE_vol'].shift(1).rolling(50).mean()
        data_daily = data_daily[['date', 'avg_vol']]
        result = self_data_df.merge(data_daily, how='left', on='date')
        result["datetime"] = pd.to_datetime(
            result["date"].astype(str) + result["time"].astype(str).str.zfill(4), format="%Y%m%d%H%M"
        )
        result.set_index("datetime", inplace=True)
        result.sort_index(inplace=True)
        
        self.avg_vol = self.I(lambda x: x, result['avg_vol'], name='avg_vol')
        
        self.condition_long = False
        self.condition_short = False
        
        self.entry_price = None
        self.stoploss_price = None
        
    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        
        closeD_prev = self.data.closeD_prev[-1]
        open_ = self.data.Open[-1]
        close = self.data.Close[-1]
        
        # 第一根K棒 845
        if self.data.date[-2] != self.data.date[-1]:
            self.condition_long = closeD_prev < open_ < close   # 開盤向上跳空，第一根收紅
            self.condition_short = closeD_prev > open_ > close  # 開盤向下跳空，第一根收黑
        
        # 進場
        if (not self.position) and (self.data.time[-1] == self.large_vol_time):
            # 判斷是否爆大量 時間點: 900 or 905 or 910 or 915 or 920 or 925
            large_vol_flag = self.data.est_daily_vol[-1] > self.avg_vol_mult * self.avg_vol[-1]
            # 多單
            if large_vol_flag and self.condition_long:
                self.buy(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = close * (1 - self.stoploss_pct_long * 0.01)
                return
            # 空單
            if large_vol_flag and self.condition_short:
                self.sell(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = close * (1 + self.stoploss_pct_short * 0.01)
                return

        # 移動停損
        if self.position:
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
#%% bt
cash = 1_000_000_000
bt = Backtest(da, Gap_large_volume_strategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% try
stats = bt.run()
print('\nNumber of trades=', len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% sambo
stats, heatmap, optimize_result = bt.optimize(
    avg_vol_period=[3, 60],
    avg_vol_mult=[1, 3],
    large_vol_time=920,
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
#%% run
stats = bt.run(avg_vol_period = 15, avg_vol_mult = 1, large_vol_time = 920, stoploss_pct_long = 3, stoploss_pct_short = 0.5)
print("\nNumber of trades=", len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
print(f"SQN= {stats.SQN:.2f}")
