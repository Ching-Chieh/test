#%% Strategy
from backtesting import Strategy, Backtest
from backtesting.lib import crossover
import pandas as pd

class Momentum_surge_strategy(Strategy):
    long_entry_mult = 0.55
    short_entry_mult = 0.55
    
    long_exit_mult = 0.75
    short_exit_mult = 0.75
    
    start_date = 20210601 # 回測起始日期
    contract_size = 200
    
    def init(self):
        self.value = ((self.data.highD1 - self.data.lowD1) +
                      (self.data.highD2 - self.data.lowD2) +
                      (self.data.highD3 - self.data.lowD3)) / 3
        
        long_entry_threshold = self.data.closeD1 + self.value*self.long_entry_mult
        self.long_entry_threshold = self.I(lambda x: x, long_entry_threshold)
        short_entry_threshold = self.data.closeD1 - self.value*self.short_entry_mult
        self.short_entry_threshold = self.I(lambda x: x, short_entry_threshold)
        
        long_exit_threshold = self.data.closeD1 - self.value*self.long_exit_mult
        self.long_exit_threshold = self.I(lambda x: x, long_exit_threshold)
        short_exit_threshold = self.data.closeD1 + self.value*self.short_exit_mult
        self.short_exit_threshold = self.I(lambda x: x, short_exit_threshold)
        
    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        
        # 進場
        if not self.position:
            long_entry_condition = crossover(self.data.Close, self.long_entry_threshold)
            short_entry_condition = crossover(self.short_entry_threshold, self.data.Close)
            if long_entry_condition:
                self.buy(size=self.contract_size)
                return
            
            if short_entry_condition:
                self.sell(size=self.contract_size)
                return
        
        # 出場
        else:
            long_exit_condition = crossover(self.long_exit_threshold, self.data.Close)
            short_exit_condition = crossover(self.data.Close, self.short_exit_threshold)
            if self.position.is_long:
                if long_exit_condition:
                    self.position.close()
                    return

            if self.position.is_short:
                if short_exit_condition:
                    self.position.close()
                    return
#%% function
def prepare_df(freq):
    df_5 = pd.read_csv(str(freq) + "min_data_FITX_1.TF.log", sep=" ", usecols=range(6))
    df_D = (
        df_5
        .groupby("date")
        .agg(
            highD=("high", "max"),
            lowD=("low", "min"),
            closeD=("close", "last"),
            )
        .reset_index()
    )
    df_D['closeD1'] = df_D['closeD'].shift(1)

    df_D['highD1'] = df_D['highD'].shift(1)
    df_D['highD2'] = df_D['highD'].shift(2)
    df_D['highD3'] = df_D['highD'].shift(3)

    df_D['lowD1'] = df_D['lowD'].shift(1)
    df_D['lowD2'] = df_D['lowD'].shift(2)
    df_D['lowD3'] = df_D['lowD'].shift(3)
    df_D.drop(['closeD', 'highD', 'lowD'], axis=1, inplace=True)
    df = df_5.merge(df_D, how='left', on='date').dropna()
    
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

    return df[["date", "time", "Open", "High", "Low", "Close",
               "closeD1",
               "highD1", "highD2", "highD3",
               "lowD1", "lowD2", "lowD3",
               ]]
#%% cash
cash = 1_000_000_000
#%% freq = 5
freq = 5
df = prepare_df(freq)
df = df[df.index > '2021-04-01'] # 回測起始日期: 20210601

bt = Backtest(df, Momentum_surge_strategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% try
stats = bt.run()
print("\nNumber of trades=", len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% sambo
stats, heatmap, optimize_result = bt.optimize(
    long_entry_mult =[0.1, 1.5],
    short_entry_mult=[0.1, 1.5],
    long_exit_mult  =[0.1, 1.5],
    short_exit_mult =[0.1, 1.5],
    maximize='Equity Final [$]',
    method='sambo',
    max_tries=1000,
    random_state=0,
    return_heatmap=True,
    return_optimization=True)
#%% sambo result
print("freq:", freq)
print("\n", optimize_result)
print(heatmap.sort_values().iloc[-3:])
print("\nNumber of trades=", len(stats['_trades']))
print(f"SQN= {stats.SQN:.2f}")
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% best parameters
stats = bt.run(long_entry_mult = 80, short_entry_mult = 54, long_exit_mult = , short_exit_mult = )
print("\nNumber of trades=", len(stats['_trades']))
print(f"SQN= {stats.SQN:.2f}")
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% freq = 10
freq = 10
df = prepare_df(freq)
df = df[df.index > '2021-04-01'] # 回測起始日期: 20210601

bt = Backtest(df, Momentum_surge_strategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% sambo
stats, heatmap, optimize_result = bt.optimize(
    long_entry_mult =[0.1, 1.5],
    short_entry_mult=[0.1, 1.5],
    long_exit_mult  =[0.1, 1.5],
    short_exit_mult =[0.1, 1.5],
    maximize='Equity Final [$]',
    method='sambo',
    max_tries=1000,
    random_state=0,
    return_heatmap=True,
    return_optimization=True)
#%% sambo result
print("freq:", freq)
print("\n", optimize_result)
print(heatmap.sort_values().iloc[-3:])
print("\nNumber of trades=", len(stats['_trades']))
print(f"SQN= {stats.SQN:.2f}")
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% best parameters
stats = bt.run(long_entry_mult = 80, short_entry_mult = 54, long_exit_mult = , short_exit_mult = )
print("\nNumber of trades=", len(stats['_trades']))
print(f"SQN= {stats.SQN:.2f}")
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")






