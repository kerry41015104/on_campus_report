
libname local 'C:\Users\user\Desktop\sas\data';
/*------------------------------------------------------part1------------------------------------------------------------------------------------*/
/*   1. start   */
proc sql;
create table exret as select a.id, a.date, a.ret-(b.rf_1year/12) as exret
from local.midtermdata_retprc as a left join local.midtermdata_rf as b
on a.date=b.date
order by date;
quit;

proc sql;
create table data_merge as select a.date, a.id, a.exret, b.mktrf, b.smb, b.hml
from exret as a left join local.midtermdata_ff3ms as b
on month(a.date)=month(b.date) and year(a.date)=year(b.date);
quit;

data data_merge;
set data_merge;
if smb=. then delete;
proc sort;
by id;
run;
/*   1. end   */

/*   2. start   */
proc reg data=data_merge outest=onestep noprint;
model exret=mktrf smb hml;
by id;
run;
/*   2. end   */
/*   3. start   */
proc sql;
create table twostepdata as select a.*,b.mktrf, b.smb, b.hml
from exret as a left join onestep as b
on a.id=b.id;
quit;
/*3.5 */
proc sort data=twostepdata;   
by date;
run;
/*   3. end   */
/*   4. start   */
proc reg data=twostepdata outest=twostep noprint;
model exret=mktrf smb hml;
by date;
run;
/*   4. end   */
/*   5. start   */
proc means data=twostep noprint;
var mktrf smb hml;
output out=fm_result;
run;
/*   5. end   */
/*   6. start   */
ods output ttests=ttest;
proc ttest data=fm_result  H0=0 side=2;
var mktrf smb hml;
run;
ods output  close;
/*   6. end   */
/*--------------------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------part2------------------------------------------------------------------------------------*/

data data_group10;
set local.data_group10;
run;

proc sort data=data_group10;
by date;
run;

proc rank data=data_group10 out=abc groups=10;
var mc;
by date;
ranks rank_mc;
run; /*divide the data into ten quentiles*/

data abc;
set abc;
if rank_mc<=1 then r=1;
if 2<=rank_mc<=4 then r=2;
if rank_mc>=5 then r=3;
run;  

data micro;
set abc(where=(r=1));
run;   /*micro data*/

data small;
set abc(where=(r=2));
run;   /*small data*/

data big;
set abc(where=(r=3));
run;   /*big data*/

data all_micro;
set abc(where=(r~=1));
run;   /* all but micro data*/

proc reg data=micro outest=regmicro rsquare noprint;
model return=mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
by date;
run;
quit;   /*micro regression*/

proc reg data=small outest=regsmall rsquare noprint;
model return=mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
by date;
run;
quit;    /*small regression*/

proc reg data=big outest=regbig rsquare noprint;
model return=mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
by date;
run;
quit;  /*big regression*/

proc reg data=all_micro outest=regall_micro rsquare noprint;
model return=mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
by date;
run;
quit;  /*all but micro regression*/

proc reg data=data_group10 outest=regmarket rsquare noprint;
model return=mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
by date;
run;
quit;  /*all regression*/

proc means data=regmicro noprint;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
output out= ttest_regmicro(drop=_type_ _freq_)  ;
run;   

ods output ttests= T_micro;
proc ttest data=ttest_regmicro  H0=0 side=2;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
run;
ods output  close;    /*micro t-test*/

proc means data=regsmall noprint;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
output out= ttest_regsmall(drop=_type_ _freq_)  ;
run; 

ods output ttests= T_small;
proc ttest data=ttest_regsmall  H0=0 side=2;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
run;
ods output  close;  /*small t-test*/

proc means data=regbig noprint;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
output out= ttest_regbig(drop=_type_ _freq_)  ;
run;

ods output ttests= T_big;
proc ttest data=ttest_regbig  H0=0 side=2;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
run;
ods output  close; /*big t-test*/

proc means data=regmarket noprint;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
output out= ttest_regmarket(drop=_type_ _freq_)  ;
run;

ods output ttests= T_market;
proc ttest data=ttest_regmarket  H0=0 side=2;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
run;
ods output  close; /*all t-test*/

proc means data=regall_micro noprint;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
output out= ttest_regall_micro(drop=_type_ _freq_)  ;
run;

ods output ttests= T_all_marco;
proc ttest data=ttest_regall_micro  H0=0 side=2;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
run;
ods output  close; /*all but micro t-test*/
