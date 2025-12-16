{@type:autotrade|@guid:32b9c8ccf93c4381bd6fc1610255e179}
// CCI 修正二
// 15分K
input: lots(1, "口數"), _time(915, "高低點時間");
var: _dailyhigh(0), _dailylow(0), _DIF(0), _DEM(0), _XMACD(0), filter_1(false), filter_2(false);

if isfirstcall("Date") then begin
	_dailyhigh = 0;
	_dailylow = 0;
end;

if time = _time*100 then begin
	_dailyhigh = HighD(0);
	_dailylow = LowD(0);
end;

_DIF = average(close, 12) - average(close, 26);
_DEM = average(_DIF, 9);
_XMACD = _DIF - _DEM;

filter_1 = close > _dailyhigh and
	       high >= highest(high[1], 3) and
	       TrueAll(_XMACD > _XMACD[1], 2);
filter_2 = close < _dailylow and
	       low <= lowest(low[1], 3) and
	       TrueAll(_XMACD < _XMACD[1], 2);

// 進場
if Position = 0 and _dailyhigh > 0 then begin
	//if filter_1 and CCI(6) cross above CCI(12) then SetPosition(lots, label:="多單進場");
	if filter_2 and CCI(6) cross below CCI(12) then SetPosition(-lots, label:="空單進場");
	//if filter_2 and CCI(6) cross below CCI(12) then SetPosition(lots, label:="多單進場");
end;

// 出場
if Position > 0 and Position = Filled then begin
	if CCI(6) cross below CCI(12) then SetPosition(0, label:="多單出場");
end;
if Position < 0 and Position = Filled then begin
	if CCI(6) cross above CCI(12) then SetPosition(0, label:="空單出場");
end;