{@type:autotrade|@guid:387199b278544bd5882ac0ebed66bfd0}
// High Low Channel with Moving Average
// day
input: _contracts(1, "number of contracts"), high_period(5, "period for High"), low_period(3, "period for Low");
input: long_exit_ma_period(20), short_exit_ma_period(20);

if Position = 0 then begin
	if close cross above highest(high[1], high_period) then SetPosition(_contracts, label:="Long_Entry");
	if close cross below lowest(low[1], low_period) then SetPosition(-_contracts, label:="Short_Entry");
end;

if Filled > 0 and Position = Filled then begin
	if close cross below average(close, long_exit_ma_period) then SetPosition(0, label:="Long_Exit");
end;
if Filled < 0 and Position = Filled then begin
	if close cross above average(close, short_exit_ma_period) then SetPosition(0, label:="Short_Exit");
end;