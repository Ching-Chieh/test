{@type:autotrade|@guid:002cc475e85c459d8415f295b315f623}
// Awesome_Oscillator_1

// 5min
// short_period= 17, long_period= 25, stoploss_pct_long= 2.5, stoploss_pct_short= 1.6
// Net Profit= 5,490,310, (Long: 3,723,522, Short: 1,766,788)

// 10min
// short_period= 20, long_period= 21, stoploss_pct_long= 1.77, stoploss_pct_short= 1.42
// Net Profit= 5,885,066, (Long: 4,124,924, Short: 1,760,142)

// 15min
// short_period= 5, long_period= 16, stoploss_pct_long= 2.4, stoploss_pct_short= 2.5
// Net Profit= 5,313,836, (Long: 3,981,178, Short: 1,332,658)

input: _contracts(1, "number of contracts");
input: short_period(20, "short period"), long_period(21, "long period");
input: stoploss_pct_long(1.77, "trailing stop % for long"), stoploss_pct_short(1.42, "trailing stop % for short");

var: mid_price(0), ao(0);

mid_price = 0.5*(high + low);
ao = average(mid_price, short_period) - average(mid_price, long_period);

// Entry
condition1 = ao cross above 0;
condition2 = ao cross below 0;

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
