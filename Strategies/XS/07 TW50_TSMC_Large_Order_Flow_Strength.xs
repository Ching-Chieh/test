{@type:autotrade|@guid:f48917db2a104794be6f346dea0fcf93}
// TW50_TSMC_Large_Order_Flow_Strength
// 5min
input: stoploss_pct(3, "trailing stoploss%"), _contracts(1, "number of contracts");
input: _time(900, "time for large orders"), _short(False, "short selling");

if time = _time*100 then begin
	value1 = GetSymbolField("0050.TW", "BidVolume_L", "D") + GetSymbolField("0050.TW", "BidVolume_XL", "D");
	value2 = GetSymbolField("0050.TW", "AskVolume_L", "D") + GetSymbolField("0050.TW", "AskVolume_XL", "D");
	value3 = GetSymbolField("2330.TW", "BidVolume_L", "D") + GetSymbolField("2330.TW", "BidVolume_XL", "D");
	value4 = GetSymbolField("2330.TW", "AskVolume_L", "D") + GetSymbolField("2330.TW", "AskVolume_XL", "D");
end;

var: intrabarpersist stoploss_price(0);
if time >= _time*100 + 500 then begin
	// Entry
	if Position = 0 then begin
		if value1 + value3 - (value2 + value4) > 0 then SetPosition(_contracts, label:="Long_Entry");
		if _short and value1 + value3 - (value2 + value4) < 0 then SetPosition(-_contracts, label:="Short_Entry");
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