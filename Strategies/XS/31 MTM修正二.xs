{@type:autotrade|@guid:1b90399e6b7849688b53be5475d7d55b}
// MTM修正三
// 分K
input: stoploss_pct(2, "移動停損%"), lots(1, "口數"), mtm_short_n(10, "MTM短期"), mtm_long_n(60, "MTM長期");
var: mtm_short(0), mtm_long(0), _high(0), _low(0), _DIF(0), _DEM(0), _XMACD(0), filter_1(false), filter_2(false);

mtm_short = Momentum(Close, mtm_short_n);
mtm_long = Momentum(Close, mtm_long_n);

if isfirstcall("Date") then begin
	_high = 0;
	_low = 0;
end;

if time = 91500 then begin
	_high = HighD(0);
	_low = LowD(0);
end;

_DIF = average(close, 12) - average(close, 26);
_DEM = average(_DIF, 9);
_XMACD = _DIF - _DEM;

filter_1 = close > _high and
	       high >= highest(high[1], 3) + 5 and
	       TrueAll(_XMACD > _XMACD[1], 2);
filter_2 = close < _low and
	       low <= lowest(low[1], 3) - 5 and
	       TrueAll(_XMACD < _XMACD[1], 2);

// 進場
if Position = 0 and _high > 0 then begin
	if mtm_short cross above mtm_long and filter_1 then SetPosition(lots, label:="多單進場");
	if mtm_short cross below mtm_long and filter_2 then SetPosition(-lots, label:="空單進場");
end;

// 多單出場
var: intrabarpersist stoploss_price(0);
if Filled = lots and Position = Filled then begin
	if stoploss_price = 0 then
		stoploss_price = FilledAvgPrice*(1 - stoploss_pct*0.01);
		
	if Close > FilledAvgPrice then begin
		if Close*(1 - stoploss_pct*0.01) > stoploss_price then
			stoploss_price = Close*(1 - stoploss_pct*0.01);
	end;

	if Close <= stoploss_price then begin
		SetPosition(0, label:="多單出場");
		stoploss_price = 0;
	end;
end;

// 空單出場
if Filled = -lots and Position = Filled then begin
	if stoploss_price = 0 then
		stoploss_price = FilledAvgPrice*(1 + stoploss_pct*0.01);
		
	if Close < FilledAvgPrice then begin
		if Close*(1 + stoploss_pct*0.01) < stoploss_price then
			stoploss_price = Close*(1 + stoploss_pct*0.01);
	end;

	if Close >= stoploss_price then begin
		SetPosition(0, label:="空單出場");
		stoploss_price = 0;
	end;
end;