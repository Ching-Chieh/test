#%% modules
import pandas as pd
from backtesting import Backtest, Strategy
from backtesting.lib import crossover
from ta.momentum import AwesomeOscillatorIndicator
#%% 1. Zero Line Crossover Strategy
class ZeroLineCrossoverStrategy(Strategy):
    short_period = 5 
    long_period = 34
    stoploss_pct_long = 0.2
    stoploss_pct_short = 0.2

    start_date = 20210601
    contract_size = 200
    
    def init(self):
        high = pd.Series(self.data.High, index=self.data.index)
        low = pd.Series(self.data.Low, index=self.data.index)
        ao_object = AwesomeOscillatorIndicator(high, low, self.short_period, self.long_period)
        self.ao = self.I(ao_object.awesome_oscillator)
    
        self.entry_price = None
        self.stoploss_price = None
        
    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        if self.short_period >= self.long_period:
            return
        
        close = self.data.Close[-1]
        
        if not self.position:
            if crossover(self.ao, 0):
                self.buy(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = close * (1 - self.stoploss_pct_long * 0.01)
                return
            
            elif crossover(0, self.ao):
                self.sell(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = close * (1 + self.stoploss_pct_short * 0.01)
                return
        
        # trailing stoploss
        else:
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
        
#%% 2. Saucers Strategy
class SaucersStrategy(Strategy):
    short_period = 5 
    long_period = 34
    stoploss_pct_long = 0.2
    stoploss_pct_short = 0.2

    start_date = 20210601
    contract_size = 200
    
    def init(self):
        high = pd.Series(self.data.High, index=self.data.index)
        low = pd.Series(self.data.Low, index=self.data.index)
        ao_object = AwesomeOscillatorIndicator(high, low, self.short_period, self.long_period)
        self.ao = self.I(ao_object.awesome_oscillator)
        
        self.entry_price = None
        self.stoploss_price = None
        
    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        if len(self.data) < 3:
            return
        if self.short_period >= self.long_period:
            return
        
        if not self.position:
            long_condition = (
                self.ao[-3] > 0 and self.ao[-2] > 0 and self.ao[-1] > 0 and  # above zero line
                self.ao[-4] > self.ao[-3] > self.ao[-2] and self.ao[-2] < self.ao[-1] and # decrease 2 times and increase one time
                self.ao[-2] < min(self.ao[-3], self.ao[-1])  # middle one is shorter
                )
            short_condition = (
                self.ao[-3] < 0 and self.ao[-2] < 0 and self.ao[-1] < 0 and  # below zero line
                self.ao[-4] < self.ao[-3] < self.ao[-2] and self.ao[-2] > self.ao[-1] and # increase 2 times and decrease one time
                self.ao[-2] > max(self.ao[-3], self.ao[-1])  # middle one is longer
                )
            # Bullish saucer
            if long_condition:
                self.buy(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = close * (1 - self.stoploss_pct_long * 0.01)
                return
            # Bearish saucer
            if short_condition:
                self.sell(size=self.contract_size)
                self.entry_price = close
                self.stoploss_price = close * (1 + self.stoploss_pct_short * 0.01)
                return
        
        # trailing stoploss
        else:
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
#%% 3. Twin Peaks Strategy

# find two most recent peaks
def find_twin_peaks(array):
    peaks = []
    for i in range(1, len(array)-1):
        if array[i] > array[i-1] and array[i] > array[i+1]:
            peaks.append(array[i])
    if len(peaks) < 2:
        return None
    return peaks[-2], peaks[-1]

# find two most recent lows
def find_twin_lows(array):
    lows = []
    for i in range(1, len(array)-1):
        if array[i] < array[i-1] and array[i] < array[i+1]:
            lows.append(array[i])
    if len(lows) < 2:
        return None
    return lows[-2], lows[-1]

class TwinPeaksStrategy(Strategy):
    short_period = 5 
    long_period = 34
    lookback = 60
    stoploss_pct_long = 0.2
    stoploss_pct_short = 0.2

    start_date = 20210601
    contract_size = 200
    
    def init(self):
        high = pd.Series(self.data.High, index=self.data.index)
        low = pd.Series(self.data.Low, index=self.data.index)
        ao_object = AwesomeOscillatorIndicator(high, low, self.short_period, self.long_period)
        self.ao = self.I(ao_object.awesome_oscillator)
        
        self.entry_price = None
        self.stoploss_price = None

    def next(self):
        if self.data.date[-1] < self.start_date:
            return
        if len(self.ao) < self.lookback:
            return
        if self.short_period >= self.long_period:
            return
        
        close = self.data.Close[-1]
        recent_ao = self.ao[-self.lookback:]
        
        if not self.position:
            # Buy Signal: Twin Lows below zero
            lows = find_twin_lows(recent_ao)
            if lows:
                l1, l2 = lows
                if l1 < 0 and l2 < 0 and l1 < l2:
                    self.buy(size=self.contract_size)
                    self.entry_price = close
                    self.stoploss_price = close * (1 - self.stoploss_pct_long * 0.01)
                    return
            
            # Sell Signal: Twin Peaks above zero
            peaks = find_twin_peaks(recent_ao)
            if peaks:
                p1, p2 = peaks
                if p1 > 0 and p2 > 0 and p1 > p2:
                    self.sell(size=self.contract_size)
                    self.entry_price = close
                    self.stoploss_price = close * (1 + self.stoploss_pct_short * 0.01)
                    return
        
        # trailing stoploss
        else:
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
#%% freq
freq = 10
#%% bt
df = pd.read_csv(str(freq) + "min_data_FITX_1.TF.log", sep=" ", usecols=range(6))
df = prepare_df(df)
df = df[df.index > '2021-04-01'] # 回測起始日期: 20210601

cash = 1_000_000_000
bt = Backtest(df, ZeroLineCrossoverStrategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% try
stats = bt.run()
print("\nNumber of trades=", len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% sambo
stats, heatmap, optimize_result = bt.optimize(
    short_period=[3, 20],
    long_period=[5, 50],
    stoploss_pct_long=[0.2, 3],
    stoploss_pct_short=[0.2, 3],
    constraint=lambda p: p.short_period < p.long_period,
    maximize='Equity Final [$]',
    method='sambo',
    max_tries=1000,
    random_state=0,
    return_heatmap=True,
    return_optimization=True)
#%%
print(optimize_result)
print(heatmap.sort_values().iloc[-3:])
print("\nNumber of trades=", len(stats['_trades']))
print(stats.SQN)
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% best parameters
stats = bt.run(fastk_period = , slowk_period = , slowd_period = ,
               high_value = , low_value = ,
               stoploss_pct_long = ,stoploss_pct_short)
print("\nNumber of trades=", len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")

