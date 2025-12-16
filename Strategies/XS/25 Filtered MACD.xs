{@type:autotrade|@guid:397a9c29b04f4ae296adc7205c3e322f}
// Filtered MACD
// 5min
input: stoploss_pct_long(1.8, "trailing stop % for long"), stoploss_pct_short(0.3, "trailing stop % for short");
input: _contracts(1, "number of contracts"), _time(925, "time for dailyhigh/low");
input: dif_fast_period(16, "period for MACD fast"), dif_slow_period(21, "period for MACD slow"), dem_period(23, "period for DEM");
input: ma_type("SMA", "MACD MA", inputkind:=Dict(["Simple MA","SMA"],["Exponential MA","EMA"]));

var: _DIF(0), _DEM(0), _XMACD(0), _dailyhigh(0), _dailylow(0), filter_1(False), filter_2(False);

_DIF = average(close, dif_fast_period) - average(close, dif_slow_period);
_DEM = average(_DIF , dem_period);
_XMACD = _DIF - _DEM;

if isfirstcall("Date") then begin
	_dailyhigh = 0;
	_dailylow = 0;
end;

if time = _time*100 then begin
	_dailyhigh = HighD(0);
	_dailylow = LowD(0);
end;

filter_1 = close > _dailyhigh and high >= highest(high[1], 3);
filter_2 = close < _dailylow and low <= lowest(low[1], 3);

if Position = 0 and _dailyhigh > 0 then begin
	if _DIF cross above _DEM and filter_1 then SetPosition(_contracts, label:="Long_Entry");
	if _DIF cross below _DEM and filter_2 then SetPosition(-_contracts, label:="Short_Entry");
end;

var: intrabarpersist stoploss_price(0);
// Exit for long positions
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

// Exit for short positions
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