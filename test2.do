sysuse auto.dta
log using test2
codebook
set more off
inspect //both inspect and codebook are good for eyeballing the data: frequency, missing values, unque values etc.
list make price mpg in 1/10
tab rep78 foreign, column //include percentages
summ mpg, detail //includes quantiles
sort foreign
by foreign: summ mpg
tabulate foreign, summarize(price)
tab rep78, summarize(price)
keep make rep78 foreign mpg price
tab rep78 foreign if rep78>=4
tab rep78 foreign if rep78>=4, column nofreq
summarize if rep78 >=2
summ if rep78 !=2
summarize if rep78 >3 & !missing(rep78) //summ if rep78 >3 & !=.
sysuse auto, clear
correlate price mpg weight rep78
pwcorr price mpg weight rep78, obs //pairwise correlation: deleting observations on a pairwise basis
drop if (rep<=2) | (rep==.)
regress mpg price weight 
tab rep78, gen(rep) //gen dummies
regress mpg price weight rep1 rep2 
label define foreignl 0 "domestic car" 1 "foreign car"
label values foreign foreignl
drop mpg3
generate mpg3=.
replace mpg3 = 1 if mpg<=18
replace mpg3 = 2 if (mpg>=19) & (mpg<=23)
replace mpg3 = 3 if (mpg>=24) & (mpg<.)
gen mpg3a = mpg
recode mpg3a (min/18=1) (19/23=2) (24/max=3)
gen mpgfd = mpg
recode mpgfd (min/18=0) (19/max=1) if foreign==0
recode mpgfd (min/24=0) (25/max=1) if foreign==1
sysuse auto,clear
drop displ gear_ratio
save auto2
tabulate rep78, missing //tab with missing freq
drop if missing(rep78)
sysuse auto, clear
keep if (rep78<=3)
use http://www.ats.ucla.edu/stat/stata/modules/kids, clear 
collapse age
use http://www.ats.ucla.edu/stat/stata/modules/kids, clear
collapse age, by(famid)
use http://www.ats.ucla.edu/stat/stata/modules/kids, clear 
collapse (mean) avgage=age, by(famid) 
use http://www.ats.ucla.edu/stat/stata/modules/kids, clear 
collapse (mean) avgage=age avgwt=wt, by(famid) 
use http://www.ats.ucla.edu/stat/stata/modules/kids, clear  
collapse (mean) avgage=age avgwt=wt (count) numkids=birth, by(famid) 
use http://www.ats.ucla.edu/stat/stata/modules/kids, clear
tab sex, gen(sexdum)
list famid sexdum1 sexdum2
collapse (count) numkids=birth (sum) girls=sexdum1 boys=sexdum2, by(famid)
list famid boys girls numkids
clear
input famid inc1-inc12 
1 3281 3413 3114 2500 2700 3500 3114 3319 3514 1282 2434 2818
2 4042 3084 3108 3150 3800 3100 1531 2914 3819 4124 4274 4471
3 6015 6123 6113 6100 6100 6200 6186 6132 3123 4231 6039 6215
end
foreach var of varlist inc1-inc12{
gen tax`var'=`var'*.10
} 
foreach qtr of numlist 1/4 {
  local m3 = `qtr'*3
  local m2 = (`qtr'*3)-1
  local m1 = (`qtr'*3)-2
  generate incqtr`qtr' = inc`m1' + inc`m2' + inc`m3'
}
