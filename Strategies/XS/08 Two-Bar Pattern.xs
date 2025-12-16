{@type:autotrade|@guid:b96ab51879124f03b147c78e75dc3fcd}
// Two-Bar Pattern
// day
// Long when yesterday opened higher but closed lower
// Short when yesterday opened lower but closed higher
input: stoploss_pct(3, "trailing stoploss%"), _contracts(1, "number of contracts"), _short(False, "short selling");

condition1 = openD(1) > closeD(2) and closeD(1) < openD(1);
condition2 = openD(1) < closeD(2) and closeD(1) > openD(1);

// Entry
if Position = 0 then begin 
	if condition1 then SetPosition(_contracts, label:="Long_Entry");
	if _short and condition2 then SetPosition(-_contracts, label:="Short_Entry");
end;

var: intrabarPersist stoploss_price(0);
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


