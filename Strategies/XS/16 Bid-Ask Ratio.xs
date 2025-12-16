{@type:autotrade|@guid:f993fc656d1a440ea803c10a77311185}
// Bid-Ask Ratio(內外盤比)
// 5min
input: stoploss_pct(2, "trailing stoploss%"), _contracts(1, "number of contracts"), _time(910, "time for bid-ask ratio");

// XQ即時指標 定義: 內外盤成交比 = 累積至當時的外盤成交張數 /（累積至當時的內盤成交張數+累積至當時的外盤成交張數）

if time = _time*100 then
	value1 = GetField("外盤量", "D") / (GetField("內盤量", "D") + GetField("外盤量", "D")) * 100;

if time = _time*100 + 500 then
	value2 = GetField("外盤量", "D") / (GetField("內盤量", "D") + GetField("外盤量", "D")) * 100;

if time = _time*100 + 1000 then
	value3 = GetField("外盤量", "D") / (GetField("內盤量", "D") + GetField("外盤量", "D")) * 100;

var: intrabarpersist stoploss_price(0);

if time >= _time*100 + 1500 then begin
	// Entry
	if Position = 0 then begin
		//if value1 < value2 and value2 < value3 then SetPosition(_contracts, label:="Long_Entry");
		//if value1 > value2 and value2 > value3 then SetPosition(-_contracts, label:="Short_Entry");
		if value1 > value2 and value2 > value3 then SetPosition(_contracts, label:="Long_Entry");
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
