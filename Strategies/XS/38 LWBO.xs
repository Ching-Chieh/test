{@type:autotrade|@guid:97413671ae6a4d16bc28c86f025bdcf4}
// LWBO
// 5min
input: _contracts(1, "number of contracts"), _time(905, "time for daily high/low");
input: num(0.1, "multiplier");
input: stoploss_pct_long(2, "trailing stop % for long"), stoploss_pct_short(3, "trailing stop % for short");
var: _dailyhigh(0), _dailylow(0), entry_long(0), entry_short(0);

value1 = (HighD(1) - LowD(1))*num;

if isfirstcall("Date") then begin
	_dailyhigh = 0;
	_dailylow = 0;
	entry_long = 0;
	entry_short = 0;
end;

if time = _time*100 then begin
	_dailyhigh = HighD(0);
	_dailylow = LowD(0);
	entry_long = _dailyhigh + value1;
	entry_short = _dailylow - value1;
end;

if Position = 0 and _dailyhigh > 0 then begin
	if close > entry_long then SetPosition(_contracts, label:="Long_Entry");
	if close < entry_short then SetPosition(-_contracts, label:="Short_Entry");
end;

var: intrabarpersist stoploss_price(0);
if Filled > 0 and Position = Filled then begin
	if stoploss_price = 0 then
		stoploss_price = FilledAvgPrice*(1 - stoploss_pct_long*0.01);
		
	if Close > FilledAvgPrice then begin
		if Close*(1 - stoploss_pct_long*0.01) > stoploss_price then
			stoploss_price = Close*(1 - stoploss_pct_long*0.01);
	end;

	if Close <= stoploss_price then begin
		SetPosition(0, label:="Long_Exit");
		stoploss_price = 0;
	end;
end;

if Filled < 0 and Position = Filled then begin
	if stoploss_price = 0 then
		stoploss_price = FilledAvgPrice*(1 + stoploss_pct_short*0.01);
		
	if Close < FilledAvgPrice then begin
		if Close*(1 + stoploss_pct_short*0.01) < stoploss_price then
			stoploss_price = Close*(1 + stoploss_pct_short*0.01);
	end;

	if Close >= stoploss_price then begin
		SetPosition(0, label:="Short_Exit");
		stoploss_price = 0;
	end;
end;

