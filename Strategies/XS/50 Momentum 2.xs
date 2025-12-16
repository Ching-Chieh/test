{@type:autotrade|@guid:73d9c9276f0b423188fadcc1eed33b34}
// Momentum 2
// 15min
input: _contracts(1, "number of contracts"), period(85, "period for MTM"), ma_period(80, "period for MA of MTM"), baseline(2);
var: _mtm(0), _ma(0);

_mtm = (Close/close[period]-1)*100;
_ma = average(_mtm, ma_period);

if Position = 0 then begin
	if _mtm cross below baseline then SetPosition(_contracts, label:="Long_Entry");
end;

if Filled > 0 and Position = Filled then begin
	if _mtm cross below _ma then SetPosition(0, label:="Long_Exit");
end;