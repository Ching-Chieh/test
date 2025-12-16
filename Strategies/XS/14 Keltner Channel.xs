{@type:autotrade|@guid:e7567a3a148740449213b855560deedb}
// Keltner Channel
// 30min
input: stoploss_pct_long(2.4, "trailing stop % for long"), stoploss_pct_short(0.5, "trailing stop % for short");
input: _contracts(1, "number of contracts"), _short(True, "short selling");
input: ma_period(45, "period for MA"), atr_period(45, "period for ATR");
input: atr_mult_upper(2, "multiplier for ATR upper band"), atr_mult_lower(1.5, "multiplier for ATR lower band");
var: _upper(0), _middle(0), _lower(0);

_middle = average(close, ma_period);
_upper = _middle + atr_mult_upper*ATR(atr_period);
_lower = _middle - atr_mult_lower*ATR(atr_period);

if Position = 0 then begin
	if close[2] > _middle[2] and close[2] < _upper[2] and
	   close[1] > _upper[1] and
	   close > high[1] then
	   SetPosition(_contracts, label:="Long_Entry");
	if _short then begin
		if close[2] > _lower[2] and close[2] < _middle[2] and
		   close[1] < _lower[1] and
		   close < low[1] then
		   SetPosition(-_contracts, label:="Short_Entry");
	end;
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