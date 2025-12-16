{@type:autotrade|@guid:f5417a8080194c95b7fc6e19ec250732}
// FITE FITF Spread Trading
// 30min
input: _ma(14, "period for MA"), _contracts(1, "number of contracts");
var: close_1(0), close_2(0), symbol_1(""), symbol_2("");

symbol_1 = "FITE*1.TF";
symbol_2 = "FITF*1.TF";

close_1 = getsymbolField("FITE*1.TF", "Close");
close_2 = getsymbolField("FITF*1.TF", "Close");

value1 = (close_1 - close_2) / close_1;
value2 = average(value1, _ma);

condition1 = value1 cross above value2;
condition2 = value1 cross below value2;

// Entry
if Position = 0 and condition1 then begin
	if symbol = symbol_1 then SetPosition(_contracts);
	if symbol = symbol_2 then SetPosition(-_contracts);
end;

// Exit
if Position <> 0 and condition2 then SetPosition(0);


