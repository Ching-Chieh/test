{@type:autotrade|@guid:4b60cb4f53e14996b1852b9c21b1dff9}
// Dual-Timeframe RSI Channel
// 5min
// Long strategy: Long when 30-min RSI crosses above 60(B). Exit when 5-min RSI crosses below 75(A).
// Short strategy: Short when 30-min RSI crosses below 40(C). Exit when 5-min RSI crosses above 25(D).
// A
// B
// C
// D
input: _contracts(1, "number of contracts"), _A(80, "A"), _B(54, "B"), _C(40, "C"), _D(25, "D"); // C D是short參數，沒有最佳化
var: long_entry_condition(false), long_exit_condition(false), short_entry_condition(false), short_exit_condition(false);


long_entry_condition = xfMin_RSI("30", GetField("Close","30"), 14) cross above _B;
long_exit_condition = RSI(close, 14) cross below _A;

short_entry_condition = xfMin_RSI("30", GetField("Close","30"), 14) cross below _C;
short_exit_condition = RSI(close, 14) cross above _D;

if Position = 0 then begin
	if long_entry_condition then SetPosition(_contracts, label:="Long_Entry");
	//if short_entry_condition then SetPosition(-_contracts, label:="Short_Entry");
end;

if Position > 0 and Position = Filled and long_exit_condition then SetPosition(0, label:="Long_Exit");
if Position < 0 and Position = Filled and short_exit_condition then SetPosition(0, label:="Short_Exit");