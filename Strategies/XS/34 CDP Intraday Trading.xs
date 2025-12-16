{@type:autotrade|@guid:75d7ea5f780e481a97cf18ce984b23d6}
// CDP Intraday Trading
// 10min
input: _contracts(1, "number of contracts"), _short(True, "short selling");
var: CDP(0), AH(0), NH(0), NL(0), AL(0);

CDP = (HighD(1) + LowD(1) + 2*CloseD(1))*0.25;
AH = CDP + (HighD(1) - LowD(1));
AL = CDP - (HighD(1) - LowD(1));

if Position = 0 then begin
	if close cross below AL then SetPosition(_contracts, label:="Long_Entry");
	if _short and close cross below AH then SetPosition(-_contracts, label:="Short_Entry");
end;

if Position > 0 and close cross below AH then SetPosition(0, label:="Long_Exit");
if Position < 0 and close cross above AL then SetPosition(0, label:="Short_Exit");
