{@type:autotrade|@guid:f69f5312fe654658985f123b93b452ae}
// Ichimoku Cloud
// 20min, Day and night
// short_period(17, "short period"), mid_period(30, "mid period"), long_period(32, "long period");
// Using optimized parameters for short positions would reduce net profit, so the original parameters are maintained.

input: _contracts(1, "number of contracts");
input: short_period(9, "short period"), mid_period(26, "mid period"), long_period(52, "long period");
input: _h(2, "No. of highest bars for short entry");

value1=(highest(high, short_period)+lowest(low, short_period))/2; // conversion_line
value2=(highest(high, mid_period)+lowest(low, mid_period))/2;     // base_line
value3=(value1+value2)/2;                                         // leading_A
value4=(highest(high, long_period)+lowest(low, long_period))/2;   // leading_B

// Entry
condition1 = value1[1] < value2[1] and value1 >= value2;
condition2 = close cross below minlist(value3[mid_period], value4[mid_period]);
if Position = 0 then begin
	if condition1 then SetPosition(_contracts, label:="Long_Entry");
	if condition2 then SetPosition(-_contracts, label:="Short_Entry");
end;

// Exit
condition3 = value1[1] > value2[1] and value1 <= value2;
condition4 = close > highest(high[1], _h);
if Filled > 0 and Position = Filled and condition3 then SetPosition(0, label:="Long_Exit");
if Filled < 0 and Position = Filled and condition4 then SetPosition(0, label:="Short_Exit");

