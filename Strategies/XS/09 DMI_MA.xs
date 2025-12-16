{@type:autotrade|@guid:b897a611a36047e6a4337dc2d2b63c8e}
// DMI with Moving Average
// 5min
input: _contracts(1, "number of contracts"), ADX_num(20, "ADX"), n1(30, "period for fast MA"), n2(50, "period for slow MA");
var: _pDI(0), _nDI(0), _ADX(0);

value1 = DirectionMovement(14, _pDI, _nDI, _ADX);

if Position = 0 then begin
	if _pDI cross above _nDI and _ADX >= ADX_num then SetPosition(_contracts, label:="Long_Entry");
	if _nDI cross above _pDI and _ADX >= ADX_num then SetPosition(-_contracts, label:="Short_Entry");
end;


// Exit for long positions
if Filled > 0 and Position = Filled then begin
	if average(close, n1) cross below average(close, n2) then SetPosition(0, label:="Long_Exit");
end;

// Exit for short positions
if Filled < 0 and Position = Filled then begin
	if average(close, n1) cross above average(close, n2) then SetPosition(0, label:="Short_Exit");
end;
