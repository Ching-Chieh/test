{@type:autotrade|@guid:351b61709e7347fcbe9d0c9d275dcdc7}
// 布林天羅地網
// 60分K
input: lots(1, "口數"), n(28, "中軌均線期數");
value1 = BollingerBand(Close, n, 1.2);
value2 = BollingerBand(Close, n, 1);
value3 = average(Close, n);
value4 = BollingerBand(Close, n, -1);
value5 = BollingerBand(Close, n, -1.4);

if Position = 0 then begin
	if close > value3 and close cross above value2 then SetPosition(lots, label:="多單進場");
	if close < value3 and close cross below value4 then SetPosition(-lots, label:="空單進場");
end;

if Position = lots then begin
	if close cross below value1 then SetPosition(0, label:="多單出場");
end;
if Position = -lots then begin
	if close cross above value5 then SetPosition(0, label:="空單出場");
end;