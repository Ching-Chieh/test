{@type:autotrade|@guid:ba763d2e366d4c6b9722d695537aed33}
// Institutional Options OI
// 5min
input: _p(2700), _c(4000), stoploss_pct(2, "trailing stoploss%"), _contracts(1, "number of contracts");
var: _call_f(0), _call_d(0), _put_f(0), _put_d(0), _call_OI_change(0), _put_OI_change(0);
_call_f = GetSymbolField("TXO00.TF", "外資賣方未平倉口數", "D", param:="CALL")[1] -
          GetSymbolField("TXO00.TF", "外資賣方未平倉口數", "D", param:="CALL")[2];
_call_d = GetSymbolField("TXO00.TF", "自營商賣方未平倉口數", "D", param:="CALL")[1] -
          GetSymbolField("TXO00.TF", "自營商賣方未平倉口數", "D", param:="CALL")[2];
_put_f  = GetSymbolField("TXO00.TF", "外資賣方未平倉口數", "D", param:="PUT")[1] -
          GetSymbolField("TXO00.TF", "外資賣方未平倉口數", "D", param:="PUT")[2];
_put_d  = GetSymbolField("TXO00.TF", "自營商賣方未平倉口數", "D", param:="PUT")[1] -
          GetSymbolField("TXO00.TF", "自營商賣方未平倉口數", "D", param:="PUT")[2];

_call_OI_change = _call_f; //+ _call_d;
_put_OI_change = _put_f;// + _put_d;

// Entry
if Position = 0 then begin
	// Long positions when short put open interest increases.
	if _put_OI_change >= _p then SetPosition(_contracts, label:="Long_Entry");
	
	// Short positions when short call open interest increases.
	if _call_OI_change >= _c then SetPosition(-_contracts, label:="Short_Entry");
end;

var: intrabarpersist stoploss_price(0);
// Exit for long positions
if Filled > 0 and Position = Filled then begin
	if stoploss_price = 0 then
		stoploss_price = FilledAvgPrice*(1 - stoploss_pct*0.01);
		
	if Close > FilledAvgPrice then begin
		if Close*(1 - stoploss_pct*0.01) > stoploss_price then
			stoploss_price = Close*(1 - stoploss_pct*0.01);
	end;

	if Close <= stoploss_price then begin
		SetPosition(0, label:="Long_Exit");
		stoploss_price = 0;
	end;
end;

// Exit for short positions
if Filled < 0 and Position = Filled then begin
	if stoploss_price = 0 then
		stoploss_price = FilledAvgPrice*(1 + stoploss_pct*0.01);
		
	if Close < FilledAvgPrice then begin
		if Close*(1 + stoploss_pct*0.01) < stoploss_price then
			stoploss_price = Close*(1 + stoploss_pct*0.01);
	end;

	if Close >= stoploss_price then begin
		SetPosition(0, label:="Short_Exit");
		stoploss_price = 0;
	end;
end;

