{@type:autotrade|@guid:83d536bca17f4e9e8ca2881cb0b63aaa}
// RSI Swing Trading
// 5min
input: stoploss_pct(3, "trailing stoploss%"), _contracts(1, "number of contracts");
input: _time(935, "time for high low"), rsi_short_period(19, "RSI short period"), rsi_long_period(50, "RSI long period");
var: _dailyhigh(0), _dailylow(0), rsi_short(0), rsi_long(0);

rsi_short = RSI(close, rsi_short_period);
rsi_long = RSI(close, rsi_long_period);

if isfirstcall("Date") then begin
	_dailyhigh = 0;
	_dailylow = 0;
end;

if time = _time*100 then begin
	_dailyhigh = HighD(0);
	_dailylow = LowD(0);
end;

// Entry
if Position = 0 and _dailyhigh > 0 then begin
	if rsi_short cross below rsi_long and
		close < _dailylow and
		low <= lowest(low[1], 3) then
		SetPosition(_contracts, label:="Long_Entry");
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