local x 6
local x = `x' + 1

local ans "yes","no"
display "`ans'"
if "`ans'" == "yes"{
	display "affirmative"
}

local xperi "grass" "green"
forvalues i=1/`xperi'{
	display "`xperi'"[`i']
}

local list "0" "1" "3" 
forvalues i = 1(1)3 {
	di `:word `i' of `list''
}

local list "0" "1" "3" 
forvalues i = 1(1)3{
	di "`:word `i' of `list''" 
}





local list "0" "2" "4" "6" "8" "10" // store string list in local ❵list✬
 forvalues i = 1/6 { // for each value of ❵i✬ = [1,6]
 di "`:word `i' of `list''" // display the ❵i✬th word in ❵list✬
}


tokenize 0 2 4 6 8 10 // store elements of list in sequential locals
 forvalues i = 1(1)6 { // for each value of ❵i✬ = [1,6]
 di ``i'' // display the ❵i✬th positional local
} 


local list "0" "1" "3" 
forvalues i = "1/`list'"{
	di `i'
}

clear
local files "/Users/arinzenwoye/Desktop/work_files/checkdta.csv  /Users/arinzenwoye/Desktop/work_files/Lsa_data.csv"
local states "AL NY"
local new_file "/Users/arinzenwoye/Desktop/stata_files/checkdta.dta /Users/arinzenwoye/Desktop/stata_files/Lsa_data.dta"

forvalues i = 1/2 {
	insheet using "`:word `i' of `files''"
	gen state = "`:word `i' of `states''"
	save "`:word `i' of `new_file''", replace
	drop _all
}


local files "/Users/arinzenwoye/Desktop/work files/b1.csv"  "/Users/arinzenwoye/Desktop/work files/Lsa_data.csv"	
forvalues i = 1/2 {
	di "`:word `i' of `list''" 
}

local list "/Users/arinzenwoye/Desktop/work_files/checkdta.csv /Users/arinzenwoye/Desktop/work_files/Lsa_data.csv" 
 forvalues i = 1/2 { // for each value of ❵i✬ = [1,6]
  insheet using "`:word `i' of `list''"
  drop _all
}











