{@type:autotrade|@guid:db22dab849e5452ea4b7d4bdf230def2}
// RSI
// 5min
input: stoploss_pct(2, "trailing stoploss%"), _contracts(1, "number of contracts"), rsi_high(70, "RSI high value"), rsi_low(30, "RSI low value");
var: _rsi(0);

_rsi = RSI(close, 14);

condition2 = _rsi cross below rsi_low;

if Position = 0 then begin
	if condition2 then SetPosition(_contracts, label:="Long_Entry");
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