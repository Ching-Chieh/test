{@type:autotrade|@guid:9408aa877d1b40fbbd43a529cc5d11d3}
// Aberration Swing Trading
// 60min
input: _contracts(1, "number of contracts"), take_profit_pct(2.5), profit_drawback_pct(2.2), _short(false, "short selling");
input: middle_ma_n(60, "period for middle line"), sd_n(30, "period for sd"), sd_m(1, "multiplier for sd");

var: _middle(0), _upper(0), _lower(0);

_middle = average(0.5*(high[1]+low[1]), middle_ma_n);
_upper = _middle + sd_m*standardDev(_middle, sd_n, 2);
_lower = _middle - sd_m*standardDev(_middle, sd_n, 2);

if Position = 0 then begin
	if close cross over _upper then SetPosition(_contracts, label:="Long_Entry");
	if _short then begin
		if close cross below _lower then SetPosition(-_contracts, label:="Short_Entry");
	end;
end;

if Filled > 0 and Position = Filled then begin
	var: stoploss_price_long(0);
	var: intrabarpersist take_profit_price_long(0), intrabarpersist profit_drawback_price_long(0);
	
	stoploss_price_long = _middle;
	
	if take_profit_price_long = 0 and Close >= FilledAvgPrice*(1 + take_profit_pct*0.01) then begin
		take_profit_price_long = Close;
		profit_drawback_price_long = take_profit_price_long*(1 - profit_drawback_pct*0.01);
	end;
	
	if take_profit_price_long <> 0 then begin
		if Close <= profit_drawback_price_long then begin
			SetPosition(0, label:="profit taking(long)");
			take_profit_price_long = 0;
			profit_drawback_price_long = 0;
		end else if Close > take_profit_price_long then begin
			take_profit_price_long = Close;
			profit_drawback_price_long = take_profit_price_long*(1 - profit_drawback_pct*0.01);
		end;
	end else if Close <= stoploss_price_long then SetPosition(0, label:="stoploss(long)");
end;

if Filled < 0 and Position = Filled then begin
	var: stoploss_price_short(0);
	var: intrabarpersist take_profit_price_short(0), intrabarpersist profit_drawback_price_short(0);
	
	stoploss_price_short = _middle;
	
	if take_profit_price_short = 0 and Close <= FilledAvgPrice*(1 - take_profit_pct*0.01) then begin
		take_profit_price_short = Close;
		profit_drawback_price_short = take_profit_price_short*(1 + profit_drawback_pct*0.01);
	end;
	
	if take_profit_price_short <> 0 then begin
		if Close >= profit_drawback_price_short then begin
			SetPosition(0, label:="profit taking(short)");
			take_profit_price_short = 0;
			profit_drawback_price_short = 0;
		end else if Close < take_profit_price_short then begin
			take_profit_price_short = Close;
			profit_drawback_price_short = take_profit_price_short*(1 + profit_drawback_pct*0.01);
		end;
	end else if Close >= stoploss_price_short then SetPosition(0, label:="stoploss(short)");
end;

