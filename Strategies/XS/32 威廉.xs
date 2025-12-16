{@type:autotrade|@guid:0d5664f35c404a0fbc08c1994bd30171}
// 威廉
// 10分K
input: period(20, "期數");
input: long_out(-20, "long_out"), long_in(-40, "long_in");
input: short_in(-70, "short_in"), short_out(-90, "short_out");

// long_out
// long_in
// short_in
// short_out

input: lots(1, "口數");
value1 = PercentR(period) - 100;

if Position = 0 then begin
	if value1 cross above long_in then SetPosition(lots, label:="多單進場");
	if value1 cross below short_in then SetPosition(-lots, label:="空單進場");
end;

if Position > 0 and Position = Filled then begin
	if value1 cross below long_out then SetPosition(0, label:="多單出場");
end;
if Position < 0 and Position = Filled then begin
	if value1 cross above short_out then SetPosition(0, label:="空單出場");
end;