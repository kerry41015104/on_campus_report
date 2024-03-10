DM 'log' clear; DM 'output' clear;
dm 'odsresults; clear';
data zz(where=(roe>0));
set small;
run;
data zzz(where=(roe<0));
set small;
run;
proc rank data=zz out=momrank groups=5;
var roe;
by date ;
ranks mom_rank;
run;

proc rank data=zzz out=momrank_2 groups=2;
var roe;
by date ;
ranks mom_rank_2;
run;

proc sort data=momrank;
by date mom_rank;
run;

proc sort data=momrank_2;
by date mom_rank_2;
run;
proc means data=momrank noprint;
var return;
by date mom_rank;
output out=momrank mean=mean;
run;

proc means data=momrank_2 noprint;
var return;
by date mom_rank_2;
output out=momrank_2 mean=mean;
run;
proc means data=small noprint;
*weight mc;
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
proc sql;
create table bbb as select a.date, a.mom_rank_2,
a.mean-b.mean as alpha
from momrank_2 as a left join weight_return as b
on a.date=b.date;
quit;
proc sort data=aaa;
by mom_rank;
run;
proc means data=aaa noprint;
var alpha;
by mom_rank;
output out=result(drop=_type_ _freq_) mean=mean;
run;
proc means data=aaa noprint;
var alpha;
by mom_rank;
output out=result2(drop=_type_ _freq_);
run;
ods output ttests= T_table2;
proc ttest data=result2  H0=0 side=2;
var alpha;
by mom_rank;
run;
ods output  close;

proc sort data=bbb;
by mom_rank_2;
run;
proc means data=bbb noprint;
var alpha;
by mom_rank_2;
output out=result3(drop=_type_ _freq_) mean=mean;
run;
proc means data=bbb noprint;
var alpha;
by mom_rank_2;
output out=result4(drop=_type_ _freq_);
run;
ods output ttests= T_table2_1;
proc ttest data=result4  H0=0 side=2;
var alpha;
by mom_rank_2;
run;
ods output  close;
/*------------------------------------------------------------------------------------------------*/

data zzzz(where=(ns=0));
set small;
run;
proc sort data=zzzz;
by date;
run;
proc means data=zzzz noprint;
var return;
by date;
output out=momrank_3 mean=mean;
run;
proc sql;
create table ccc as select a.date, 
a.mean-b.mean as alpha
from momrank_3 as a left join weight_return as b
on a.date=b.date;
quit;

proc means data=ccc noprint;
var alpha;
output out=result5(drop=_type_ _freq_) mean=mean;
run;
proc means data=ccc noprint;
var alpha;
output out=result6(drop=_type_ _freq_);
run;
ods output ttests= T_table2_2;
proc ttest data=result6  H0=0 side=2;
var alpha;
run;
ods output  close;
/*------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------*/
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
by  mom_rank;
run;
proc means data=momrank noprint;
var mean;
by mom_rank;
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
output out=result(drop=_type_ _freq_) mean=mean;
run;
proc means data=aaa noprint;
var alpha;
by mom_rank;
output out=result_2(drop=_type_ _freq_);
run;
ods output ttests= T_table2;
proc ttest data=result_2  H0=0 side=2;
var alpha;
by mom_rank;
run;
ods output  close;
