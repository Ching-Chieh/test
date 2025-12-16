{@type:autotrade|@guid:801fa82cd6e24cefbc049a87b3e24415}
// Commodity Channel Index
// day
// DD
// CC
// BB 
// AA
input: DD(128), CC(48), BB(-46), AA(-97), cci_n(8, "period for CCI"), _contracts(1, "number of contracts");
var: long_entry_condition(false), long_exit_condition(false), short_entry_condition(False), short_exit_condition(False);

long_entry_condition = CCI(cci_n) cross above AA;
long_exit_condition = CCI(cci_n) cross above BB;

short_entry_condition = CCI(cci_n) cross below DD;
short_exit_condition = CCI(cci_n) cross below CC;

if Position = 0 then begin
	if long_entry_condition then SetPosition(_contracts, label:="Long_Entry");
	if short_entry_condition then SetPosition(-_contracts, label:="Short_Entry");
end;

if Position > 0 and long_exit_condition then SetPosition(0, label:="Long_Exit");
if Position < 0 and short_exit_condition then SetPosition(0, label:="Short_Exit");

