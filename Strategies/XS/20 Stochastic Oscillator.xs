{@type:autotrade|@guid:b0583571dde04c77b4cab17b739c1059}
// Stochastic Oscillator
// 30min
input: _contracts(1, "number of contracts");
input: stoploss_pct_long(2.9, "trailing stop % for long"), stoploss_pct_short(0.95, "trailing stop % for short");
input: fast_k_period(30, "fast_k_period"), slow_k_period(30, "slow_k_period"), slow_d_period(17, "slow_d_period");
input: high_value(69, "kd high value"), low_value(25, "kd low value");
var: _rsv(0), _k(0), _d(0);

value1 = Stochastic(fast_k_period, slow_k_period, slow_d_period, _rsv, _k, _d);

// Entry
condition1 = _k >= high_value and _d >= high_value and _k cross below _d;
condition2 = _k <= low_value and _d <= low_value and _k cross over _d;

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
