clear
*insheet using modeldta.csv // original data no subset
*insheet using model_data1.csv // data with interviews
*insheet using new_model1.csv 
insheet using new_model4.csv
encode gender, gen(sex)
mvdecode sex, mv(3)
encode ethnicity, gen(race)
mvdecode race, mv(4)
encode broad_category, gen(major1)
encode no_japps, gen(apps)
mvdecode apps, mv(6)
*encode dep_var, gen(status1)
gen age1 = real(age)
gen cgpa = real(gpa)
gen informal = 0
replace informal = 1 if (jobsearch_method_network == 1)
gen formal = 0 
replace formal = 1 if (jobsearch_method_website == 1 | jobsearch_method_media == 1 | jobsearch_method_print == 1)
encode work, gen(international)
mvdecode international, mv(1)
gen foreign = (international == 2) if !missing(international)

replace postgrad_status =  "Full-time employed" ///
if postgrad_status == "Employed full-time, full-time entrepreneur, full-time post-graduation internship, full-time fellowship, etc. (on average 30 hours or more per week)"

replace postgrad_status =  "Part-time employed" ///
if postgrad_status == "Employed part-time, part-time entrepreneur, part-time post-graduation internship, part-time fellowship, etc. (on average less than 30 hours per week)"

label define status2 3 "Full-time employed" 2 "Part-time employed" 1 "Seeking employment"
encode postgrad_status, gen(status2)
save rick_research, replace

gen b_stat =  status2 if status2 !=2 
replace b_stat = 0 if b_stat == 1
replace b_stat = 1 if b_stat == 3
gen res1_skills =  jobsearch_skills_1 +  jobsearch_skills_2 +  jobsearch_skills_4 +  jobsearch_skills_5


clear
import delimited using ucs_model2.csv, varnames(1)
save ucs_data, replace
clear 
use rick_research
merge m:m name using ucs_data, keepusing(utilization logins)
replace utilization = 0 if _merge == 1
drop if _merge==2
*ordered logit
ologit status2 i.sex age1 ib5.race ib10.major1 cgpa internship jobsearch_skills_1 jobsearch_skills_2 jobsearch_skills_4 ///
jobsearch_skills_5 jobsearch_skills_12-jobsearch_skills_17 int_dummy jobsearch_skills_7-jobsearch_skills_11 , vce(robust)
logit b_stat res1_skills netwrk_skills i.sex age1 ib5.race ib10.major1 cgpa internship i.int_dummy##c.int_skills, vce(robust) //sig

logit b_stat resume_skills netwrk_skills i.sex age1 ib5.race ib10.major1 cgpa internship int_dummy##c.int_skills, vce(robust)

ologit status2 jobsearch_skills_agg  i.sex age1 ib5.race, vce(robust) // sig
ologit status2 jobsearch_skills_agg  i.sex age1 ib5.race ib10.major1, vce(robust) // sig
ologit status2 jobsearch_skills_agg  i.sex age1 ib5.race ib10.major1 cgpa, vce(robust) // sig
ologit status2 jobsearch_skills_agg  i.sex age1 ib5.race ib10.major1 cgpa, vce(robust)












*IV
gen new_status2 = new_stat2
ivregress 2sls new_status2 i.sex ib10.major1 age1 cgpa ib5.race internshipco_op ///
total_internships foreign (jobsearch_skills_agg = utilization), first





***ordered logit (dep var: status2)
quietly ologit new_stat2 i.sex age1 cgpa first_gen ib5.race internshipco_op ///
total_internships foreign jobsearch_skills_agg intensity ib10.major1, vce(robust) //ordinal logit with foreign
*write out ordered logit
outreg using ordered_status.doc, se va summstat(ll\r2_p) ctitles("Variables", "Coefficients") ///
note("Dependent Variable is Postgraduate Status. Standard errors are in parenthesis. * and ** denote statistical significance at the 5% and 1% respectively") ///
title("Effects of Job Search Skills on Postgraduate Status, Ordinal Regression") replace
*write out and marginal effects
quietly margins, dydx(*) atmeans predict(outcome(3))
outreg using ordered_status.doc, se ma va ctitles("variables", "Full-employed") merge
quietly margins, dydx(*) atmeans predict(outcome(2))
outreg using ordered_status.doc, se ma va ctitles("variables", "Underemployed") merge
quietly margins, dydx(*) atmeans predict(outcome(1))
outreg using ordered_status.doc, se ma va ctitles("variables", "Unemployed") merge



***Multinomial Logit (dep var: status1)
quietly mlogit status1 i.sex ib10.major1 age1 cgpa first_gen ib5.race internshipco_op ///
total_internships foreign jobsearch_skills_agg i.apps, base(3) vce(robust) //with foreign
margins, dydx(*) atmeans predict(outcome(1))
margins, dydx(*) atmeans predict(outcome(2))
reg status1 i.sex ib10.major1 age1 cgpa first_gen ib5.race internshipco_op ///
total_internships foreign jobsearch_skills_agg jobsearch_method_ucs, vce(robust) //linear model
ivregress status1 i.sex ib10.major1 age1 cgpa first_gen ib5.race internshipco_op ///
total_internships foreign jobsearch_skills_agg (jobsearch_method_ucs = , vce(robust) 



gen num_status2 = status2
ivregress 2sls num_status2 i.sex ib10.major1 age1 cgpa ib5.race internshipco_op ///
total_internships foreign intensity (jobsearch_skills_agg = utilization), first



regress num_status2 i.sex ib10.major1 age1 cgpa first_gen ib5.race internshipco_op ///
total_internships foreign intensity jobsearch_skills_agg, vce(robust) 

quietly mprobit status1 i.sex ib10.major1 age1 cgpa first_gen ib5.race internshipco_op ///
total_internships foreign jobsearch_skills_agg jobsearch_method_ucs, base(3) vce(robust) //with foreign & jobsearch UCS

margins, dydx(*) atmeans predict(outcome(1))
margins, dydx(*) atmeans predict(outcome(2))
margins, dydx(first_gen) at(race=(1 2 3 5 6))
margins r.race, dydx(first_gen)
*Heckamn Correction
gen ucs = 1 if (jobsearch_method_ucs == 1)
replace ucs = 0 if (ucs==.)
keep if (jobsearch_method_ucs == 1)
quietly mlogit status1 i.sex i.major1 age1 cgpa first_gen##ib5.race internshipco_op ///
total_internships jobsearch_skills_agg, base(3) vce(robust) 
margins, dydx(*) predict(outcome(Full_Employed))
*Binomial Logit
encode postgrad_status, gen(dep_var_1)
gen status2 = (dep_var_1 != 3)
quietly logit status2 i.sex i.major1 age1 cgpa first_gen i.race internshipco_op ///
total_internships jobsearch_method_media jobsearch_method_print jobsearch_method_ucs /// 
jobsearch_method_network jobsearch_method_website jobsearch_skills_agg, vce(robust)
quietly logit status2 i.sex i.major1 age1 cgpa first_gen i.race internshipco_op ///
total_internships jobsearch_skills_agg, vce(robust)
margins, dydx(*) atmeans

*UCS MODEL
clear
insheet using ucs_model.csv
encode gender, gen(sex)
mvdecode sex, mv(3)
encode ethnicity, gen(race)
mvdecode race, mv(4)
encode broad_category, gen(major1)
encode no_japps, gen(apps)
mvdecode apps, mv(6)
encode dep_var, gen(status1)
gen age1 = real(age)
gen cgpa = real(gpa)

replace postgrad_status =  "Full-time employed" ///
if postgrad_status == "Employed full-time, full-time entrepreneur, full-time post-graduation internship, full-time fellowship, etc. (on average 30 hours or more per week)"

replace postgrad_status =  "Part-time employed" ///
if postgrad_status == "Employed part-time, part-time entrepreneur, part-time post-graduation internship, part-time fellowship, etc. (on average less than 30 hours per week)"

label define status3 3 "Full-time employed" 2 "Part-time employed" 1 "Seeking employment"
encode postgrad_status, gen(status3)

logit status2 i.sex i.major1 age1 cgpa first_gen i.race internshipco_op ///
total_internships intensity utilization jobsearch_skills_agg, vce(robust) 

ologit status3 i.sex ib10.major1 age1 cgpa first_gen ib5.race internshipco_op ///
total_internships c.jobsearch_skills_agg##c.utilization, vce(robust)


margins, dydx(*) atmeans
margins, dydx(*) 

*visualization
histogram jobsearch_skills_agg, discrete frequency normal // histogram with normal denisity
graph box basic_skills_agg, over(major1) // boxplot job search skills by status1

margins, over(resume_skills)
marginsplot

margins r.int_dummy, over(int_skills)
marginsplot, yline(0)



*write out
estpost tabstat jobsearch_skills_agg, by(status1) stat(mean sd count)
esttab . using depstat.rtf, cells("mean(fmt(a3)) sd count") label title("Descriptive Statistics: Job Search Skills by Postgraduate Status") // job search skills by status

estpost tab major1
esttab . using maj1_dstat.rtf, cells("b pct(fmt(2)) cumpct(fmt(2))") noobs varlabels(`e(labels)') onecell replace // major descriptive stats



