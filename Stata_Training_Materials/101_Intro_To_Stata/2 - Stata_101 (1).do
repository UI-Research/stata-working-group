*****************************************************************************
** LOCATION: D:\Users\HHassani\Desktop
** CREATED BY: Emma Kalish
** CREATED ON: 7/20/15
** LAST EDITED: 7/15/19, by Matt Gerken
** LAST RUN: 7/15/2019
** DESCRIPTION: Example do file for Stata class, with exercises and solutions
** NOTES: Uses Stata15
*****************************************************************************

*-----------------------------
*1 - Setting up your program
*-----------------------------

*Set a working directory where all your project files will be located:
cd "D:\Users\HHassani\Desktop"
*Comments can note or describe things, or they can preserve a command that you want to run later

/*these commands close any open log files and start a new log file, writing over 
any old log files that have the same name */
capture log close
log using "Stata_101.log", replace

*this command allows do file to run continuously
set more off, permanently

*load the data you want to use - add clear at the end to empty any data that was in before
use "FINRA_01.dta", clear

*-------------------------------
*2 - Getting to know your data
*-------------------------------

*Inspect/get a detailed look at your data using the data editor in browse mode:
browse
	
	*Rows are observations/records; columns are variables/characteristics/features
	*Red data is coded as string, black is numeric, and blue is numeric with text labels.
	
*Count: number of observations in your dataset
count
*Describe: basic information on your data set and its variables
describe
*Codebook: details on specific variables including missingness, range, example values or distribution
codebook ed_catvar g_female A3A
*List: prints out values for the variables and records/observations specified
list ed_catvar g_female A3A in 1/10

*--------------------------------
*3 - Detailed look at your data
*--------------------------------

*Continuous/numeric variables
summarize A3A 
summarize A3A  r_white //can summarize multiple variables at once

*Categorical variables
tabulate ed_catvar

*Use the missing option to show any missing values (coded as . for numeric data and "" for string data)
tabulate sloan, missing

*Can usually abbreviate. The following line gives you the same output as the previous one
tab sloan, m

*Crosstabbing: *Can easily see combinations in your data
tab ed_catvar sloan, missing

*Column percent: % within each row that are in each column category (%s in columns sum to 100%)
tab ed_catvar sloan, column //For those with and without student loans, what is the education breakdown?

*Row percent: % within each column that are in each row category (%s in rows sum to 100%)
tab ed_catvar sloan, row //For those at each level of education, what percent has student loans?

*Cell: % in the entire table total that are in each cell (%s in cells sum to 100%)
tab ed_catvar sloan, cell //What percent of people at each educational level do or do not have student loans?

*another way to look at your data - graphs
histogram A3A // histogram showing the distribution of age

*---------------------------
*4 - Subsetting your data
*---------------------------
/*IN statements define subsets based on records' observation number (index)
    IF statements define subsets based on conditional statements:
	equals (==)
	not equals (!= or ~=)
	greater than (>)
	less than (<)
	greater than or equal to (>=)
	less than or equal to (<=)
You can combine operators using the following Booleans:
	and (&)
	or (|)
*/
	
*Summarize age for just observations less than age 50:
summarize A3A  if A3A < 50
*Tabulate education for just observations less than age 50:
tabulate  ed_catvar  if A3A < 50
*or just those whose age is equal to 50:
tabulate  ed_catvar  if A3A == 50

*We already used an 'in' expression with 'list' above to show the values of 
*some of our variables for the first ten observations:
list stringvar respid stateq censusreg sloan sl_concern ed_lths in 1/10

*-----------------------------------------------------------
*5 - Creating new variables and updating existing variables
*-----------------------------------------------------------

/*Be mindful of missing ("" if string or . if numeric ) values and special values codes.
Special values are often negative or high values like 9998, 9999, etc. and can indicate "don't know," "refused"  in survey data.
Always inspect your data initially via tab, summ, etc. to look for these and deal with them appropriately
	before constructing variables or starting your actual analysis */

*Binary (0/1) age variable
*The 'generate' creates a new variable with the name specified and set to the value after the equals sign
generate a1824 = 0

*The 'replace' command updates the values of an existing variable; 
	*often you'll combine it with if statements to change the values of just a subset of observations
replace a1824 = 1 if A3A >= 18 & A3A < 25

*look at your variable after you make it
tab a1824, m

*And compare it to the original
summarize A3A if a1824 == 0 
summarize A3A if a1824 == 1

*Finally, label your variable
label variable a1824 "age between 18 and 24"

*Categorical variables
*Creating a variable that equals 1 if the respondent is aged 18-24, 2 if 25-60, and 3 if 60+
gen age_cat = .
replace age_cat = 1 if  A3A > 17 & A3A < 25
replace age_cat = 2 if A3A > 24 & A3A < 61
replace age_cat = 3 if A3A > 60

*label your variable
label variable age_cat "age categories"

*label the values of your variable
label define age 1 "18-24" 2 "25-60" 3 "more than 60"
label values age_cat age
tab age_cat, m

*Confirm that you created variable correctly by crosstabbing vs. original variable(s)
tab A3A age_cat , m

*tab one variable based on another variable
tab g_female if age_cat == 3

**Other kinds of variables to create
*Scaling/transformations
*Create an age in months variable based on the age in years:
gen age_in_months = A3A*12
sum age_in_months A3A

*Create age-squared
gen age_squared = A3A*A3A
sum age_squared A3A

*Create logged-age
*For logged variables, you need to recode zeros and negatives.Common solution: set all negatives equal to zero then add one to all values
*This variable is clean, so we don't need to do that
gen age_logged = ln(A3A)
sum age_logged A3A

*Create a new variable based on the value of multiple other variabls:
*Create a new dummy variable based on a few other dummies rather than just one
*B1 = checking acct; B2 = savings acct
codebook B1 B2
gen bankacct = .
replace bankacct = 1 if B1 == 1
replace bankacct = 1 if B2 == 1
replace bankacct = 0 if B1 == 2 & B2 == 2

*could also use an OR statement instead of an AND statement - depends on how you want to define things
replace bankacct = 0 if (B1 == 2 | B2 == 2) & bankacct ==.

*check your variable is created correctly
tab bankacct B1 if B2 != 1, m
tab bankacct B2 if B1 != 1, m

*Setting up so you don't have to manually check
*"assert" command will run an error if there's a false statement and stop your program
assert bankacct == 1 if B1 == 1 | B2 == 1

*Interaction variable: multiple the values of the female indicator and age 
	*to create a variable that captures females age but is 0 for males
gen female_age = g_female*A3A

*Compare the original and new variable for females and non-females:
sum female_age A3A if g_female == 1
sum female_age A3A if g_female == 0

*----------------------
*6 - Stata help
*----------------------

*Once you can use a Stata help file, you can figure out almost any command!
*Reference a specific command's help file for syntax (order), options, and more
help summarize
/*Basic syntax of a Stata command:
	commandname expression if/in, options
	The 1st expression can contain variable names, assignement clauses, subcommands, etc. and depend on the particular command
	The if/in statement is followed by a 2nd expression defining the subset of the data set you want the command to work on
	Options always follow a single comma and are also command specific/dependent.

*More on syntax is available here: http://www.stata.com/manuals13/gsw10.pdf
A list of basic Stata commands is available at: 
 http://www.stata.com/manuals13/u27.pdf
 and
 https://people.ucsc.edu/~aspearot/Econ113W13%20/basic_tutorial_stata.pdf
*/

*always save with a new name, do not overwrite your data. 
save "FINRA_02.dta", replace 
log close

*-----------------
*EXERCISES
*-----------------

******************************************************************************
*1. Start a separate, new log file and open up the original FINRA_01 data set
******************************************************************************

*Start new Log file
capture log close
log using "Stata_101_EXERCISES_$S_DATE.log", replace 
*The "$S_DATE" text is a special Stata expression that will add the day you are running the program 
	*to the end of the Log file name so you can create new files/records of your work automatically every day. 

*Open base data set
use "FINRA_01.dta", clear

*****************************************************************************
*2. Provide descriptive statistics of variable G22. 
	*What # and % of records have the value "Don't know", "Prefer not to say", and missing?
	*How are "Don't know" and "Prefer not to say" coded in the data?
*****************************************************************************
	


********************************************************************************************
*3. Create a new version of this variable called G22_clean that recodes "Don't know" and 
    * "Prefer not to say" to missing, Crosstab the new and old versions of the variable 
	* so that you can confirm you created it correctly.
********************************************************************************************
	


****************************************************************************
*4. What is the average number of dependent children (depchild)? 
   *What is the 25th percentile? 75th percentile?
****************************************************************************



*****************************************************************************
*5. Use HELP to figure out how to use the "centile" command to produce the 
*   20th, 40th, 60th, and 80th percentile for the "wgt_n2" variable.
*****************************************************************************



****************************************************************************
*6. Create a new categorical version of the weight variable called 
*   "wgt_n2_quintile" that contains information on which quintile each record's 
*   weight "wgt_n2" is in using the results of the centile command from question 5.
****************************************************************************
	


***************************************************************************
*7. Save a new version of the data file called FINRA_03.dta, 
	*close your log, and then inspect your log by navigating to where 
	*you saved it and opening it with notepad.
***************************************************************************

*save new version of the data
save "FINRA_03.dta", replace
*close log
log close
*view log by navigating to it and opening it with Stata or notepad. 
	*Mine is in my working directory "D:\Users\hhassani\Desktop"

