use testwrk.dta, clear
*log using dataman.txt, text replace
rename whichofthefollowingbestdescribes underutilization // rename variable 
label variable internship "did you have an internship or not" //relabel variable
list gpa ethnicity in 1/2, clean 
tabulate gpa
destring internship, replace force //change internship to numeric with missing data
destring gpa, replace force
foreach var of varlist varsitysports communityservice residentiallearning ///
reserchproject clinicalrotation studentorganization studentteaching ///
studyabroad workabroad noparticipation casecompetition employedparttime ///
graduateasst{
	destring `var', replace force 
}
encode ethnicity, gen(eth)
encode underutilization, gen(underuti)
encode gender, gen(sex)
encode(status), gen(emp)
gen work = (emp==1) | (emp==2) //after encoding to numeric the 1 & 2 are the first and second instance
gen maj = 0 
replace maj = 1 if majorcode1 >=200 & majorcode <400
replace maj = 2 if majorcode1 >=400 & majorcode <600
replace maj = 3 if majorcode1 >=600 & majorcode <800
replace maj = 4 if majorcode1 >=800
replace internship = 0 if missing(internship)
encode searchduration_interview, gen(dur_intvw)
encode searchduration_app, gen(dur_app)
replace eth = missing(eth) if (eth==5) | (eth==7) 
replace eth = missing(eth) if (eth==0)
local xlist "methods_2 methods_3 methods_4 methods_5 methods_6 methods_7"
Probit work i.maj i.eth jobsearchskills internship, vce(robust)
*probit work `xlist' i.eth gpa jobsearchskills internship i.dur_intvw ///
*i.dur_app age extracurricular first_gen i.sex i.maj
margins, dydx(*) atmeans
margins, dydx(*)
log close
exit, clear


*gen ifmale = (sex=="male") if !missing(sex)













*probit
*report psudo R-squared to explain the goodness of fit of the regression 
*perform wald test on the variables of interest. can also use the likelihood ratio 
*margins, dydx(*) atmeans gives the marginal effect at the mean for all the variables (*). //
*if you leave off the "at" then you just get the average marginal effect 
*binary models with panel data
*if the ci is not long (ie 10,000 individuals) you can use i.variable like for example state level data. probit y x1 x2 i.state  to take care of the FE
* if you getting into incidental parameter problem it might be better to use the FE logit
*RE probit: xtprobit
*FE Logit: because of the nature of the denominator of the logit you cancel out the c's 
