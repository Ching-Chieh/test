{@type:autotrade|@guid:f80090879bc5434ab53e744c45f3d403}
// ABS Swing Trading
// 10min
input: stoploss_pct(3, "trailing stoploss%"), _contracts(1, "number of contracts"), _short(False, "short selling");
input: d_threshold(40, "threshold for D"), ma_period(5, "period for MA");
var: _K(0), _D(0);

value1 = absValue(open - close);
value2 = Stochastic(13, 3, 3, value2, _K, _D);

if Position = 0 then begin
	if _D > d_threshold and close > open and value1 > average(value1[1], ma_period) then SetPosition(_contracts, label:="Long_Entry");
	if _short then begin
		if _D < d_threshold and close < open and value1 > average(value1[1], ma_period) then SetPosition(-_contracts, label:="Short_Entry");
	end;
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