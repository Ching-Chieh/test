{@type:autotrade|@guid:3ccf11187bdd45cea007a331c8d31918}
// CCI Crossing Strategy
// 15min
input: _contracts(1, "number of contracts"), stoploss_pct_long(2.5, "trailing stop % for long"), stoploss_pct_short(1, "trailing stop % for short");
input: short_period(38, "period for CCI fast"), long_period(60, "period for CCI low");
var: CCI_fast(0), CCI_slow(0);

CCI_fast = CCI(short_period);
CCI_slow = CCI(long_period);


if Position = 0 then begin
	if CCI_fast cross above CCI_slow then SetPosition(_contracts, label:="Long_Entry");
	if CCI_fast cross below CCI_slow then SetPosition(-_contracts, label:="Short_Entry");
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