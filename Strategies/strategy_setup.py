!pip install backtesting
!pip install sambo
!pip install ta
!pip install TA_Lib

from google.colab import drive
drive.mount('/content/drive')

import pandas as pd
file_path = '/content/drive/My Drive/Strategies/data/15min_data_FITX_1.TF.log'
df = pd.read_csv(file_path, sep=" ", usecols=range(6))
print(len(df))

import sys
sys.path.append('/content/drive/MyDrive/Strategies')
from BollingerStrategy import BollingerStrategy