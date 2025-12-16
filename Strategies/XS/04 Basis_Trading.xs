{@type:autotrade|@guid:c31b8015c94a4b91882ec2075e4e0e56}
// Basis_Trading
// 5min
input: stoploss_pct(2, "trailing stoploss%"), _contracts(1, "number of contracts"), spread_high(100), spread_low(-115);
var: spread(0);

spread = close - GetSymbolField("TSE.TW", "Close");
// Between 8:45–9:00 and 13:30–13:45, GetSymbolField("TSE.TW", "Close") carries over the previous value instead of returning 0.
// Entry
// Enter positions during 8:45–9:00 and 13:30–13:45 when TAIEX and FITX are out of sync, so we don't restrict the trading time.
if Position = 0 then begin
	if spread cross above spread_low then SetPosition(_contracts, label:="Long_Entry");
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