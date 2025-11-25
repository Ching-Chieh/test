#%% date
import pandas as pd
import requests
from bs4 import BeautifulSoup
from io import StringIO

folder_path = r'C:\Users\Jimmy\Desktop\d'

url = "https://www.taifex.com.tw/cht/3/futPrevious30DaysSalesData"

html = requests.get(url).text
soup = BeautifulSoup(html, "html.parser")
table = soup.find("table", class_="table_f table-fixed")
df = pd.read_html(StringIO(str(table)))[0][["日期"]].rename(columns={'日期': 'date'})
df['date'] = pd.to_datetime(df['date'], format='%Y/%m/%d')
df = df.sort_values(by="date")
df.reset_index(drop=True, inplace=True)
url = "https://www.taifex.com.tw/file/taifex/Dailydownload/DailydownloadCSV/"
df['filename'] = url + "Daily_" + df['date'].dt.strftime("%Y_%m_%d") + ".zip"

#%% download
import os
import requests
from concurrent.futures import ThreadPoolExecutor, as_completed
from tqdm import tqdm

def download_file(url):
    try:
        filename = os.path.basename(url)
        filepath = os.path.join(folder_path, filename)

        r = requests.get(url)
        r.raise_for_status()

        with open(filepath, "wb") as f:
            f.write(r.content)

        return True
    except:
        return False

urls = df["filename"].tolist()
max_workers = 10

with ThreadPoolExecutor(max_workers=max_workers) as tex:
    tasks = [tex.submit(download_file, url) for url in urls]

    for _ in tqdm(as_completed(tasks), total=len(tasks), desc="Downloading"):
        pass

print("\n----- 下載完成 -----\n")
#%% unzip_files
import zipfile

def unzip_files(folder_path):
    for file in os.listdir(folder_path):
        if file.lower().endswith(".zip"):
            zip_path = os.path.join(folder_path, file)
    
            print(f"正在解壓縮：{zip_path}")
    
            with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                zip_ref.extractall(folder_path)
    print("\n----- 解壓縮完成 -----")

unzip_files(folder_path)
#%% read csv
import pandas as pd

file = "Daily_2025_11_21.csv"
d_ = int(file[6:16].replace("_", ""))
m_ = "202512"
columns = ["date", "code", "month", "time", "price", "volume"]
dtype_dict = {
    "date": int,
    "code": str,
    "month": str,
    "time": int,
    "price": float,
    "volume": int
    }
df = pd.read_csv(file, usecols=range(6), encoding="Big5", dtype=dtype_dict, names=columns, skiprows=1)
# polars
# import polars as pl
# dtype_dict = {
#     "date": pl.Int64,
#     "code": pl.Utf8,
#     "month": pl.Utf8,
#     "time": pl.Int64,
#     "price": pl.Float64,
#     "volume": pl.Int64
# }
# df = pl.read_csv(
#     file,
#     columns=range(6),
#     new_columns=columns,
#     schema_overrides=dtype_dict,
#     encoding="big5",
#     skip_rows=1
# ).to_pandas()
# print(df)
# print(df.dtypes)

# aa=list(set(df['code'].tolist()))
# print("TX" in aa)
# print([s for s in aa if s.startswith("T")])
# aa=list(set(df['month'].tolist()))
# print(aa)
df[["code", "month"]] = df[["code", "month"]].apply(lambda x: x.str.strip())
df = df[
    (df['date'] == d_) &
    (df['code'] == "TX") &
    (df['month'] == m_) &
    (df['time'] >= 84500) &
    (df['time'] <= 134500)
]

df['volume'] = df['volume'] / 2
df['h'] = df['time'] // 10000
df['m'] = (df['time'] % 10000) // 100
df['total_min'] = df['h'] * 60 + df['m']

tmp = 8*60 + 45

def f1(df, freq):
    df = df.copy()
    df['t'] = ((df['total_min'] - tmp) // freq) * freq + tmp
    df['t'] = (df['t'] // 60) * 100 + (df['t'] % 60)

    agg = df.groupby('t').agg(
        open=('price', 'first'),
        high=('price', 'max'),
        low=('price', 'min'),
        close=('price', 'last'),
        volume=('volume', 'sum')
    ).reset_index().rename(columns={'t': 'time'})
    return agg

freqs = [1, 3, 5, 10, 15, 20, 30, 60]
result = {str(f): f1(df, f) for f in freqs}
print(result['5'])
print(result['30'])



