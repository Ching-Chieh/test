{@type:autotrade|@guid:0565bdf80fb947939fd4963180e42295}
// Ichimoku Cloud Simplified
// 20min, Day and night
input: _contracts(1, "number of contracts"), short_period(6, "short period"), long_period(32, "long period");
input: _h(5, "No. of highest bars for short entry");

value1=(highest(high, short_period)+lowest(low, short_period))/2; // conversion_line
value2=(highest(high, long_period)+lowest(low, long_period))/2;   // base_line

// Entry
condition1 = value1[1] < value2[1] and value1 >= value2;
condition2 = value1[1] > value2[1] and value1 <= value2;

if Position = 0 then begin
	if condition1 then SetPosition(_contracts, label:="Long_Entry");
	if condition2 then SetPosition(-_contracts, label:="Short_Entry");
end;

// Exit
condition3 = value1[1] > value2[1] and value1 <= value2;
condition4 = close > highest(high[1], _h);

if Filled > 0 and Position = Filled and condition3 then SetPosition(0, label:="Long_Exit");
if Filled < 0 and Position = Filled and condition4 then SetPosition(0, label:="Short_Exit");

