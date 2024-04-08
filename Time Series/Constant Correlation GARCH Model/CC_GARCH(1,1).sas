dm 'odsresults;  clear';
dm 'log; clear; output; clear;';
PROC IMPORT OUT= WORK.da 
            DATAFILE= "C:\Users\Jimmy\Desktop\d-spcscointc.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
proc varmax data=da;
   model sp csco intc;
   garch p=1 q=1 form=ccc;
run;
