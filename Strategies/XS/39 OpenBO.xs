{@type:autotrade|@guid:19cd8db9cb6a40e4a621c49bdb0ac5fa}
// OpenBO
// 5min
input: long_num(0.68, "multiplier(long)%"), short_num(0.15, "multiplier(short)%");
input: stoploss_pct_long(1.8, "trailing stop % for long"), stoploss_pct_short(0.64, "trailing stop % for short"), _contracts(1, "number of contracts");

if Position = 0 then begin
	if close > openD(0)*(1+long_num*0.01) then SetPosition(_contracts, label:="Long_Entry");
	if close < openD(0)*(1-short_num*0.01) then SetPosition(-_contracts, label:="Short_Entry");
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