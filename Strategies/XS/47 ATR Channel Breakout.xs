{@type:autotrade|@guid:b47c04174b094c16bdc499112369bd11}
// ATR Channel Breakout
// day
input: _contracts(1, "number of contracts"), _short(True, "short selling");
input: MAlen(10, "period for MA"), ATRlen(60, "period for ATR"), N1(2, "multiplier for upper"), N2(3, "multiplier for lower");
var: _upper(0), _lower(0), _atr(0);

_atr = average(truerange, ATRlen);
value2 = average(close, MAlen);
_upper = value2 + N1 * _atr;
_lower = value2 - N2 * _atr;

if Position = 0 then begin
	if close crosses over _upper then SetPosition(_contracts, label:="Long_Entry");
	if _short and close crosses below _lower then SetPosition(-_contracts, label:="Short_Entry");
end;

if Filled > 0 then begin
	if close crosses below _lower then SetPosition(0, label:="Long_Exit");
end;
if Filled < 0 then begin
	if close crosses over _upper then SetPosition(0, label:="Short_Exit");
end;
