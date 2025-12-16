{@type:autotrade|@guid:bd0dc0c43a7842bbb15ebb3a7c14d37a}
// CDP當沖 修正三 順勢
// 5分K
input: lots(1, "口數"), _short(True, "是否作空");
var: CDP(0), AH(0), NH(0), NL(0), AL(0);

CDP = (HighD(1) + LowD(1) + 2*CloseD(1))*0.25;
AH = CDP + (HighD(1) - LowD(1));
NH = 2*CDP - LowD(1);
NL = 2*CDP - HighD(1);
AL = CDP - (HighD(1) - LowD(1));

if Position = 0 then begin
	if close cross above AH then SetPosition(lots, label:="多單進場");
	if _short and close cross below AL then SetPosition(-lots, label:="空單進場");
end;

if Position = lots and close cross below NH then SetPosition(0, label:="多單出場");
if Position = -lots and close cross above NL then SetPosition(0, label:="空單出場");
