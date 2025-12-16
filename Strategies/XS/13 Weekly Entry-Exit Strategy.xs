{@type:autotrade|@guid:09fd48a42676410eafc5631cd3b46d91}
// Weekly Entry-Exit Strategy
// 5min
// Long strategy: If today is Monday and open is higher than yesterday's close, enter before the close. Exit before Friday's close.
// Short strategy: The opposite conditions apply.
input: _contracts(1, "number of contracts"), wd_entry(5, "Day of the week to enter");
var: wd_exit(0);

If Position = 0 and DayOfWeek(Date) = wd_entry and time = 133000 then begin
   if OpenD(0) > CloseD(1) then SetPosition(_contracts, label:="Long_Entry");
   //if OpenD(0) < CloseD(1) then SetPosition(-_contracts, label:="Short_Entry");
end;

wd_exit = wd_entry + 4;
if wd_exit > 5 then wd_exit = wd_exit - 5;

If Position <> 0 and DayOfWeek(Date) = wd_exit and time = 133000 then SetPosition(0);



