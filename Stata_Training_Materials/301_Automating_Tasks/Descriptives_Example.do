**------------------------------------------------------------------------------
* Stata Users Group
* Descriptives_Example.do
* Created 		5/29/2019 	by M Gerken
**--------------------------------------/---------------------------------------
* This program gives a few examples of quickly generating descriptive statistics
**------------------------------------------------------------------------------

**------------------------------------------------------------------------------
* Directories & Locals
**------------------------------------------------------------------------------

local data "E:\Stata help\descriptives_example.dta"
local output "filepath"

cd "`output'"

**----------------------------------------------------------------------------
* Method 1: Using collapse
*			Example below calculates the mean, median, min, max across 5 vars
**----------------------------------------------------------------------------	
	
	use "E:\Stata help\descriptives_example.dta", clear
	
	* create holder variables
	foreach x of varlist var1-var5 {
		gen `x'_mean = `x'
		gen `x'_median = `x'
		gen `x'_min = `x'
		gen `x'_max = `x'
	}
	
	* Asterisk used as wild card, 
	collapse (mean) *_mean (median) *_median (min) *_min (max) *_max
	
	* Order variables
	order var1_* var2_* var3_* var4_* var5_* 
	
	export excel using "E:\Stata help\name.xls", sheet("Des") ///
		sheetmodify firstrow(variables)

**--------------------------------------------------------------------------
* Method 2: Using tabstat
*			Example below calculates the mean, median, min, max across 5 vars
**--------------------------------------------------------------------------

	use "E:\Stata help\descriptives_example.dta", clear
		
	tabstat var1-var5, stat(mean median min max)
	
	mrtab q3_1-q3_4 // good for dummy variables

**--------------------------------------------------------------------------
* Method 3: Using postfile
*			Example below uses postfile to create a temporary dataset where
*			you decide what descriptives to store in the columns. This example
*			stores the mean and number of observations for a variable, as 
*			well as the mean and number of observations of the variable by
*			another variable, in this case, region.
**--------------------------------------------------------------------------

	use "E:\Stata help\descriptives_example.dta", clear

	* create a temporary dataset named "memhold"
	tempname memhold

	/* create the structure of the postfile dataset, with each column labeled 
	according to descriptives of interest */
	postfile `memhold' str20(varname) meantot ntot mean1 n1 mean2 n2 mean3 ///
		n3 mean4 n4 nomiss ///
		using "E:\Stata help\descriptives_postfile.dta", replace
		
	loc varlist var1 var2 var3 var4 var5
		
	* loop through variables, generating means, and storing them as locals 
	foreach var of local varlist {
				
		su `var' // summarize command
		loc mean = r(mean) // store mean of variable as local 
		loc n = r(N) // store num obs of variable as local
		
		forvalues i=1/4 {		
			su `var' if region == `i' // summarize variable for each region
			loc mean`i' = r(mean) // store mean for that region
			loc n`i' = r(N) // store num obs for that region
		}
			mdesc `var' // summarize missingness of variable
			loc nomiss = r(miss) // store missingness in local

	* "post" the estimates to the temporary file
		post `memhold' ("`var'") (`n') (`mean') (`n1') (`mean1') (`n2') ///
		(`mean2') (`n3') (`mean3') (`n4') (`mean4') (`nomiss')
	}
	* close the temporary file
	postclose `memhold'

	preserve
	* open the temporary file
		use "E:\Stata help\descriptives_postfile.dta", clear

	* save the temporary file as an excel spreadsheet 
		export excel using "E:\Stata help\descriptives.xlsx", replace
	restore	
	