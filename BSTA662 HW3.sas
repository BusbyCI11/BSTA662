PROC IMPORT OUT= WORK.whas500 
            DATAFILE= "C:\Users\cianb\Downloads\whas500.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
RUN;

ods graphics on;

proc print data=whas500 (obs=5);
run;

proc lifetest data=whas500 method=km plots=(survival(cl),ls,lls)
 	graphics outsurv=a;
	time lenfol*fstat(0);
	test age gender hr sysbp diasbp bmi cvd afb sho chf av3 miord mitype los;
run;

proc print data=a (obs=5);
run;

proc phreg data=whas500;
class gender;
	model lenfol*fstat(0)= age gender hr sysbp diasbp bmi cvd afb sho chf av3 miord mitype los/ties=exact selection=backwards;
run;

proc phreg data=whas500;
class gender;
	model lenfol*fstat(0)= age gender hr sysbp diasbp bmi cvd afb sho chf av3 miord mitype los/ties=exact selection=stepwise;
run;

proc phreg data=whas500;
class gender;
	model lenfol*fstat(0)= age gender hr diasbp bmi sho chf/ties=exact;
run;

/* Explain selection of factors/covariates and graph */

proc lifetest data=whas500 method=km nelson plots=(survival(cl),ls,lls)
 	graphics;
	time lenfol*fstat(0);
	strata chf;
run;

proc lifetest data=whas500 method=km nelson plots=(survival(cl),ls,lls)
 	graphics;
	time lenfol*fstat(0);
	strata gender;
run;

data distY;
	set a;
	s=survival;
	logH=log(-log(s));
	lnorm=probit(1-s);
	logit=log((1-s)/s);
	llenfol=log(lenfol);
run;

proc gplot data=distY;
	plot logit*llenfol logH*lenfol lnorm*llenfol;
	run;
quit;

proc lifetest data=whas500 method=km plots=(survival(cl),ls,lls)
 	graphics outsurv=c;
	time lenfol*fstat(0);
	strata gender;
run;

proc lifetest data=whas500 method=km plots=(survival(cl),ls,lls)
 	graphics outsurv=c;
	time lenfol*fstat(0);
	strata gender;
	test age gender hr sysbp diasbp bmi cvd afb sho chf av3 miord mitype los;
run;

data distZ;
	set c;
	s=survival;
	logH=log(-log(s));
	lnorm=probit(1-s);
	logit=log((1-s)/s);
	llenfol=log(lenfol);
run;

proc gplot data=distZ;
	title "Graphical Checking of Distributions";
	symbol1 i=join width=2 value=triangle c=steelblue;
	symbol2 i=join width=2 value=circle c=red;
	plot logit*llenfol=gender logH*llenfol=gender lnorm*llenfol=gender;
	run;
quit;

ods graphics off;
