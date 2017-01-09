log using hello.txt, text replace

capture program drop hello
program hello
	display "hi there"
end

capture program drop goodbye
program goodbye
	display "thank you for using STATA"
end

sysuse auto.dta, clear //remove data from memory 
set more off

capture program drop meddiff
program meddiff
	tempvar diff
	generate `diff' = price + weight
	pause just created diff
	_pctile `diff' , p(50)
	display "Median difference = " r(r1)
end

pause on 
meddiff



log close

