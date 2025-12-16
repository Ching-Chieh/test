{@type:autotrade|@guid:28dc5b84998c4ad4865381e45fb9728d}
// Turtle Trading Rules
// day
input: _contracts(1, "number of contracts");
input: entry_high_period(5), entry_low_period(38);
input: exit_high_period(3), exit_low_period(37);

if Position = 0 then begin
	if close cross above highest(high[1], entry_high_period) then SetPosition(_contracts, label:="Long_Entry");
	if close cross below lowest(low[1], entry_low_period) then SetPosition(-_contracts, label:="Short_Entry");
end;

if Filled > 0 and Position = Filled then begin
	if close cross below lowest(low[1], exit_low_period) then SetPosition(0, label:="Long_Exit");
end;
if Filled < 0 and Position = Filled then begin
	if close cross above highest(high[1], exit_high_period) then SetPosition(0, label:="Short_Exit");
end;