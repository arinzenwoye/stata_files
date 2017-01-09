*set more of command so the output does not pause after each page 
sysuse ///
auto.dta, clear //remove data from memory 
set more off
summarize mpg 
log using example.txt, text replace //(create an udated smcl file in text form)
scalar a = 2*3 
scalar b = "2 times 3"
display b a
local xlist "price weight"
regress mpg `xlist', noheader
*make artificial dataset of 100 observations on 4 uniform variables
clear 
set obs 100
set seed 10101 
generate x1var = runiform()
generate x2var = runiform()
generate x3var = runiform()
generate x4var = runiform()
generate sum = x1var + x2var + x3var + x4var
summarize sum
quietly replace sum = 0
foreach var of varlist x1var x2var x3var x4var{
	quietly replace sum = sum + `var'
}
summarize sum 
quietly replace sum = 0 
forvalues i = 1/4{
	quietly replace sum = sum + x`i'var
}
summarize sum 
quietly replace sum = 0 
local i 1
while `i' <=4{
	quietly replace sum = sum + x`i'var
	local i = `i' + 1
}
summarize sum

log close
exit, clear

*destring and tostring to convert from and to strings 

global pathdata 
