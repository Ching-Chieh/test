{@type:autotrade|@guid:f3580408c8164e8eb73c4ac4069fb6b9}
// Contrarian Bollinger Band Strategy
// 15min
input: _contracts(1, "number of contracts"), period(20, "period for MA"), n(2, "multiplier for BBand");
var: _upper(0), _lower(0);

_upper = BollingerBand(Close, period, n);
_lower = BollingerBand(Close, period, -n);

if Position = 0 and close cross below _lower then SetPosition(_contracts, label:="Long_Entry");
if Position > 0 and Filled = Position and close cross below _upper then SetPosition(0, label:="Long_Exit");



