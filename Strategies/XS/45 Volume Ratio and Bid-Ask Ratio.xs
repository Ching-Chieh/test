{@type:autotrade|@guid:90e7eb6e0a7149889ebba994d85cf808}
// Volume Ratio and Bid-Ask Ratio
// 5min
input: stoploss_pct(2, "trailing stoploss%"), _contracts(1, "number of contracts"), num(1, "multiplier for est volume");
input: num1(51, "high bid-ask ratio"), num2(49, "low bid-ask ratio");
var: estvol(0), avgvol(0);

if isfirstcall("Date") then begin
	estvol = 0;
	avgvol = average(GetSymbolField("TSE.TW", "volume", "D")[1], 5);
end;

if time = 90500 then estvol = GetSymbolField("TSE.TW", "EstimateVolume", "D");

if time = 91000 then begin
	if Position = 0 then begin
		condition1 = estvol > num*avgvol; // 5 mins after the market opens at 9:00, there is a surge in volume.
		value1 = GetField("TradeVolumeAtAsk", "D") / (GetField("TradeVolumeAtBid", "D") + GetField("TradeVolumeAtAsk", "D")) * 100;
		if condition1 and value1 > num1 then SetPosition(_contracts, label:="Long_Entry");
		if condition1 and value1 < num2 then SetPosition(-_contracts, label:="Short_Entry");
	end;
end;
	

var: intrabarpersist stoploss_price(0);
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