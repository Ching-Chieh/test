{@type:autotrade|@guid:a1432e3c20ba486d8c990f3e4c15929b}
// Foreign_OI
// 5min
input: stoploss_pct(3, "trailing stoploss%"), _contracts(1, "number of contracts");

value1 = GetField("FINILongOI", "D")[1];
value2 = GetField("FINILongOI", "D")[2];
value3 = GetField("FINILongOI", "D")[3];

value4 = GetField("FINIShortOI", "D")[1];
value5 = GetField("FINIShortOI", "D")[2];
value6 = GetField("FINIShortOI", "D")[3];

// Long
condition1 = value1 > value2 and value2 > value3; // Long open interest keeps increasing
condition2 = value4 < value5 and value5 < value6; // Short open interest keeps decreasing

// Short
condition3 = value1 < value2 and value2 < value3; // Long open interest keeps decreasing
condition4 = value4 > value5 and value5 > value6; // Short open interest keeps increasing

// Entry
if Position = 0 then begin 
	//if (condition1 or condition2) and close cross above average(close, 5) then SetPosition(_contracts, label:="Long_Entry");
	//if (condition3 or condition4) and close cross below average(close, 5) then SetPosition(-_contracts, label:="Short_Entry");
	if (condition3 or condition4) and close cross below average(close, 5) then SetPosition(_contracts, label:="Long_Entry");
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
