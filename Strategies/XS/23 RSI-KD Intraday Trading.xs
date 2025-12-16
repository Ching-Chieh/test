{@type:autotrade|@guid:febb831623424cbf8db82559e4f19102}
// RSI-KD Intraday Trading
// 5min
input: stoploss_pct(2, "trailing stoploss%"), _contracts(1, "number of contracts"), kd_high(75), kd_low(30), rsi_high(65), rsi_low(45);
var: _rsv(0), _k(0), _d(0), _rsi(0);

value1 = Stochastic(9,3,3, _rsv, _k, _d);
_rsi = RSI(close, 6);

if Position = 0 then begin
    if _k <= kd_low and _d <= kd_low and
	   _k cross above _d and
	   _rsi <= rsi_low then
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