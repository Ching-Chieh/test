{@type:autotrade|@guid:dd2755ab43f944e59d516340ec9cf114}
// Momentum
// 15min
input: _contracts(1, "number of contracts"), period(75, "period for MTM"), ma_period(95, "period for MA of MTM"), baseline(20);
var: _mtm(0), _ma(0);

_mtm = Momentum(Close, period);
_ma = average(_mtm, ma_period);

if Position = 0 then begin
	if _mtm cross below baseline then SetPosition(_contracts, label:="Long_Entry");
end;

if Filled > 0 and Position = Filled then begin
	if _mtm cross below _ma or _mtm cross above _ma then SetPosition(0, label:="Long_Exit");
end;