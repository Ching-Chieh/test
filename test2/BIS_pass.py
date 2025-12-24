import pandas as pd
import requests
import os

url = "https://dsp.twse.com.tw/public/static/downloads/brokerDepartment/肆、測驗合格人員名單_20250103153040.xlsx"
file_name = "Exam_Pass_List.xlsx"

r = requests.get(url)
with open(file_name, "wb") as f:
    f.write(r.content)

da = pd.read_excel(file_name, header=None, names=["券商代號", "券商名稱", "姓名"])
os.remove(file_name)
tmp = da["券商代號"]

header_idx = tmp[tmp == "券商代號"].index
year_idx = header_idx - 1

year = (
    tmp.loc[year_idx]
    .str.extract(r"(\d+)(?=年)")[0]
    .astype(int)
    .tolist()
)

idx_start = header_idx + 1
idx_end = list(year_idx[1:] - 1) + [len(da) - 1]
from pprint import pprint
pprint(list(zip(idx_start, idx_end, year)))
dfs = [
    da.loc[s:e]
      .dropna(subset=["姓名"])
      .assign(year=y)
    for s, e, y in zip(idx_start, idx_end, year)
]

df = pd.concat(dfs, ignore_index=True)
print(df)
print(df[
    df["姓名"].str.startswith("") &
    df["姓名"].str.endswith("")
])

print(df[
    df["券商名稱"].str.startswith("") &
    df["姓名"].str.startswith("") &
    df["姓名"].str.endswith("")
])

print(df[
    df["券商名稱"].str.startswith("") &
    df["姓名"].str.startswith("") &
    df["姓名"].str.endswith("")
])
