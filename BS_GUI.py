import tkinter as tk

win = tk.Tk()
# win.geometry('450x100')
win.title('BS')

# S0
def check_S():
    msg_S.set("已輸入S0= " + str(S0.get()))
label_S0 = tk.Label(win, text='S0: ')
label_S0.grid(row=0, column=0, padx=5, pady=5)
S0 = tk.DoubleVar()
entry_S = tk.Entry(win, textvariable= S0)
entry_S.grid(row=0, column=1, padx=5, pady=5)
msg_S = tk.StringVar()
button_S = tk.Button(win, text="確認", command= check_S)
button_S.grid(row=0, column=2, padx=5, pady=5)
label_S0_2 = tk.Label(win, textvariable= msg_S, fg='red')
label_S0_2.grid(row=1, column=1, padx=5, pady=5)

# K
def check_K():
    msg_K.set("已輸入K= " + str(K.get()))
label_K = tk.Label(win, text='K: ')
label_K.grid(row=0, column=3, padx=5, pady=5)
K = tk.DoubleVar()
entry_K = tk.Entry(win, textvariable= K)
entry_K.grid(row=0, column=4, padx=5, pady=5)
msg_K = tk.StringVar()
button_K = tk.Button(win, text="確認", command= check_K)
button_K.grid(row=0, column=5, padx=5, pady=5)
label_K_2 = tk.Label(win, textvariable= msg_K, fg='red')
label_K_2.grid(row=1, column=4, padx=5, pady=5)

# T
def check_T():
    msg_T.set("已輸入T= " + str(T.get()))
label_T = tk.Label(win, text='T: ')
label_T.grid(row=2, column=0, padx=5, pady=5)
T = tk.DoubleVar()
entry_T = tk.Entry(win, textvariable= T)
entry_T.grid(row=2, column=1, padx=5, pady=5)
msg_T = tk.StringVar()
button_T = tk.Button(win, text="確認", command= check_T)
button_T.grid(row=2, column=2, padx=5, pady=5)
label_T_2 = tk.Label(win, textvariable= msg_T, fg='red')
label_T_2.grid(row=3, column=1, padx=5, pady=5)

# sigma
def check_sigma():
    msg_sigma.set("已輸入sigma= " + str(sigma.get()))
label_sigma = tk.Label(win, text='sigma: ')
label_sigma.grid(row=2, column=3, padx=5, pady=5)
sigma = tk.DoubleVar()
entry_sigma = tk.Entry(win, textvariable= sigma)
entry_sigma.grid(row=2, column=4, padx=5, pady=5)
msg_sigma = tk.StringVar()
button_sigma = tk.Button(win, text="確認", command= check_sigma)
button_sigma.grid(row=2, column=5, padx=5, pady=5)
label_sigma_2 = tk.Label(win, textvariable= msg_sigma, fg='red')
label_sigma_2.grid(row=3, column=4, padx=5, pady=5)

# r
def check_r():
    msg_r.set("已輸入r= " + str(r.get()))
label_r = tk.Label(win, text='r: ')
label_r.grid(row=4, column=0, padx=5, pady=5)
r = tk.DoubleVar()
entry_r = tk.Entry(win, textvariable= r)
entry_r.grid(row=4, column=1, padx=5, pady=5)
msg_r = tk.StringVar()
button_r = tk.Button(win, text="確認", command= check_r)
button_r.grid(row=4, column=2, padx=5, pady=5)
label_r_2 = tk.Label(win, textvariable= msg_r, fg='red')
label_r_2.grid(row=5, column=1, padx=5, pady=5)

# call or put
def choose():
    msg_c_p.set('已選擇: ' + choice.get() + '\n\n\n')
msg_c_p = tk.StringVar()
label_c_p = tk.Label(win, text='call or put: ')
label_c_p.grid(row=4, column=3, padx=5, pady=5)
choice = tk.StringVar()
item1 = tk.Radiobutton(win, text= "call", value='c', variable=choice, command= choose)
item1.grid(row=4, column=4, padx=5, pady=5)
item2 = tk.Radiobutton(win, text= "put", value='p', variable=choice, command= choose)
item2.grid(row=5, column=4, padx=5, pady=5)
label_c_p2 = tk.Label(win, textvariable= msg_c_p, fg='red')
label_c_p2.grid(row=6, column=4, padx=5, pady=5, columnspan=2)
item1.select()
choose()


def calculate():
    from numpy import log
    from numpy import exp
    from math import sqrt
    from scipy.stats import norm
    d1 = (log(S0.get()/K.get())+(r.get()+0.5*sigma.get()**2)*T.get())/(sigma.get()*sqrt(T.get()))
    d2 = d1-sigma.get()*sqrt(T.get())
    if choice.get()=='c':
        c = S0.get()*norm.cdf(d1)-K.get()*exp(-r.get()*T.get())*norm.cdf(d2)
        label_Final = tk.Label(win, text='call value= '+ str(round(c,4)), fg='red')
        label_Final.grid(row=6, column=2, padx=5, pady=5, columnspan=2)
    else:
        p = K.get()*exp(-r.get()*T.get())*norm.cdf(-d2)-S0.get()*norm.cdf(-d1)
        label_Final = tk.Label(win, text='put value= '+ str(round(p,4)), fg='red')
        label_Final.grid(row=6, column=2, padx=5, pady=5, columnspan=2)

button_Final = tk.Button(win, text="計算", command= calculate)
button_Final.grid(row=6, column=1, padx=5, pady=5, columnspan=2)

win.mainloop()
