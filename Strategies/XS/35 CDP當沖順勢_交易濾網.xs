{@type:autotrade|@guid:8468945f2ff540c6b24d2011e2fb37fa}
// CDP當沖 修正三 順勢 + 3大交易濾網
// 5分K
input: lots(1, "口數");
var: CDP(0), AH(0), NH(0), NL(0), AL(0);
var: _high(0), _low(0), _XMACD(0), filter_1(false), filter_2(false);

if isfirstcall("Date") then begin
	_high = 0;
	_low = 0;
end;

if time = 91500 then begin
	_high = HighD(0);
	_low = LowD(0);
end;

value1 = MACD(weightedclose, 12, 26, 9, value2, value3, _XMACD);

filter_1 = close > _high and
	       high >= highest(high[1], 3) + 5 and
	       TrueAll(_XMACD > _XMACD[1], 2);
filter_2 = close < _low and
	       low <= lowest(low[1], 3) - 5 and
	       TrueAll(_XMACD < _XMACD[1], 2);

CDP = (HighD(1) + LowD(1) + 2*CloseD(1))*0.25;
AH = CDP + (HighD(1) - LowD(1));
NH = 2*CDP - LowD(1);
NL = 2*CDP - HighD(1);
AL = CDP - (HighD(1) - LowD(1));

if Position = 0 and _high > 0 then begin
	if close cross above AH and filter_1 then SetPosition(lots, label:="多單進場");
	if close cross below AL and filter_2 then SetPosition(-lots, label:="空單進場");
end;

if Position = lots and close cross below NH then SetPosition(0, label:="多單出場");
if Position = -lots and close cross above NL then SetPosition(0, label:="空單出場");