*The usual commands at the top to clear anything already open and establish an initial setup:
	*(You can setup a template/starter DO file that has your preferred initial setup/parameters)
clear 
capture log close
set more off, permanently

*Set a working directory where all your project files will be located (replace my username with your own):
cd "C:\Users\urbanmeet\Desktop\"

log using "StataClass_$S_DATE.log", replace 	

use "data_wide.dta", clear

*------------------------------
**MACROS: LOCALS vs. GLOBALS
*------------------------------

	*Macros are a kind of temporary holding space akin to "variables" in R, Python, 
	*and other general program languages (remember: think of your data set as a spreadsheet,
	*or in R/Python, etc. terms, a "data frame" and its variables as columns). These are also
	*different from "macros" in Excel, Macs, etc. which are a set of step automated via short code scripts.
*There are 2 flavors of Macros in Stat: LOCALS and GLOBALS. 
	*LOCALS last only as long as your commands are continuously running within a session 
		*and have limited (local/private) SCOPE, meaning their values are independent and cannot be accessed 
		*at different levels (i.e. within loops) in your code or other DO files you might run in the same session.
	*GLOBALS persist for your entire Stata session and have global (public) SCOPE, 
		*meaning their values are accesible and changeable at any point in your session.
*Both types of macros can be used to storre strings or numeric values/expressions:
local my1stlocalmacro "Hello, world!" //define LOCALS with the "local" command followed by what you want to name it.
di `my1stlocalmacro'  //refer to locals with an open single quote "`" (shift+ ~), the name, and then a close single quote/apostrophe "'" 
	*Uh oh, note that although the macro stored a string, when trying to display the value of the LOCAL, 
	*Stata first evaluates it/looks for it as a variable name.
*If we enclose the reference in double quotes, that may help us get closer to the desired output:
di "`my1stlocalmacro'"
	*On no again, the LOCAL macro is now empty since it is temporary/ephemoral, 
	*we have to define it again and run it together with our display command:
local my1stlocalmacro "Hello, world!"
di "`my1stlocalmacro'"

*Globals on the other hand will persist and do not require us to redefine 
	*after the interactive session or DO file (or set of commands in a DO file if we only run a section) is finished:
global my1stglobalmacro "Hi, friend" //define LOCALS with the "local" command followed by what you want to name it.
di $my1stglobalmacro //refer to GLOBALS with the dollars sign "$" followed by the global name
di 	"$my1stglobalmacro"
di 	"$my1stglobalmacroly guy" // if I try to add some text right after the global name, Stata thinks that is part of the global's name
di 	"${my1stglobalmacro}ly guy" // enclose the global's name in curly brackets to remove this amgiguity
	
*You can use macros to store lists of variables that you want to use over and over again, 
local myvarlist "age gender"
sum `myvarlist'
*Or for filepaths to use/save data and results from/to:
pwd
local workingdir `c(pwd)'
di "`workingdir'"
global saved_data "`workingdir'\Stata 301\"
capture noisily mkdir "${saved_data}" //create the directory, use capture in case it already exists...
save "${saved_data}data_wide_copy.dta", replace //save the file there
*You can also set them to the value of some expression:
local my2ndlocalmacro = 2+2 
di "`my2ndlocalmacro'"
*Local macros are also used as part of loops (see below)

*IN practical terms, I find GLOBALS easier to work with as they persist, and I tend not to do anything too too fancy things like
	*running many PROGRAMS (see below) or DO/ADO (those downloaded user written commands) files  within other DO files 
	*where scoping would be a bigger issue. However, it is technically bad form to use GLOBALS generally due to potential conflicts.
	*Strictly speaking, good programming form is to use LOCALS rather than GLOBALS unless you have a program that must remember something
	*from one run to the next. Even with DO files, you can actually pass values from one DO file to another run within it with LOCAL arguments (see below)

*------------------
**LOOPING
*------------------

/*Use forvalues for looping over numeric values with consistent intervals	*/
forvalues i=1(1)10 { 		/*syntax is i=min(interval)max 					*/
	display "`i'"				/*call the values with `i'					*/
	}							/*close the bracket							*/
forvalues i=1(2)10 { 		/*loop over odd values 		 					*/
	display "`i'"				
	}	
forvalues i=2(2)10 { 		/*loop over even values 		 				*/
	display "`i'"				
	}	

/*Want to generate a variable that's the number of theft arrests per person 
could write out arr_theft_tot=arr_theft1 + arr_theft2 +...+arr_theft39 
or use a loop to do this all more easily in one step*/
tab arr_theft4, m
tab arr_theft4, m nolabel	

/*If any of the values are missing the sum will be 
missing, so this command sets the original variables to 0 if missing*/
forvalues i=1(1)39 {
	replace arr_theft`i' = 0 if arr_theft`i' == .
}

gen arr_theft=0			/*Can only generate once so do it before the loop*/		
forvalues i=1(1)39 {
	replace arr_theft=arr_theft + arr_theft`i'
	}
list id arr_theft arr_theft1 arr_theft2 arr_theft3 arr_theft4  in 1/10										

	
/*Want to generate a variable that's the number of arrests per year per person*/
/*Can loop within loops*/
forvalues j=2012(1)2014 {
	gen arr_`j'=0
	forvalues i=1(1)39  {
		replace arr_`j'=arr_`j'+1 if arr_y`i'==`j'
		}
	}
list id arr_2012 arr_y1 arr_y2 arr_y3 arr_y4  in 1/10										


/*Use foreach for looping over non-numeric values or numeric values with 
inconsistent intervals														*/
/*Want to create a similar variable as the number of theft arrests for alcohol and other type arrests*/
foreach k in arr_alcohol arr_other { /*Syntax is "k in" some list strings or numbers
										separted by spaced*/
	display "`k'"
	}

* replace missings
forvalues i=1(1)39 {
	replace arr_alcohol`i' = 0 if arr_alcohol`i' == .
	replace arr_other`i' = 0 if arr_other`i' == .	
}	
	
foreach k in arr_alcohol arr_other {
	gen `k'=0			/*Can only generate once so do it before the loop*/		
	forvalues i=1(1)39 {
		replace `k'=`k' + `k'`i'
		}
	list id `k' `k'1 `k'2 `k'3 `k'4  in 1/10	
}

/*Want to do the same thing for the regression output for the entire sample using a varlist*/
local varlist "arr_theft arr_alcohol arr_other"
*Install outreg2, a user written command to output regression results in a pretty way, 
	*more on this in future weeks...
capture ssc install outreg2
foreach var of varlist `varlist' { /*Note syntax here is different, "of varlist" 
								instead of "in"								*/
	reg `var' age gender 
	outreg2 using "regressions.doc",  label ctitle(`var') append 
}

/*Want to do the same thing for a subpopulation*/
local varlist "arr_theft arr_alcohol arr_other"
forvalues i=0(1)1 {
	foreach var of varlist `varlist' {
		reg `var' age if gender==`i'
		outreg2 using "regressions_bygender.doc",  label ///
		ctitle(`var', "gender==`i'") append /*added to ctitle to show subgroup*/
		}
}
	
*You can combine the "of varlist" syntax with the flexible ways Stata allows you to define a VARLIST 
	*in order loop through a group of variables that start, end, or have some other common section in their names.
*Let's try only looking at whether age and gender are related to if individuals had specifically a 4th arrest of anytype:
	*first I'll rename ALL the day and year variables to a slightly different pattern since we don't want to run our regression on them...
rename  arr_d* arrest_d*
rename  arr_y* arrest_y*
*Now loop through just the arrest "type" indicator variables (theft, alcohol, other)
	*but just for if each individual had a 4TH arrest of that type:
foreach var of varlist arr_*4 {
	di "`var'"
	reg `var' age gender 
	outreg2 using "regressions_type.doc",  label ctitle(`var') append 
}
*We could have also used this "foreach... of varlist..." syntax instead of the "forvalues" contstruction above
	*to loop through the 39 different versions of the various arrest type variables.
	
	
*The "forvalues" looping syntax assumes a regular pattern numeric pattern 
	*for values of a variable you might want to step through in your loop. 
	*However, this is not always the case, and trying to refer to a value 
	*that does not exist can lead to errors.
*We can use the "levelsof" syntax to loop through just the valid values of 
	*either a numeric or even a string variable:

*Let's say we don't know what years individuals' 1st arrests occured in or are
	*working with multiple data sets where the years covered may vary.
*If we wanted to run our regressions on whether individuals' 1st arrest 
	*was for each of the 3 potential reasons by year, we would need to manually
	*check the arrest years in this data set and then loop through only those values.
*Or we could just use "levelof" to show and return the different levels of the "arrest_y1" variable
	*and then just loop through those values:
levelsof arr*_y1, local(levels)
display "`levels'"
foreach l of local levels {
foreach var of varlist arr_*4 {
	di "`var' `l'" 
	reg `var' age gender if arrest_y1 == `l'
	outreg2 using "regressions.doc" ,  label ctitle("`var'_`l'") append 
}
 }
*rename the variables back:
rename   arrest_d* arr_d*
rename   arrest_y* arr_y* 

/*If and else statements let you control the 
flow of your program to execute some commands and/or
skip others depending on some condition:*/
forvalues i=1(1)39 {
	if `i'<10 {
		display "Less than 10"
		}
	if `i'>=10 & `i'<20 {
		display "10-20"
		}
	else if `i'>=20 	{	
		display "Greater than 20"
		}
}
	
/*Suppose you want to run regressions for both binomial and continuous variables,
but you don't want to go through the trouble of specifying separate lists for each type:*/
local varlist "arr_theft arr_theft1"
	sum arr_theft 
	return list
	sum arr_theft1
	return list
	
foreach x of varlist `varlist' {
	qui sum `x'
	if r(max)==1 {				/*This won't always work in every context make 
								sure you know the distribution of your varlist 
								before using this syntax to separate out binomials for
								this*/
		probit `x' age gender
	}
	else if r(max)>1  {	
		regress `x' age gender
	}
}

*For more on returning stored results see the help file for the command you are using or for "return"
help summarize
help return 
help program //you can also return results in the own programs (see below) and commands (ADO) files you create

*----------------	
**PROGRAMMING
*----------------

*Analogous to defining a "function" in R, Python, etc. 
	*Allows you to take one or more pieces of varying input and 
	*execute the same set of commands for the varying input.
capture program drop test 	/*Drops any previous definition of this program*/
program define test			/*Defines the name of the program*/
	args x					/*Defines the input(s) in the program*/
		display "`x'"		/*Tells stata what to do with that input*/
	end	
					/*Tells stata this is the end of your program*/
test "Stata is great" /*To run the program type the name and the input(s)*/
test 45
										
/*Suppose you want to make a bunch of different histograms*/								
histogram arr_theft, percent     			///                                
	title("Arrests for Theft")          	///                                                                          
	color("22 150 210") lcolor(black)		///
	width(1)								///
	ylabel(0(25)100,nogrid) 				///
	xlabel(0(5)35,nogrid) 					///
	xtitle("Number of Arrests")				/// 
	graphregion(fcolor(white)) 				///
	plotregion(style(none)) 			
										
capture program drop pretty_histogram
program define pretty_histogram
                args var title color num
					histogram `var', percent     						///                                
								title("`title'")						///               
                                color("`color'") lcolor(black)			///
								width(1)								///
								ylabel(0(25)100,nogrid) 				///
								xlabel(0(5)35,nogrid) 					///  
								xtitle("Number of Arrests")				/// 
                                graphregion(fcolor(white)) 				///
								plotregion(style(none)) 				
                graph export "AppendixA_Figure`num'.pdf", replace
end
 

pretty_histogram arr_theft  	"Arrests for Theft"  	"207 232 243" 	1
pretty_histogram arr_alcohol 	"Arrests for Alcohol" 	"70 171 219"	2
pretty_histogram arr_2012 		"Arrests in 2012" 		"253 216 112"	3
pretty_histogram arr_2013 		"Arrests in 2013" 		"253 191 17"	4
pretty_histogram arr_2014 		"Arrests in 2014" 		"202 88 0"		5

*PROGRAMS are a good illustration of scoping issues between GLOBALS and LOCALS.
	*What do you think the value of Y will be at the end in each of the situations below?
*1. LOCAL example:
capture program drop localexample 
program define localexample 
	args x 
local y = `x' +1
di "`y'"
end

*2. GLOBAL example:
capture program drop globalexample 
program define globalexample 
	args x 
global y = `x' +1 
di "`y'"
end
*What happened in the program, stays in the program for the local,
localexample 10
di "`y'"

globalexample 2
di "$y"
*which is not the same case for the global, it is updated within the program.

*Programmers NOTE: this can also be important for running DO/ADO files within
*another DO file. If you update a global in the child DO file you are running from 
*your Master/Parent DO file, it will also be updated for the Master DO file and any
*other subsequen child DO files you run in it after the original child DO file is done
*excecuting. This is not the case with local macros. Good programming form would be to
*generally use local arguments and returned values passed explcitily between DO files and
*programs rather than globals, generally. However, that is beyond the SCOPE of this session.

*--------------------------------------
**OUTPUTTING DESCRIPTIVE STATISTICS 
*--------------------------------------

*This will help you with speeding up your work by automating the outputting of your results from Stata to external files
use "FINRA_01.dta", clear  // use the old FINRA data file from the intro trainings
**Three (3) frequently used ways of outputting results to external files, each with pros and cons**
	* 1) POSTFILE:
		*Pros: 
			*Native to Stata 
			*Fairly flexible on what data you can put and in what order
		*Cons: 
			*Less easy to format and include context like variables names and labels
			*Less easy to use and output lots of information as it is based on looping and writes 1 line at a time
			
	* 2) TABOUT: 
		*Pros: 
			*Easy to use and output lots of information 
			*Easy to format and include context like variables names and labels
		*Cons: 
			*Not built into Stata-- have to download and install from SSC
			*Less flexible on what statistics you can run and in what order

	* 3) PUTEXCEL: 
		*Pros:
			*Similar to POSTFILE in that it is built into Stata
			*Easier to edit and manipulate specific cells/data points and add labels/text unlike POSTFILE, 
		*Cons:
			*Less automated and more tedious as you must specify which cells and ranges to write to in Excel with each command
	
** 1) POSTFILE: first way of outputting descriptive statistics 

*Postfile creates a second temporary data set in memory, separate from the one you have open
*You will run your summary statistics on the active data set, store the results in local macros,
*write the results in the locals to the temporary data set,
*and, finally, open the temporary data set and export it to an external Excel file

*First create a temporary data set in memory with a temporary name assigned to the local macro "memhold"
tempname memhold
*In this line we actually create the temporary dataset in memory (but which is not active) in the namespace "memhold"
*The different variables/columns we want in our temporary data set are listed between "memhold" and using 
*Using specifies where the data set actually gets saved/stored eventually
postfile `memhold' str20(varname) meanmale meanfemale pvaloftest using "${saved_data}FINRA_02_postfile.dta", replace
*Next we will specify the different variables that we want statistics on in a loop we can iterate through
*In this case we want to see if the mean/average value of these various variables differ significanlty by gender (A3)
foreach var in A3A    r_white r_black r_hisp r_asian r_other reg_ne reg_mw reg_south reg_west {
		*First find the mean value of the varible of interest for males (A3==1)
		su `var' if A3 == 1
		return list		//Return list displays the statistics stata saved and can be stored in your locals		
		*Store this average termporarily in a local macro called "meanmale"; we will write this vlaue to our temporary data file below in the "post" command line
		loc meanmale = r(mean)
		
		*Next, find the mean value of the varible of interest for females (A3==2)
		su `var' if A3==2 
		*store the result to a local macro called "meanfemale"
		loc meanfemale = r(mean)
		
		*Then, we want to see if the average for males and females differs statistically, 
		*so we will use the mean estimation and the postestimatation test command to see.
		*We could also use "ttest" to do this in one line, but "mean" is more flexible and allows us to use weights if we want
		mean `var', over (A3)
		test [`var']Male = [`var']Female
		*Save the 2-sided p-value of this difference of means test to a third local macro
		local pvaloftest = r(p)
	*Finally, for the variable we are actively looping through,
	*write the mean value for males, mean value for females, and 2-sided p-value of the difference
	*as a new observation (row) in our temporary data file (not the one we have open actively and are analyzing)
	post `memhold' ("`var'") (`meanmale') (`meanfemale') (`pvaloftest')
	}
*Postclose tells Stata we are done writing to the temporary data file we created 
*and to finalize/save it where we specified in the "postfile" command
postclose `memhold'

*Then we just have to open up and export that new data file and export the results
*First we may want to preserve our active data file, though, so we can restore it quickly to conduct additional analyses 
	*This part is optional, though, since you could just reopen your original data file, 
	*or save a working version here and reopen it after the export instead of using preserve/restore
preserve //optional
*Open up your results file data set:
use "${saved_data}FINRA_02_postfile.dta", clear
	*Export to Excel:
	export excel using "${saved_data}FINRA_02_postfile.xls", replace
restore //optional

*Take a look at the resulting Excel file for the output--its gives you the information you need, 
*but the numbers are not formatted and there are no column headings to tell you what metric is in each column
*Sometimes, the better option is... TABOUT 
*(though you would not be able to pull out and write the p-value for the significance test in TABOUT easily)


* 2) TABOUT: second way of outputting descriptive statistics that is pretty automated/easy to use
*Download command:
capture ssc install tabout 
*Can use to show tabulations
tabout A3 using "${saved_data}FINRA_02.xls", cells(col) stats(chi2)	replace 

*Or crosstabs (by gender in this case):
foreach characteristic of varlist A4A A6 A5 {
	tabout `characteristic' A3 using "${saved_data}FINRA_02.xls", cells(col) stats(chi2) append 
}
	
*Can also use to show summary statistics with the "sum" option
*You need to specify which statistic to show for each variable whose mean, median, etc. you want to show
*Tabout then runs this by the differing variables listed before "using"
tabout A3 A4A using "${saved_data}FINRA_02.xls", sum c(mean A3A  mean emp_full) f(4) append 
*f(4) indicates four digits after the decimal

*Again, you can use loops and loops within loops to automate and quicken your work...
foreach characteristic of varlist A4A A6 A5 {
foreach outcome of varlist A3A   emp_full {
tabout `characteristic' using "${saved_data}FINRA_02.xls", sum c(N `outcome' mean `outcome') f(4) append
}
}
*Can also download and use the OUTSUM command from SSC to export summary statistics, 
*but usually I find tabout along with the sum option to be adequate


* 3) PUTEXCEL: another way of outputting results from Stata to external file (the most tedious),
*but also the most flexible in terms of what to place in each individual cell and how to format it.
*First specify the file that you want to write your output to:
putexcel set "${saved_data}test.xls", replace
*Can write stored results/contents of local macros similar to postfile:
sum A3A
local avg = r(mean)
putexcel B2= `avg'
local stdDev  = r(sd)
putexcel B3  = `stdDev'
*Can also add labeling more easily than in postfile:
putexcel B1="Age" A2="Average" A3="Standard Deviation"

capture log close

*-------------------------
**EXERCISES  
**DATASET: data_wide.dta
*-------------------------

use "data_wide.dta", clear

**LOOPING
/* 1. Using a loop, generate a variable equal to the total number of arrests each 		
	person had had*/
gen arr_total=0
forvalues i=1(1)39 {
	replace arr_total=arr_total+1 if arr_d`i'!=.
}

/* 2. Use a loop to generate a variable to equal their age at arrest, e.g. age1 for 
age at arr_d1 and age2 for age at arr_d2, etc*/
forvalues i=1(1)39 {
	gen age`i'=floor((arr_d`i'-birth_d)/365)
}

/*3. Using a loop, create a variable for the date of their first arrest and the
	date of their last arrest*/

*Answer version 1
gen first_arr=.
gen last_arr=.
format first_arr last_arr %td
forvalues i=1(1)39 {
	replace first_arr=arr_d`i' if arr_d`i'<first_arr
	replace last_arr=arr_d`i' if (arr_d`i'>last_arr | last_arr==.) & arr_d`i'!=. 
}

*Answer version 2 - based on the idea that we know these are orderd*/
gen first_arr2=arr_d1
gen last_arr2=.
format first_arr2 last_arr2 %td 

forvalues i=2(1)39 {
	local j=`i'-1
	display "`i'"
	display "`j'"
	assert arr_d`j'<=arr_d`i'
	replace last_arr2=arr_d`j' if arr_d`i'==. & arr_d`j'!=.
	replace last_arr2=arr_d`i' if `i'==39 & arr_d`i'!=.
}

/*4. Using a loop, tab all of arr_theft1, arr_alcohol1, arr_other1, arr_total*/	

foreach x in arr_theft1 arr_alcohol1 arr_other1 arr_total {
	tab `x' 
}

/*Write a program that says "Hello, Name" and replaces a name that you input*/
capture program drop hello
program define hello
	args name
	display "Hello `name'"
	end
	
hello "Matt"

*----------------------------------------------------------------------
**EXERCISES for automating Output of summary/descriptive statistics:
**DATASET: FINRA_01.dta
*----------------------------------------------------------------------

*1. Start a new log file, open the FINRA_01 data file again, and save a working version under a different filename right away.
capture log close
log using "Stata_Summary output_EXERCISES_$S_DATE.log", replace
use "FINRA_01.dta", clear
save "${saved_data}FINRA_02.dta", replace
*2. Output descriptive tables that show the share of observations by their age group, race/ethnicity, gender/sex, income category, and census region.
tabout  A4A a_2029 a_3039 a_4049 a_5059 a_60plus A3 i_catvar censusreg using "${saved_data}FINRA_one-way_tabs.xls", cells(col) 	replace oneway //the "oneway" option produces a one-way tabulation (like the tab1 command) rather than a crosstab
*3. Output the distribution (crosstab) of race/ethnicity by gender/sex
tabout  A4A A3  using "${saved_data}FINRA_x-tab_race-sex.xls", cells(col) 	replace 

*4. Output the number of observations at each education level and the median value of age for each education level.
tabout A5 using "${saved_data}FINRA_ageN-p50.xls", sum c(N A3A  p50 A3A) f(4) replace 

*5. Repeat question 4, but use a different method for exporting your output (TABOUT, POSTFILE, or PUTEXCEL)
*USING POSTFILE:
tempname memhold
postfile `memhold' str20(varname) Nsample medianAge  using "${saved_data}FINRA_q5postfile.dta", replace
forvalues i=1/6{
		sum A3A if A5 == `i'
		local N =  r(N)  
		local med =  r(p50)  		
	post `memhold' ("A5 (eduation level) == `i'") (`N') (`med')
	}
postclose `memhold'
preserve 
use "${saved_data}FINRA_q5postfile.dta", clear

	export excel using "${saved_data}FINRA_q5postfile.xls", replace
restore 

log close
clear all

