{@type:autotrade|@guid:9ffc24d636454fd8b568c85d08aed3ef}
// Awesome_Oscillator_3

// 5min
// short_period= 11, long_period= 50, stoploss_pct_long= 3, stoploss_pct_short= 2.5
// Net Profit= 5,549,364, (Long: 4,135,310, Short: 1,414,054)

// 10min
// short_period= 3, long_period= 37, stoploss_pct_long= 3, stoploss_pct_short= 2.7
// Net Profit= 5,398,548, (Long: 3,905,156, Short: 1,493,392)

// 15min
// short_period= 15, long_period= 47, stoploss_pct_long= 1.8, stoploss_pct_short= 0.85
// Net Profit= 5,364,984, (Long: 3,996,944, Short: 1,368,040)

// 30min
// short_period= 3, long_period= 38, stoploss_pct_long= 1.9, stoploss_pct_short= 0.2
// Net Profit= 5,078,488, (Long: 4,411,514, Short: 666,974)

input: _contracts(1, "number of contracts");
input: short_period(11, "short period"), long_period(50, "long period");
input: stoploss_pct_long(3, "trailing stop % for long"), stoploss_pct_short(2.5, "trailing stop % for short");
var: mid_price(0), ao(0), p1(0), p2(0), l1(0), l2(0);

mid_price = 0.5*(high + low);
ao = average(mid_price, short_period) - average(mid_price, long_period);
// find two most recent peaks
p1 = SwingHighBar(ao, 60, 1, 1, 2);  // p1, p2(recent)
p2 = SwingHighBar(ao, 60, 1, 1, 1);
// find two most recent lows
l1 = SwingLowBar(ao, 60, 1, 1, 2);   // l1, l2(recent)
l2 = SwingLowBar(ao, 60, 1, 1, 1);

// Entry
condition1 = False;
condition2 = False;
if l1 <> -1 and l2 <> -1 then begin
	if ao[l1] < 0 and ao[l2] < 0 and ao[l1] < ao[l2] then condition1 = True;
end;
if p1 <> -1 and p2 <> -1 then begin
	if ao[p1] > 0 and ao[p2] > 0 and ao[p1] > ao[p2] then condition2 = True;
end;

if Position = 0 then begin
	if condition1 then SetPosition(_contracts, label:="Long_entry");
	if condition2 then SetPosition(-_contracts, label:="Short_entry");
end;

var: intrabarpersist stoploss_price(0);
// Exit for long positions
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

// Exit for short positions
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
