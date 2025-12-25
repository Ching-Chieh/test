import numpy as np
import pandas as pd

data = np.array([0, 2, 4, 6, 8, 10])
window = 3
cumsum = np.cumsum(np.insert(data, 0, 0))
rolling_mean = (cumsum[window:] - cumsum[:-window]) / window
print(rolling_mean)
rolling_mean = pd.Series(data).rolling(window).mean()
print(rolling_mean)
rolling_mean = np.convolve(data, np.ones(window)/window, mode='valid')
print(rolling_mean)
