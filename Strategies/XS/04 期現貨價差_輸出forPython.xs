{@type:autotrade|@guid:bc3a24c8413b401295f1dc47b98d4369}
// 期現貨價差
// 5min
var: spread(0);
spread = close - GetSymbolField("TSE.TW", "Close");

var: _path(""), _firstTime(0);
_path = "C:\Users\Jimmy\Desktop\期現貨價差交易data.log";

if _firstTime = 0 then begin
	print(file(_path),
	      "date", "time",
		  "open",
		  "high",
		  "low",
		  "close",
		  "close_TSE",
		  "spread"
		  );
	_firstTime = 1;
end;

print(file(_path),
      numtostr(date, 0), numtostr(time/100, 0),
	  numtostr(open, 0),
	  numtostr(high, 0),
	  numtostr(low, 0),
	  numtostr(close, 0),
	  numtostr(GetSymbolField("TSE.TW", "Close"), 2),
	  numtostr(spread, 2)
	  );

