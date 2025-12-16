{@type:autotrade|@guid:9d33269c98be4db0affffe648234c686}
// HLBO
// 5min
input: long_num(0.1, "multiplier(long)%"), short_num(1.6, "multiplier(short)%"), _contracts(1, "number of contracts");
input: _time(940, "time for daily high/low"), stoploss_pct_long(1.8, "trailing stop % for long"), stoploss_pct_short(2.9, "trailing stop % for short");
var: _dailyhigh(0), _dailylow(0);

if isfirstcall("Date") then begin
	_dailyhigh = 0;
	_dailylow = 0;
end;

if time = _time*100 then begin
	_dailyhigh = HighD(0);
	_dailylow = LowD(0);
end;

if Position = 0 and _dailyhigh > 0 then begin
	if close > _dailyhigh*(1+long_num*0.01) then SetPosition(_contracts, label:="Long_Entry");
	if close < _dailylow*(1-short_num*0.01) then SetPosition(-_contracts, label:="Short_Entry");
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
