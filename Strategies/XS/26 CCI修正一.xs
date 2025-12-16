{@type:autotrade|@guid:f01539f00d944c0f80f5bba61e79d081}
// CCI 修正一
// 日K
// CCI 向上突破 AA (-120) 作多，CCI 向上突破 BB (-70) 出場
// CCI 向下跌破 DD (120) 作空，CCI 向下跌破  CC (70) 出場
// DD
// CC
// BB 
// AA
input: DD(100), CC(50), BB(-50), AA(-100), cci_n(15, "CCI期數"), lots(1, "口數");
var: long_entry_condition(false), long_exit_condition(false), short_entry_condition(false), short_exit_condition(false);

long_entry_condition = CCI(cci_n) cross above AA;
long_exit_condition = CCI(cci_n) cross above BB;

short_entry_condition = CCI(cci_n) cross below DD;
short_exit_condition = CCI(cci_n) cross below CC;

if Position = 0 then begin
	// if long_entry_condition then SetPosition(lots, label:="多單進場");
	// if short_entry_condition then SetPosition(-lots, label:="空單進場");
	if short_entry_condition then SetPosition(lots, label:="多單進場");
end;

if Position = lots and long_exit_condition then SetPosition(0, label:="多單出場");
if Position = -lots and short_exit_condition then SetPosition(0, label:="空單出場");

