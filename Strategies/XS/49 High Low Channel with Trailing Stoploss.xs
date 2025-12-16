{@type:autotrade|@guid:e739379db7cd47208f6c573a5bd3958c}
// High Low Channel with Trailing Stoploss
// Frequency is daily. Enter and exit at the last 5-min candle for avoiding tick-by-tick movements.
input: _contracts(1, "number of contracts"), high_period(5, "period for High"), low_period(3, "period for Low");
input: stoploss_pct_long(2.3, "trailing stop % for long"), stoploss_pct_short(2.6, "trailing stop % for short");
var: i(0), recent_high(0), recent_low(0);

recent_high = highD(1);
for i = 2 to high_period
begin
	if highD(i) > recent_high then recent_high = highD(i);
end;

recent_low = lowD(1);
for i = 2 to low_period
begin
	if lowD(i) < recent_low then recent_low = lowD(i);
end;

if Position = 0 and IsSessionLastBar then begin
	if close > recent_high then SetPosition(_contracts, label:="Long_Entry");
	if close < recent_low then SetPosition(-_contracts, label:="Short_Entry");
end;

var: intrabarpersist stoploss_price(0);
if IsSessionLastBar then begin

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

end;