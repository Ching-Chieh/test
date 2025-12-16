{@type:autotrade|@guid:589e59d3e07d4ce6a2b6737e4e185192}
// VWMA Crossing Strategy
// 20min
input: _contracts(1, "number of contracts");
input: short_period(60, "period for fast MA"), long_period(70, "period for slow MA");
input: enter_period(47, "period for MA enter"), exit_period(45, "period for MA exit");
var: vwma_short(0), vwma_long(0), vwma_enter(0), vwma_exit(0);

vwma_short = VWMA(close, short_period);
vwma_long = VWMA(close, long_period);
vwma_enter = VWMA(close, enter_period);
vwma_exit = VWMA(close, exit_period);

condition1 = vwma_short > vwma_long and close cross above vwma_enter;
condition2 = vwma_short < vwma_long and close cross below vwma_enter;
condition3 = close cross below vwma_exit;
condition4 = close cross above vwma_exit;

if Position = 0 then begin
	if condition1 then SetPosition(_contracts, label:="Long_Entry");
	if condition2 then SetPosition(-_contracts, label:="Short_Entry");
end;

if Filled > 0 and Position = Filled then begin
	if condition3 then SetPosition(0, label:="Long_Exit");
end;

if Filled < 0 and Position = Filled then begin
	if condition4 then SetPosition(0, label:="Short_Exit");
end;