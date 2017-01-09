sysuse auto.dta, clear //remove data from memory 
set more off
log using h1.txt, text replace 
summarize mpg
log close
