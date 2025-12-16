{@type:autotrade|@guid:80b6cd80711742ea9735168360fbb665}
// Directional Movement Index
// 5min
input: stoploss_pct(1, "trailing stoploss%"), _contracts(1, "number of contracts"), ADX_num(20, "ADX");
var: _pDI(0), _nDI(0), _ADX(0);

value1 = DirectionMovement(14, _pDI, _nDI, _ADX);

if Position = 0 then begin
	if _pDI cross above _nDI and // TrueAll(_ADX[1] < _ADX, 2) and
	   _ADX >= ADX_num then
	    SetPosition(_contracts, label:="Long_Entry");
	if _nDI cross above _pDI and // TrueAll(_ADX[1] < _ADX, 2) and
	   _ADX >= ADX_num then
	    SetPosition(-_contracts, label:="Short_Entry");
end;

var: intrabarpersist stoploss_price(0);
if Filled > 0 and Position = Filled then begin
	if stoploss_price = 0 then
		stoploss_price = FilledAvgPrice*(1 - stoploss_pct*0.01);
		
	if Close > FilledAvgPrice then begin
		if Close*(1 - stoploss_pct*0.01) > stoploss_price then
			stoploss_price = Close*(1 - stoploss_pct*0.01);
	end;

	if Close <= stoploss_price then begin
		SetPosition(0, label:="Long_Exit");
		stoploss_price = 0;
	end;
end;

if Filled < 0 and Position = Filled then begin
	if stoploss_price = 0 then
		stoploss_price = FilledAvgPrice*(1 + stoploss_pct*0.01);
		
	if Close < FilledAvgPrice then begin
		if Close*(1 + stoploss_pct*0.01) < stoploss_price then
			stoploss_price = Close*(1 + stoploss_pct*0.01);
	end;

	if Close >= stoploss_price then begin
		SetPosition(0, label:="Short_Exit");
		stoploss_price = 0;
	end;
end;