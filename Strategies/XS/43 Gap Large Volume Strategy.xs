{@type:autotrade|@guid:ae07cb2c9577492a8e717dbeebc462cc}
// Gap Large Volume Strategy
// 5min
input: avg_vol_period(15, "period for avg daily volume"), num(1, "multiplier for est volume"), _time(920, "time for est volume");
input: stoploss_pct_long(3, "trailing stop % for long"), stoploss_pct_short(0.5, "trailing stop % for short"), _contracts(1, "number of contracts");
var: cond_long(False), cond_short(False);

if IsSessionFirstBar then begin
	cond_long = closeD(1) < openD(0) and openD(0) < close; // At 8:45, futures opened with an upward gap, and 1st 5-min candle closed bullish.
	cond_short = closeD(1) > openD(0) and openD(0) > close;// At 8:45, futures opened with an downward gap, and 1st 5-min candle closed bearish.
end;

if Position = 0 and time = _time*100 then begin
	condition1 = GetSymbolField("TSE.TW", "EstimateVolume", "D") > average(GetSymbolField("TSE.TW", "volume", "D")[1], avg_vol_period); // 10 min after the market opens at 9:00, there is a surge in volume.
	if condition1 and cond_long then SetPosition(_contracts, label:="Long_Entry");
	if condition1 and cond_short then SetPosition(-_contracts, label:="Short_Entry");
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