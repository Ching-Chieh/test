{@type:autotrade|@guid:d8de683767da4a2b9ff0fc36eec77278}
// MACD Strong Trend Trading
// Performance was good on the 5-min, 15-min, and 30-min charts.

// 5min
// trailing stop % for long=3, trailing stop % for short=0.2
// period for MACD fast=12, period for MACD slow=19, period for DEM=3, MACD MA=SMA
// Net profit: 3,802,204 (Long: 3,281,548, Short: 520,656) 

// 15min
// trailing stop % for long=1.7, trailing stop % for short=3
// period for MACD fast=19, period for MACD slow=46, period for DEM=16, MACD MA=SMA 
// Net profit: 2,681,140 (Long: 2,478,824, Short: 202,316) 

// 30min
// trailing stop % for long=2.5, trailing stop % for short=0.6
// period for MACD fast=34, period for MACD slow=46, period for DEM=31, MACD MA=EMA
// Net profit: 2,785,468 (Long: 2,246,792, Short: 538,676) 

input: _contracts(1, "number of contracts");
input: stoploss_pct_long(3, "trailing stop % for long"), stoploss_pct_short(0.2, "trailing stop % for short");
input: dif_fast_period(12, "period for MACD fast"), dif_slow_period(19, "period for MACD slow"), dem_period(3, "DEM期數");
input: ma_type("SMA", "MACD MA", inputkind:=Dict(["Simple MA","SMA"],["Exponential MA","EMA"]));

var: _DIF(0), _DEM(0), _XMACD(0);

if ma_type = "SMA" then begin
	_DIF = average(close, dif_fast_period) - average(close, dif_slow_period);
	_DEM = average(_DIF , dem_period);
	_XMACD = _DIF - _DEM;
end else if ma_type = "EMA" then begin
	value1 = MACD(WeightedClose, dif_fast_period, dif_slow_period, dem_period, _DIF, _DEM, _XMACD);
end;

if Position = 0 then begin
	if _DIF > 0 and _DEM > 0 and _XMACD > 0 then SetPosition(_contracts, label:="Long_Entry");
	if _DIF < 0 and _DEM < 0 and _XMACD < 0 then SetPosition(-_contracts, label:="Short_Entry");
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