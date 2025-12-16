{@type:autotrade|@guid:1b4fbe9624314412890a99efd637122a}
// TSMC_Large_Order_Flow_Strength
// 5min
input: stoploss_pct(2, "trailing stoploss%"), _contracts(1, "number of contracts"), mult(1), _time(905, "time for large orders");

if time = _time*100 then begin
	value1 = GetSymbolField("2330.TW", "BidVolume_L", "D") + GetSymbolField("2330.TW", "BidVolume_XL", "D");
	value2 = GetSymbolField("2330.TW", "AskVolume_L", "D") + GetSymbolField("2330.TW", "AskVolume_XL", "D");
end;

var: intrabarpersist stoploss_price(0);
if time >= _time*100 + 500 then begin
	// Entry
	if Position = 0 then begin
		if value1 > mult*value2 then SetPosition(_contracts, label:="Long_Entry");
		//if value2 > mult*value1 then SetPosition(-_contracts, label:="Short_Entry");
	end;
	
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

end;