PROC IMPORT OUT= local.price1 /* Using  rawdata_1*/ 
            DATAFILE= "C:\Users\user\Desktop\sas\data_2\price1.xlsx"
            DBMS=EXCELCS REPLACE;
     RANGE="price1$"; 
RUN;

PROC IMPORT OUT= local.return1 /* Using  rawdata_bv*/ 
            DATAFILE= "C:\Users\user\Desktop\sas\data_2\return1.xlsx"
            DBMS=EXCELCS REPLACE;
     RANGE="return1$"; 
RUN;

data rawdata_1;
set rawdata_1;
date = intnx('month',date,0,'e');
format date yymmdd10.;
run;

proc sql; 
create table rawdata_2 as select a.date, a.id, a.ownership, a.mv/1000 as mv, a.return, b.bv
from rawdata_1 as a left join rawdata_bv as b
on a.id = b.id and intck('month', b.date, a.date) = 1
order by a.id, a.date;
quit;

proc sql; 
create table rawdata_f as select a.date, a.id, a.ownership as own,
b.ownership as ownership_post 'ownership_post',
b.ownership - a.ownership as ownch, 
a.mv, a.bv,
a.return as return
from rawdata_2 as a left join rawdata_2 as b
on a.id = b.id and intck('month', b.date, a.date) = -12
where a.mv > 0
order by a.date, a.id ; /* a.id, a.date */
quit;

/**************************************************************/
/*                                        Table1-PanelA                                              */
/**************************************************************/
proc sql; 
create table data_10mon as select *
from rawdata_f
where month(date) = 10
order by date, id;
quit;

/*-------------------------- PaneA-exercise1-------------------------- */
proc rank data = data_10mon out = data_10mon groups=6;
var own;
by date;
ranks own_rank;
run;

proc rank data =  data_10mon out = data_10mon;

run;
/* ----------------------------------------------------------------------- */
proc rank data = data_10mon out = data_10mon;
var mv;
by date;
ranks mv_rank;
run;

/*-------------------------- PaneA-exercise2-------------------------- */
proc sort data = data_10mon;

run;
/* ----------------------------------------------------------------------- */
proc sql; 
create table data_10mon as select *,
mean(ownch) as mean_ownch 'mean_ownch(y)',
ownch- calculated mean_ownch as delta_own
from data_10mon
group by date;
quit;

proc sql;
create table Tab_1_A_t as select date, ownch_rank as portfolio 'portfolio',
mean(own) as own_mean,
mean(delta_own) as delta_own_mean,
mean(log(mv)) as lnmv_mean 'ln(mv)_mean',
mean( log(bv/mv) ) as lnbm_mean 'ln(b/m)_mean'
from data_10mon
where missing(portfolio) = 0
group by date, ownch_rank
order by portfolio, date;
quit;

proc sql;
create table Table_1_A as select portfolio,
mean(own_mean) as own_mean,
mean(delta_own_mean) as delta_own_mean,
mean(lnmv_mean) as lnmv_mean 'ln(mv)_mean',
mean(lnbm_mean) as lnbm_mean 'ln(b/m)_mean'
from tab_1_A_t
group by portfolio;
quit;

/************************/
/*                F-test               */
/************************/

/* According to Tab_1_A_t */
proc anova


run;
quit;

/**************************************************************/
/*                                        Table1-PanelB                                              */
/**************************************************************/

proc sql;
create table portfo as select a.date, a.id, a.return,
b.mv_rank 'mv_rank', 
b.ownch_rank as portfolio 'portfolio' , 
b.date as bdate 'bdate', 

mean(a.return) as mean_return 'Cross-sessional Avg-return', 
a.return - calculated mean_return as ar_mon 'Month Abnormal return' 

from rawdata_f as a left join data_10mon as b
on a.id = b.id and -11 <= intck('month', a.date, b.date) <= 0 

group by a.date, b.mv_rank 

order by a.date,a.id; /* a.id, a.date */
quit;

proc sql;
create table portfo_yar as select date, id, portfolio, ar_mon, bdate
from portfo
/* min(ar_mon) as min_ar*/
order by id, date;
quit;

/*-------------------------- PanelB-exercise-------------------------- */
proc sql;
create table portfo_yar2 as select *,
quit;


proc sql;
create table portfo_yar3 as select bdate'Bdate' , id, portfolio,
/* wait to add one code */
from portfo_yar
where missing(portfolio) = 0
group by id, bdate
order by bdate, portfolio, id; 
quit;
/*-------------------------------------------------------------------------- */

proc means data = portfo_yar3 noprint;
var ar_year;
by bdate portfolio;
where missing(portfolio) =0;
output out = portfo_avg_yar(drop = _type_ _freq_) mean = cross_sesstional_avg;
run;

/************************/
/*                 F-test              */
/************************/
proc sort data = portfo_avg_yar;
by portfolio bdate ;
run;

proc anova data=portfo_avg_yar ; 
class portfolio;
model cross_sesstional_avg= portfolio; 
run;
quit;

/************************/
/*                T-test              */
/************************/

proc ttest data = portfo_avg_yar H0 = 0 side = 2 ;
var cross_sesstional_avg;
by portfolio;
run;

proc sql;
create table Table_1_b as select portfolio, 
mean(cross_sesstional_avg) as Herding_Year_AR 'Herding Year Abnormal Return'
from portfo_avg_yar
group by portfolio
order by portfolio;
quit;

/**************************************************************/
/*                                        Table1-PanelC                                              */
/**************************************************************/

proc sql;
create table portfo_c as select a.date, a.id,
b.ar_mon as Post_ar_mon'Post 1y Month Abnormal Return'
from portfo as a left join portfo as b
on a.id = b.id and intck('month', a.date, b.date) = 12
order by a.date, a.id;
quit;

proc sql;
create table portfo_yar_c as select a.date, a.id,
b.ownch_rank as portfolio 'portfolio',
post_ar_mon,
b.date as bdate 'bdate'
from portfo_c as a left join data_10mon as b
on a.id = b.id and -11 <= intck('month', a.date, b.date) <= 0
order by a.id, a.date;
quit;

proc sql;
create table portfo_yar2_c as select distinct bdate'Bdate' , id, portfolio, 
exp( sum( log(1 + post_ar_mon*0.01 ) ) ) - 1 as post_ar_year 'Post Abnormal Return(y)'
from portfo_yar_c
where missing(portfolio) = 0
group by id, bdate
order by bdate, portfolio, id;
quit;

proc means data = portfo_yar2_c noprint;
var post_ar_year;
by bdate portfolio;
output out = portfo_avg_yar_c(drop = _type_ _freq_) mean = cross_sesstional_avg;
run;

/************************/
/*                F-test               */
/************************/
proc sort data = portfo_avg_yar_c;
by portfolio bdate ;
run;
proc anova data=portfo_avg_yar_c ;
class portfolio;
model cross_sesstional_avg= portfolio;
run;
quit;

/************************/
/*                T-test               */
/************************/
proc ttest data = portfo_avg_yar_c H0 = 0 side = 2 ;
var cross_sesstional_avg;
by portfolio;
run;

proc sql;
create table Table_1_C as select portfolio, 
mean(cross_sesstional_avg) as Post_Herding_Year_AR 'Post Herding Year Abnormal Return'
from portfo_avg_yar_c
group by portfolio
order by portfolio;
quit;





