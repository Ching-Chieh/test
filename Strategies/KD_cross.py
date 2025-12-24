#%% Strategy
from backtesting import Strategy, Backtest
from backtesting.lib import crossover
from talib import STOCH
import pandas as pd

class KD_cross_strategy(Strategy):
    fastk_period = 9
    slowk_period = 3
    slowd_period = 3
    low_value = 50

    start_date = 20210601
    contract_size = 200
    
    def init(self):
        high = pd.Series(self.data.High, index=self.data.index)
        low = pd.Series(self.data.Low, index=self.data.index)
        close = pd.Series(self.data.Close, index=self.data.index)
        # slowk, slowd = STOCH(high, low, close, fastk_period=5, slowk_period=3, slowk_matype=0, slowd_period=3, slowd_matype=0)
        self.k, self.d = self.I(STOCH,
                                high, low, close,
                                self.fastk_period,
                                self.slowk_period,
                                0,
                                self.slowd_period,
                                0,
                                name=['k', 'd'])
    
    def next(self):
        if self.data.index[-1] < pd.to_datetime(str(self.start_date), format="%Y%m%d"):
            return
        
        condition1 = crossover(self.k, self.d)
        condition2 = crossover(self.d, self.k)
        
        if not self.position:
            if condition1:
                self.buy(size=self.contract_size)
                return
        
            if condition2 and self.d[-1] < self.low_value:
                self.sell(size=self.contract_size)
                return
        
        else:
            if self.position.is_long:
                if condition2:
                    self.position.close()
                    return
    
            if self.position.is_short:
                if condition1:
                    self.position.close()
                    return
#%% functions
def prepare_df(df):
    df = df.copy()
    df["date"] = pd.to_datetime(df["date"].astype(str), format="%Y%m%d")
    df = (
        df
        .set_index("date")
        .sort_index()
        .rename(columns={
            "open": "Open",
            "high": "High",
            "low": "Low",
            "close": "Close"
        })
        [["Open", "High", "Low", "Close"]]
    )
    return df
#%% bt
df = pd.read_excel("day_data_FITX_1.TF.xlsx")
df = prepare_df(df)

cash = 1_000_000_000
bt = Backtest(df, KD_cross_strategy,
              cash=cash,
              trade_on_close=True,
              finalize_trades=True)
#%% try
stats = bt.run()
print("\nNumber of trades=", len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% maximize final equity
stats, heatmap, optimize_result = bt.optimize(
    fastk_period=[3, 40],
    slowk_period=[3, 40],
    slowd_period=[3, 40],
    low_value=[10, 70],
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
stats = bt.run(fastk_period = , slowk_period = , slowd_period = , low_value = )
print("\nNumber of trades=", len(stats['_trades']))
print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")
#%% maximize net profit / max drawdown
def max_drawdown_dollar(stats):
    equity = stats['_equity_curve']['Equity']
    peak = equity.cummax()
    drawdown = peak - equity
    return drawdown.max()

def net_profit_drawdown_ratio(stats):
    net_profit = stats['Equity Final [$]'] - cash
    max_dd = max_drawdown_dollar(stats)

    if max_dd == 0:
        return -1e9
    #if stats['# Trades'] < 30:
    #    return -1e9
    
    return net_profit / max_dd

stats, heatmap, optimize_result = bt.optimize(
    fastk_period=[3, 40],
    slowk_period=[3, 40],
    slowd_period=[3, 40],
    low_value=[10, 70],
    maximize=net_profit_drawdown_ratio,
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
stats = bt.run(fastk_period = , slowk_period = , slowd_period = , low_value = )
print("\nNumber of trades=", len(stats['_trades']))

print(f"Net profit= {stats['Equity Final [$]']-cash:,.0f}")

