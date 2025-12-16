{@type:autotrade|@guid:26ac49eef5db4457be1fe4b2f1906d02}
// RSI_Trend_Following
// 5min
input: stoploss_pct(3, "trailing stoploss%"), _contracts(1, "number of contracts");
input: rsi_high(75), rsi_low(30), rsi_window(18, "period for RSI");
var: _rsi(0);

_rsi = RSI(close, rsi_window);

// Entry
if Position = 0 then begin 
	if _rsi cross over rsi_high then SetPosition(_contracts, label:="Long_Entry");
	//if _rsi cross below rsi_low then SetPosition(-_contracts, label:="Short_Entry");
end;

var: intrabarpersist stoploss_price(0);
// Exit for long positions
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

// Exit for short positions
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
