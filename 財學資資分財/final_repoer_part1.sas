
libname local 'C:\Users\user\Desktop\sas\data_2';
DM 'log' clear; DM 'output' clear;

data data;
set local.data123;
run;

data local.price;
set local.price_new;
id=substr(id, 1, 4);
drop f5;
run;

data local.price;
set local.price_new;
if id = "9103" then delete;
if id = "9116" then delete;
run;

proc sort data=local.price;
by id;
run;

proc sql;
create table local.mc as select id, date, log(price*shrout) as mc
from local.price(where=(month(date)=6));
quit;

proc sql;
create table local.bmratio as select a.id, a.date, log((a.price*b.shrout)/b.bv) as bm
from local.price(where=(month(date)=6)) as a left join local.bm as b
on a.id=b.id and intck('month', b.date, a.date)=6
order by id, date;
quit;

proc sql;
create table variable as select a.id, a.date, a.mc, b.bm
from local.mc(where=(year(date)not between 2010 and 2011) ) as a 
left join local.bmratio(where=(year(date)not between 2010 and  2011) ) as b
on a.id=b.id and a.date=b.date
order by id, date;
quit;

data mom;
set local.return;
lag2_ret=lag2(return);
lag3_ret=lag3(return);
lag4_ret=lag4(return);
lag5_ret=lag5(return);
lag6_ret=lag6(return);
lag7_ret=lag7(return);
lag8_ret=lag8(return);
lag9_ret=lag9(return);
lag10_ret=lag10(return);
lag11_ret=lag11(return);
lag12_ret=lag12(return);
mom=
((1+lag2_ret*0.01)
*(1+lag3_ret*0.01)
*(1+lag4_ret*0.01)
*(1+lag5_ret*0.01)
*(1+lag6_ret*0.01)
*(1+lag7_ret*0.01)
*(1+lag8_ret*0.01)
*(1+lag9_ret*0.01)
*(1+lag10_ret*0.01)
*(1+lag11_ret*0.01)
*(1+lag12_ret*0.01))-1;
keep id date mom;
run;

data local.mom;
set mom;
if year(date)=2010  then delete;
proc sort;
by id date;
run;

proc sql;
create table variable1 as select a.*, b.ac_b, c.roe, d.log as ns
from local.assetgrowth(where=(year(date)not between 2010 and 2011)) as a,
local.ac_b as b, local.roe(where=(year(date)not between 2010 and 2011) ) as c,
local.stock_issues as d
where a.id=b.id=c.id=d.id and year(a.date)=year(b.date)=year(c.date)=year(d.date);
quit;

data variable1;
set variable1;
if ns=0 then zerons=1;
else zerons=0;
run;

data variable1;
set variable1;
date=intnx('month', date, 6, 'e');
format date yymmdd10.;
proc sort;
by id date;
run;

proc sql;
create table variable2 as select a.*, b.assetgrowth, b.ac_b, b.roe, b.ns, b.zerons
from variable(where=(year(date)~= 2012)) as a left join variable1(where=(year(date)~= 2021)) as b
on a.id=b.id and year(a.date)=year(b.date)
order by id, date;
quit;

proc sql;
create table variable3 as select a.*, b.mom
from local.return(where=(date>19537)) as a left join mom(where=(date>19537)) as b
on a.id=b.id and a.date=b.date
order by id, date;
quit;

proc sql;
create table data as select a.*, b.*
from variable3 as a left join variable2 as b
on a.id=b.id and 1<=intck('month',b.date,a.date)<=12
order by id, date;
quit;

data data;
set data;
if ac_b < 0 then n_ac_b=1;
else n_ac_b=0;
run;



data data;
set data;
if mom=. then delete;
if mc=. then delete;
if bm=. then delete;
if assetgrowth=. then delete;
if ac_b=. then delete;
if roe=. then delete;
run;

data local.data;
set data;
run;

data data;
set data;
if roe<0 then negy=1;
else negy=0;
run;

proc sort data=data;
by date ;
run;



proc sort data=data;
by date;
run;

proc rank data=data out=abc groups=10;
var mc;
by date;
ranks rank_mc;
run;

data abc;
set abc;
if rank_mc<=1 then r=1;
if 2<=rank_mc<=4 then r=2;
if rank_mc>=5 then r=3;
run;

data micro;
set abc(where=(r=1));
run;

data small;
set abc(where=(r=2));
run;

data big;
set abc(where=(r=3));
run;

data all_micro;
set abc(where=(r~=1));
run;


/*percent of market cap*/

proc sort data=data;
by date;
run;

proc means data=data noprint;
var mc;
by date;
output out=market_mc mean=mean;
run;

proc means data=market_mc noprint;
var mean;
output out=market_mc;
run;
/*------------------*/

proc sort data=data;
by date;
run;
proc means data=data noprint;
var return;
by date;
output out=market_vw_return mean=mean std=std;
run;
proc means data=market_vw_return noprint;
var mean std;
output out=market_vw_return;
run;


/*firm number*/
proc sort data=data;
by date;
run;

proc means data=data noprint;
var return;
by date;
output out=market_n n=n;
run;

proc means data=market_n noprint;
var n;
output out=market_n;
run;

proc sort data=micro;
by date;
run;

proc means data=micro noprint;
var return;
by date;
output out=micro_n n=n;
run;

proc means data=micro_n noprint;
var n;
output out=micro_n;
run;

proc sort data=small;
by date;
run;

proc means data=small noprint;
var return;
by date;
output out=small_n n=n;
run;

proc means data=small_n noprint;
var n;
output out=small_n;
run;

proc sort data=big;
by date;
run;

proc means data=big noprint;
var return;
by date;
output out=big_n n=n;
run;

proc means data=big_n noprint;
var n;
output out=big_n;
run;
/*-------------------------*/

/*table2 vw*/

proc rank data=data out=momrank groups=5;
var mom;
by date ;
ranks mom_rank;
run;

proc sort data=momrank;
by date mom_rank;
run;
proc means data=momrank noprint;
var return;
by date mom_rank;
output out=momrank mean=mean;
run;
proc means data=data noprint;
weight mc;
var return;
by date;
output out=weight_return mean=mean;
run;
proc sql;
create table aaa as select a.date, a.mom_rank,
a.mean-b.mean as alpha
from momrank as a left join weight_return as b
on a.date=b.date;
quit;
proc sort data=aaa;
by mom_rank;
run;
proc means data=aaa noprint;
var alpha;
by mom_rank;
output out=result(drop=_type_ _freq_);
run;
ods output ttests= T_table2;
proc ttest data=result  H0=0 side=2;
var alpha;
by mom_rank;
run;
ods output  close;
/*table2* vwnegns*/
proc rank data=data out=negns groups=2;
var zerons;
by date ;
ranks negns_rank;
run;

proc sort data=negns;
by date negns_rank;
run;
proc means data=negns noprint;
var return;
by date negns_rank;
output out=negnsrank mean=mean;
run;
proc means data=data noprint;
weight mc;
var return;
by date;
output out=weight_return mean=mean;
run;
proc sql;
create table aaa as select a.date, a.negns_rank,
a.mean-b.mean as alpha
from negnsrank as a left join weight_return as b
on a.date=b.date;
quit;
proc sort data=aaa;
by negns_rank;
run;
proc means data=aaa noprint;
var alpha;
by negns_rank;
output out=result(drop=_type_ _freq_);
run;
ods output ttests= T_table2;
proc ttest data=result  H0=0 side=2;
var alpha;
by negns_rank;
run;
ods output  close;

/*table2* ew*/
proc rank data=data out=momrank groups=5;
var mom;
by date ;
ranks mom_rank;
run;

proc sort data=momrank;
by date mom_rank;
run;
proc means data=momrank noprint;
var return;
by date mom_rank;
output out=momrank mean=mean;
run;
proc means data=data noprint;
var return;
by date;
output out=weight_return mean=mean;
run;
proc sql;
create table aaa as select a.date, a.mom_rank,
a.mean-b.mean as alpha
from momrank as a left join weight_return as b
on a.date=b.date;
quit;
proc sort data=aaa;
by mom_rank;
run;
proc means data=aaa noprint;
var alpha;
by mom_rank;
output out=result(drop=_type_ _freq_);
run;
ods output ttests= T_table2;
proc ttest data=result  H0=0 side=2;
var alpha;
by mom_rank;
run;
ods output  close;

/*table3*/
proc rank data=data out=momrank groups=5;
var mom;
by date ;
ranks mom_rank;
run;

proc sort data=momrank;
by date mom_rank;
run;
proc means data=momrank noprint;
var mom;
by date mom_rank;
output out=ewv mean=mean std=std;
run;

proc sort data=ewv;
by mom_rank;
proc means data=ewv noprint;
var mean std;
by mom_rank;
output out=ewv;
run;

/*table3 neg */
proc rank data=data out=momrank groups=2;
var mom;
by date ;
ranks mom_rank;
run;
proc sort data=momrank;
by date mom_rank;
run;
proc means data=momrank noprint;
var mom;
by date mom_rank;
output out=ewv mean=mean std=std;
run;

proc sort data=ewv;
by mom_rank;
proc means data=ewv noprint;
var mean std;
by mom_rank;
output out=ewv;
run;

/*table4 */
proc reg data=micro outest=regmicro rsquare noprint;
model return=mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
by date;
run;
quit;

proc reg data=small outest=regsmall rsquare noprint;
model return=mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
by date;
run;
quit;

proc reg data=big outest=regbig rsquare noprint;
model return=mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
by date;
run;
quit;

proc reg data=all_micro outest=regall_micro rsquare noprint;
model return=mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
by date;
run;
quit;

proc reg data=data outest=regmarket rsquare noprint;
model return=mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
by date;
run;
quit;  /*market*/

proc means data=regmicro noprint;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
output out= ttest_regmicro(drop=_type_ _freq_)  ;
run;

ods output ttests= T_micro;
proc ttest data=ttest_regmicro  H0=0 side=2;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
run;
ods output  close;

proc means data=regsmall noprint;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
output out= ttest_regsmall(drop=_type_ _freq_)  ;
run;

ods output ttests= T_small;
proc ttest data=ttest_regsmall  H0=0 side=2;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
run;
ods output  close;

proc means data=regbig noprint;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
output out= ttest_regbig(drop=_type_ _freq_)  ;
run;

ods output ttests= T_big;
proc ttest data=ttest_regbig  H0=0 side=2;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
run;
ods output  close;

proc means data=regmarket noprint;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
output out= ttest_regmarket(drop=_type_ _freq_)  ;
run;

ods output ttests= T_market;
proc ttest data=ttest_regmarket  H0=0 side=2;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
run;
ods output  close;

proc means data=regall_micro noprint;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
output out= ttest_regall_micro(drop=_type_ _freq_)  ;
run;

ods output ttests= T_all_marco;
proc ttest data=ttest_regall_micro  H0=0 side=2;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
run;
ods output  close;

proc sql;
create table regmicro_small as select a.date, a.mc-b.mc as mc, a.bm-b.bm as bm, 
a.mom-b.mom as mom, a.zerons-b.zerons as zerons, a.ns-b.ns as ns, a.n_ac_b-b.n_ac_b as n_ac_b,
a.ac_b-b.ac_b as ac_b, a.assetgrowth-b.assetgrowth as assetgrowth, a.negy-b.negy as negy, 
a.roe-b.roe as roe
from regmicro as a left join regsmall as b
on a.date=b.date;
quit;

proc means data=regmicro_small noprint;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
output out= ttest_regmicro_small(drop=_type_ _freq_)  ;
run;

ods output ttests= T_regsmall_micro;
proc ttest data=ttest_regmicro_small  H0=0 side=2;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
run;
ods output  close;

proc sql;
create table regmicro_big as select a.date, a.mc-b.mc as mc, a.bm-b.bm as bm, 
a.mom-b.mom as mom, a.zerons-b.zerons as zerons, a.ns-b.ns as ns, a.n_ac_b-b.n_ac_b as n_ac_b,
a.ac_b-b.ac_b as ac_b, a.assetgrowth-b.assetgrowth as assetgrowth, a.negy-b.negy as negy, 
a.roe-b.roe as roe
from regmicro as a left join regbig as b
on a.date=b.date;
quit;

proc means data=regmicro_big noprint;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
output out= ttest_regmicro_big(drop=_type_ _freq_)  ;
run;

ods output ttests= T_regmicro_big;
proc ttest data=ttest_regmicro_big  H0=0 side=2;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
run;
ods output  close;

proc sql;
create table regmicro_all_micro as select a.date, a.mc-b.mc as mc, a.bm-b.bm as bm, 
a.mom-b.mom as mom, a.zerons-b.zerons as zerons, a.ns-b.ns as ns, a.n_ac_b-b.n_ac_b as n_ac_b,
a.ac_b-b.ac_b as ac_b, a.assetgrowth-b.assetgrowth as assetgrowth, a.negy-b.negy as negy, 
a.roe-b.roe as roe
from regmicro as a left join regall_micro as b
on a.date=b.date;
quit;

proc means data=regmicro_all_micro noprint;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
output out= ttest_regmicro_all_micro(drop=_type_ _freq_)  ;
run;

ods output ttests= T_regmicro_all_micro;
proc ttest data=ttest_regmicro_all_micro  H0=0 side=2;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
run;
ods output  close;

proc sql;
create table regsmall_big as select a.date, a.mc-b.mc as mc, a.bm-b.bm as bm, 
a.mom-b.mom as mom, a.zerons-b.zerons as zerons, a.ns-b.ns as ns, a.n_ac_b-b.n_ac_b as n_ac_b,
a.ac_b-b.ac_b as ac_b, a.assetgrowth-b.assetgrowth as assetgrowth, a.negy-b.negy as negy, 
a.roe-b.roe as roe
from regsmall as a left join regbig as b
on a.date=b.date;
quit;

proc means data=regsmall_big noprint;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
output out= ttest_regsmall_big(drop=_type_ _freq_)  ;
run;

ods output ttests= T_regsmall_big;
proc ttest data=ttest_regsmall_big  H0=0 side=2;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
run;
ods output  close;

/*table5 */
proc sort data=data;
by date;
run;
proc rank data=data out=momrank groups=5;
var mom;
by date ;
ranks mom_rank;
run;

proc sort data=momrank;
by date mom_rank;
run;
proc means data=momrank noprint;
var return;
by date mom_rank;
output out=momrank mean=mean;
run;
proc sort data=momrank;
by mom_rank;
run;
proc means data=momrank noprint;
var mean;
by mom_rank;
output out=weight_return mean=mean;
run;

/*----------------------------------------------------------------------------------*/

proc rank data=data out=momrank groups=5;
var mom;
by date ;
ranks mom_rank;
run;

proc sort data=momrank;
by date mom_rank;
run;
proc means data=momrank noprint;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
by date mom_rank;
output out=momrank_a;
run;
proc sort data=momrank_a;
by mom_rank;
run;
proc means data=momrank_a noprint;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
by mom_rank;
output out=weight_return;
run;

data Out;
do Slice=4, 9,14,19,24;
set Weight_return point=Slice;
output;
end;
stop;
run;

proc reg data=data outest=regmarket rsquare  noprint;
model return=mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
by date;
run;
quit; 
proc means data=regmarket noprint;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
output out= ttest_regmarket(drop=_type_ _freq_)  ;
run;

ods output ttests= T_market;
proc ttest data=ttest_regmarket  H0=0 side=2;
var mc bm mom zerons ns n_ac_b ac_b assetgrowth negy roe;
run;
ods output  close;

proc sort data=data;
by date;
run;


proc sort data=local.return;
by id;
run;


data local.asd;
set data;
run;
