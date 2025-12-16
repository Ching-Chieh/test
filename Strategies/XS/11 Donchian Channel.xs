{@type:autotrade|@guid:82c09f6ff42c4b9198b103d273e74b64}
// Donchian Channel
// 日K
{
價格突破 20 日上軌 → 進場
價格創新高 → 加碼
跌破 10 日下軌 → 出場
}
input: n_long(20, "長天數"), n_short(16, "短天數"), lots(1, "口數");
var: _upper_long(0), _middle_long(0), _lower_long(0);
var: _upper_short(0), _middle_short(0), _lower_short(0);

_upper_long = highest(high[1], n_long);
_lower_long = lowest(low[1], n_long);
//_middle_long = 0.5*(_upper_long + _lower_long);

_upper_short = highest(high[1], n_short);
_lower_short = lowest(low[1], n_short);
//_middle_short = 0.5*(_upper_short + _lower_short);


if Position = 0 then begin
	if close cross above _upper_long then SetPosition(lots, label:="多單進場");
	//if close cross below _lower_long then SetPosition(-lots, label:="空單進場");
end;

if Position <> 0 then begin
	if Position > 0 then begin
		if close cross below _lower_short then SetPosition(0, label:="多單出場");
		//if high > highest(high[1], 3) then SetPosition(Position+1, label:="多單加碼");
	end;
	if Position < 0 then begin
		if close cross above _upper_short then SetPosition(0, label:="空單出場");
		//if low < lowest(low[1], 3) then SetPosition(Position-1, label:="空單加碼");
	end;
end;

