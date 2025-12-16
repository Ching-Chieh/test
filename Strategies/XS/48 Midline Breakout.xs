{@type:autotrade|@guid:6f108ce91a3f439fa393e9bf395d3a54}
// Midline Breakout
// 5min
input: stoploss_pct(2, "trailing stoploss%"), _contracts(1, "number of contracts"), _time(930, "time for daily high/low");
input: _m(0.2, "multiplier for midline"), _short(False, "short selling");
var: _dailyhigh(0), _dailylow(0), midline(0);

if isfirstcall("Date") then begin
	_dailyhigh = 0;
	_dailylow = 0;
	midline = 0;
end;

if time = _time*100 then begin
	_dailyhigh = highD(0);
	_dailylow = lowD(0);
	midline = _dailylow + (_dailyhigh - _dailylow) * _m;
end;

// 進場
if midline > 0 and Position = 0 then begin
	if close > midline then SetPosition(_contracts, label:="Long_Entry");
	if _short and close < midline then SetPosition(-_contracts, label:="Short_Entry");
end;

var: intrabarpersist stoploss_price(0);
if Filled > 0 and Position = Filled then begin
	if stoploss_price = 0 then
		stoploss_price = FilledAvgPrice*(1 - stoploss_pct*0.01);
		
	if Close > FilledAvgPrice then begin
		if Close*(1 - stoploss_pct*0.01) > stoploss_price then
			stoploss_price = Close*(1 - stoploss_pct*0.01);
	end;

	if Close <= stoploss_price then begin
		SetPosition(0, label:="Long_Exit");
		stoploss_price = 0;
	end;
end;

if Filled < 0 and Position = Filled then begin
	if stoploss_price = 0 then
		stoploss_price = FilledAvgPrice*(1 + stoploss_pct*0.01);
		
	if Close < FilledAvgPrice then begin
		if Close*(1 + stoploss_pct*0.01) < stoploss_price then
			stoploss_price = Close*(1 + stoploss_pct*0.01);
	end;

	if Close >= stoploss_price then begin
		SetPosition(0, label:="Short_Exit");
		stoploss_price = 0;
	end;
end;