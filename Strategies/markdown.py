#%%
import pandas as pd
df = pd.read_excel(r"C:\Users\Jimmy\Desktop\策略\strategy.xlsx", skiprows=3, usecols=range(13))
cols = ['Net Profit', 'Max Drawdown', 'Profit for Long Trades', 'Profit for Short Trades']
def format_number(x):
    try:
        return f"{float(x):,.0f}"
    except:
        return ""
df[cols] = df[cols].map(format_number)
def format_percent(x):
    try:
        return f"{float(x)*100:.2f}%"
    except:
        return ""
df['Win Rate'] = df['Win Rate'].map(format_percent)
df['Number of Trades'] = df['Number of Trades'].fillna(0).astype(int)
df['SQN'] = df['SQN'].round(2)
df = df.fillna("")
markdown_table = df.to_markdown(index=False)
markdown_table = markdown_table.replace("nan%", "    ")
markdown_table = markdown_table.replace("nan", "   ")
print(markdown_table)
