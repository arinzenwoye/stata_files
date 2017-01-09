clear
import delimited using full_majors.csv, varnames(1)
drop v1
*Recoding
encode post_grad_status, gen(status)
gen status1 = 1 if (status == 1)
replace status1 = 0 if missing(status1) //status1 - dep variable
encode experiential1, gen(experiential) // experiential
encode poptype, gen(major) //major
encode gender, gen(sex) 
replace sex = . if (sex == 3) //sex
replace ethnicity = "other" if (ethnicity == "American Indian or Alaskan Native" | /// 
ethnicity == "Native Hawaiian or Other Pacific Islander, Non Asian" | ethnicity == "Unknown")
encode ethnicity, gen(race)
replace race = . if (race == 5) // race
gen gpa = real(studentprofilegpa) // gpa

*Regression for employment
quietly logit status1 i.experiential i.major i.sex ib6.race gpa, vce(robust) // no interaction
margins, dydx(*) atmeans
margins, dydx(*)
quietly logit status1 experiential##major i.sex ib6.race gpa, vce(robust)
*margins i.major##i.experiential - check this margins command before running the below
margins, over (experiential major)
margins, over (experiential major) expression(exp(xb())) post
lincom 2.experiential#1.major - 1.experiential#1.major //experiential learning within humanities & social sciences
lincom 2.experiential#2.major - 1.experiential#2.major // experiential learning within math & sciences
logit status1 major##experiential i.sex ib6.race gpa, or //odds ratio

*Regression for Salary
use rick_dat, clear
set more off
keep if status1 == 1
gen salary = real(salary_base)
gen lnsalary = ln(salary)
replace race = 8 if missing(race)
replace sex = 2 if missing(sex)
drop if (major == 2 & salary <= 6000)
drop if major == 1 & salary < 20000
drop if major == 1 & salary >= 110000
*regress lnsalary i.race i.sex gpa major##experiential, vce(robust)
*regress lnsalary i.race i.sex gpa i.major i.experiential, vce(robust)
*handling missing data
misstable summarize //summarizes all the encoded data and provides the number missing values by variable
mi set mlong
mi misstable patterns 
mi misstable nested
mi register imputed lnsalary gpa 
mi register regular sex race major experiential
mi impute mvn lnsalary gpa = race sex major experiential, add(20) rseed(123) replace
mi estimate: regress lnsalary i.race i.sex gpa i.major i.experiential, vce(robust)
mi estimate: regress lnsalary i.race i.sex gpa i.major##i.experiential, vce(robust)
margins, dydx(*) atmeans




