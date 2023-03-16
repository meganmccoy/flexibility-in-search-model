cd "/Users/megan.mccoy/Desktop/UNC/Flexibility in Field Paper/flexibility-in-field-paper/"

***********************************************************************
*		CPS Data for Unemployment Duration
***********************************************************************
use cps_00023.dta, clear
keep if mish==8

rename month month_cps8
rename year year_cps8
rename sex sex_cps8
rename age age_cps8
rename empstat empstat_cps8

format cpsidp %18.0f

save cps_workfile, replace

***********************************************************************
*		CPI Data
***********************************************************************

import delimited using CPIAUCSL_FRED_17-18_annual_avg.csv, clear  

gen year = 2017 if date=="2017-01-01"
recode year .=2018
destring year, replace
drop date

gen cpibase2018 = cpiaucsl/251.0989

save cpi, replace


***********************************************************************
*		ATUS Leave Module Data
***********************************************************************

* Merge CPS and ATUS 
use atus_00013.dta, clear // 19,816 total responses 
format cpsidp %18.0f

merge 1:1 cpsidp year_cps8 month_cps8 using cps_workfile
keep if _m==3 // perfect merge! 
drop _m

* Merge ATUS and CPI
merge m:1 year using cpi

* Necessary variables 
gen atus_date = mdy(month, 1, year)
format atus_date %td
label var atus_date "Month, Year of ATUS interview"
gen cps8_date = mdy(month_cps8, 1, year_cps8)
label var cps8_date "Month, Year of ATUS interview"
format cps8_date %td

* Homogeneity measures
	* age 25-55, men, white, college degree or more, unemployed OR employed FT Leave Module respondent
	* create new edu (1 if HS diploma, 2 if college or more)

keep if age>24 & age<56 // removes 10,119

// tab sex
// tab sex, nol
// keep if sex==1 // removes 5,213

tab race
tab race, nol
keep if race==100 // removes 879

tab educ
tab educ, nol
// keep if educ >= 40 // removes 1,998

gen hs_edu=(educ==20 | educ==21 | educ==30) // highest edu: HS graduate - GED or diploma or some college (no degree)
tab educ hs_edu, mis
label var hs_edu "High School Diploma or equivalent"

gen col_edu=(educ>=40)
tab educ col_edu, mis
label var col_edu "Bachelors degree or more"

tab empstat
tab empstat, nol
keep if empstat==1 | empstat==4 // removes 91
gen employed=(empstat==1)

tab fullpart 
tab fullpart, nol
drop if employed==1 & fullpart==2 // removes 62

tab lv_resp
tab lv_resp, nol
drop if employed==1 & lv_resp!=1 // removed 184

drop if employed==1 & earnweek==0 // removed 1

	* After homogeneity measures, sample of 1270 (1243 employed and 27 unemployed)
	
* Flexibility Measures

tab wrkflexhrs //has a flexible schedule where able to change work start or end time
tab wrkflexhrs, nol

tab wrkflexpol //formal or informal policy on flexible schedule
tab wrkflexpol, nol

tab wrkflexfreq //frequency of ability to change work start or end time
tab wrkflexfreq, nol

gen flexsched = (wrkflexhrs==1)
label var flexsched "1 if able to change work schedule"
recode flexsched 0=. if employed==0

// flexibility score = 1(flexible schedule) + 1(formal policy) 
// 		0 if not flexible, 1 if informal policy, 2 if formal policy 
gen flex_sched_score = (wrkflexhrs==1)+(wrkflexpol==1)
label var flex_sched_score "Score of Flexible Schedule: 0 if not, 1 if informal, 2 if formal policy"
recode flex_sched_score 0=. if employed==0

tab flex_sched_score wrkflexfreq //no relationship between formality and use, supporting argument to separate access and utilization

gen flexloc = (wrkhomeable==1) //&(wrkhomepd==1 | wrkhomepd==3) // ISSUE! Paid question requires a yes to "do you ever work from home?"
label var flexloc "1 if able to WFH" // and paid for
recode flexloc 0=. if employed==0

// flexibility score = 1(flexible location) + 1(paid for some or all) 
// 		0 if not flexible, 1 if unpaid, 2 if paid
gen flex_loc_score = (wrkhomeable==1)+(wrkhomepd==1 | wrkhomepd==3)
label var flex_loc_score "Score of Flexible Location: 0 if not, 1 if able but unpaid, 2 if able and paid"
recode flex_loc_score 0=. if employed==0


* Wages
sum earnweek if employed==1 //some topcoding but no missing
sum hourwage if employed==1 //missing

gen hrwage = earnweek/40 if employed==1
label var hrwage "Estimated hourly wage (earnweek/40)"

gen hrwage_r = hrwage/cpibase2018
label var hrwage_r "Estimated hourly wage (earnweek/40), 2018 dollars"

* Unemployment duration 
recode durunemp 999=.
sum durunemp if employed==0 // only 6 individuals unemployed in CPS8 and ATUS interviews
gen dur = durunemp + (datediff_frac(cps8_date, atus_date, "month")*4) if employed==0 // add CPS8 duration of unemployment to time between CPS8 and ATUS interviews 
label var dur "Duration of unemployment in weeks"

tab empstat_cps8 if durunemp==. & employed==0 //12 lost jobs, 9 re-entered labor force

gen durunemp_imp = datediff_frac(cps8_date, atus_date, "month")*4 if employed==0 & durunemp==.
label var durunemp_imp "Imputed unemployed duration"

replace dur=durunemp_imp if dur==.

save workfile.dta, replace
