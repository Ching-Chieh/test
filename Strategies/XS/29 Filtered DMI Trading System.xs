{@type:autotrade|@guid:adbd4d6eab33453a9b1548782b0a693e}
// Filtered DMI Trading System
// 10min
input: stoploss_pct_long(3, "trailing stop % for long"), stoploss_pct_short(3, "trailing stop % for short");
input: _contracts(1, "number of contracts"), _value(25), _time(905, "time for daily high/low");
var: _dailyhigh(0), _dailylow(0), _DIF(0), _DEM(0), _XMACD(0), _pDI(0), _nDI(0), _ADX(0), filter_1(False), filter_2(False);

if isfirstcall("Date") then begin
	_dailyhigh = 0;
	_dailylow = 0;
end;

if time = _time*100 then begin
	_dailyhigh = HighD(0);
	_dailylow = LowD(0);
end;

_DIF = average(close, 12) - average(close, 26);
_DEM = average(_DIF, 9);
_XMACD = _DIF - _DEM;

// value1 = MACD(WeightedClose, 12, 26, 9, _DIF, _DEM, _XMACD);
value1 = DirectionMovement(14, _pDI, _nDI, _ADX);

filter_1 = close > _dailyhigh and
	       high >= highest(high[1], 3) + _value and
	       TrueAll(_XMACD > _XMACD[1], 2);
filter_2 = close < _dailylow and
	       low <= lowest(low[1], 3) - _value and
	       TrueAll(_XMACD < _XMACD[1], 2);

if Position = 0 and _dailyhigh > 0 then begin
	if _pDI cross above _nDI and filter_1 then SetPosition(_contracts, label:="Long_Entry");
	if _nDI cross above _pDI and filter_2 then SetPosition(-_contracts, label:="Short_Entry");
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