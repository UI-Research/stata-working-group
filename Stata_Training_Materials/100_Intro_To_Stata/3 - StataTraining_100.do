** LOCATION: D:\Users\clou\Desktop\Do
** CREATED BY: Emma Kalish
** CREATED ON: 7/20/15
** LAST EDITED: 6/29/20 by Cary Lou
** LAST RUN:
** DESCRIPTION: Example do file for Stata class
** NOTES: Uses Stata15
*****************************************************************************

*Review Stata interface/windows
	*Results (main) window: shows the commands that are run and the resulting output (errors show up in red text)
	*Variables window: shows variables in current dataset including any labels
	*Properties window: detailed characteristics of dataset and its variables as well as variable(s) selected in the Variables window
	*Review window: shows previous commands entered and if they resulted in an error (if text is in red)
	*Command window: allows users to type in commands to be executed directly/interactively 

*Basic structure of command -> [commandname][what (e.g., variable(s), file, etc.], [options]  
	
*Although you can run commands by typing them into the command window and using the dropdown menus, 
*The real power of Stata lies in using it as a statistical programming language. 
*That is creating scripts/programs in the form of DO files that allow you to save and reproduce your analysis.

*The purpose of using DO/Log files = recording and replicating your work (you can also steal from old DO files for new anlayses)
*To this end, create new versions of DO, LOG, and DATA files rather than saving over old ones.

**3 Main Types of Stata Files:
*Data files (end in .dta)  look like spreadsheets and contain the information you want to analyze
*DO files (end in .do) are essentially Stata programs that allow you to save and re-run/reproduce your analysis from scratch
*LOG files (end in .log [unformatted and can open with any text editor] or .smcl [formatted, but can only open with Stata]) 
	*capture the results (what appears in the main results window) of your commands/DO file  and contain a record of the steps taken in your analysis.


***Setting up your DO file and opening your data***
*Set your working directory:
cd "D:\Users\clou\Desktop"

*This command allows do file to run continuously rathering than having to click "more" on the screen
set more off, permanently
	
**Commenting your code
*Your DO file should contain comments to document your work allowing others to follow your work and 
*reminding yourself  of what you were doing later. There are a few ways to create comments, 
*you can start a line with an * (star/asterix) to make the line a comment. 
*You can also follow a command with a // (double forward slash) to make the REST of the line a comment
*To create a multi-line comment block start with /* and end with */
* /// (three forward slashes allow you to continue a command across multiple lines

*1st way to create a comment
set more off // 2nd way: comment the rest of this line 
/*3rd way: Block comment
This is all commented out
...
*/
*Allow a (long) command to run across lines with /// at the end:
set more ///
 off
 
*these commands close any open log files (capture log close) and 
*start a new log file (log using) to capture your output and results,
*the replace option (options always follow a comma) writes over 
*any old log files that have the same name in your working directory
capture log close
log using "Stata_Class_1.log", replace 
 
 
***Loading in your data*** 
*1) Copy and paste data from another program into the data editor or manually enter it:
edit
*2) Use the import command or wizard to directly bring in data from a file in another format
import excel "FINRA_01.xls", sheet("Sheet1") clear
*3) load the data you want to use with the Stata "use" command
	*add clear as an option at the end after a comma to empty any data that was in before
use "FINRA_01.dta", clear 	
* This is a file containing survey data on individuals background and financial situation


***Getting to know your data***
*Inspect/get a detailed look at your data using the data editor in browse mode:
browse
	*rows are observations/records; columns are variables/characteristics/features
	*Red data is coded as string, black is numeric, and blue is numeric with text labels.

*We can see this by using the 'display' command to turn Stata into a calculator:
*Adding 2+2 with numeric values
display 2+2   
*Adding 'stringvar'+"2" with string values
display stringvar +"2" 
*Show the value of the 'stateq' variable (will show the value of the 1st record)
display stateq 

*Describe will provide basic information on your data set and its variables:
describe
*Codebook provides more details on specific variables including missingness, range, example values or distribution
codebook stringvar respid stateq censusreg sloan sl_concern ed_lths
*List will print out values for the variables and records/observations specified
list stringvar respid stateq censusreg sloan sl_concern ed_lths in 1/10


***Descriptive statistics***
*You may want to examine variables of interest for your analysis more closely
*or include descriptive statistics for them in your study

*Use summarize for discrete or continuous numeric variables, 
*tabulate for ordinal or categorical variables, 
*and either for dummies/binary/indicators: 

*summarize the age variable
summarize A3A 
*or we can summarize more than one variable at a time 
*(age and whether observation is white):
summarize A3A  r_white
*tabulate education category variable
tabulate ed_catvar
*tabulate student loan recipiency variable with the missing option (, missing)
	*at the end of the command after a comma to show any missing values 
	*(coded as . for numeric data and "" for string data)
tabulate sloan, missing
*You usually don't have to type out the whole expression, 
*Stata will know what you mean if you abbreviate as long as 
*there is no ambiguity with other commands, variables, options, etc.
tab sloan, m
*Another option: see a labeled numeric variable without its value labels 
	*(i.e. see the underlying numeric values)
tab B1
tab B1, nolabel 
*Also, use tabulate with two categorical variables to show their crosstab:
tab ed_catvar sloan , missing
tab ed_catvar sloan, column //the column option reports the % within each row that are in each column category (%s in columns sum to 100%)
tab ed_catvar sloan, row //the row option reports the % within each column that are in each row category (%s in rows sum to 100%)
tab ed_catvar sloan, cell //the cell option reports the % in the entire table total that are in each cell (%s in cells sum to 100%)

*another way to look at your data - graphs
*Histogram showing the distribution of age: 
histogram A3A


***Subsetting your data***
*IF and IN statements allow you to operate on subsets of your data
*IN statements define subsets based on records' index (observation) number
*IF statements define subsets based on conditional statements 
	*& is AND 
	*| is OR  
	*Use == to compare the equality of two values
	* != is not equal to (! is NOT in general)
	* > is greater than
	* < is less than
	* >= is greater than or equal to (= must come after < or >, not before or it will not work, i.e. >= is CORRECT; => is INCORRECT) 
	* <= is less than or equal to
*Summarize age for just observations less than age 50:
summarize A3A  if A3A < 50
*Tabulate education for just observations less than age 50:
tabulate  ed_catvar  if A3A < 50
*or just those whose age is equal to 50:
tabulate  ed_catvar  if A3A == 50

*We already used an 'in' expression with 'list' above to show the values of 
*some of our variables for the first ten observations:
list stringvar respid stateq censusreg sloan sl_concern ed_lths in 1/10


***Creating new variables and updating existing variables***
*Be mindful of missing ("" if string or . if numeric ) values as well as special values codes
*Special values are often negative or high values like 9998, 9999, etc.
*and can indicate "don't know," "refused," etc. in survey data.

*always inspect your data initially via tab, summ, etc. to look for these and deal with them appropriately
*BEFORE constructing variables or starting your actual analysis

*binary (0/1) age variable
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

*You can also create categorical variables
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

**Other kinds of variables to create
*Scaling/transformations
*Create an age in months variable based on the age in years:
gen age_in_months = A3A*12
sum age_in_months A3A
*Create age-squared
gen age_squared = A3A*A3A
sum age_squared A3A
*Create logged-age
gen age_logged = ln(A3A)
sum age_logged A3A

*Create a new variable based on the value of multiple other variabls:
*Create a new dummy variable based on a few other dummies rather than just one
*B1 = checking acct; B2 = savings acct
gen bankacct = .
replace bankacct = 1 if B1 == 1
replace bankacct = 1 if B2 == 1
replace bankacct = 0 if B1 == 2 & B2 == 2
*could also have used an OR statement instead of an AND statement - depends on how you want to define things
replace bankacct = 0 if (B1 == 2 | B2 == 2) & bankacct ==.
*Confirm that you created variable correctly by crosstabbing vs. original variable(s)
tab bankacct B1 if B2 != 1, m
tab bankacct B2 if B1 != 1, m

*Interaction variable: multiple the values of the female indicator and age 
	*to create a variable that captures females age but is 0 for males
gen female_age = g_female*A3A
*Compare the original and new variable for females and non-females:
sum female_age A3A if g_female == 1
sum female_age A3A if g_female == 0


***Stata help: once you can use a Stata help file, you should be able to figure out almost any command!
help summarize
*Basic syntax of a Stata command:
*commandname expression if/in expression , options
*The 1st expression can contain variable names, assignement clauses, subcommands, etc. and depend on the particular command
*The if/in statement is followed by a 2nd expression defining the subset of the data set you want the command to work on
*Options always follow a single comma and are also command specific/dependent.
*Reference the help file for more on options, syntax, etc. for specific commands

*More on syntax is available here: http://www.stata.com/manuals13/gsw10.pdf

*A list of basic Stata commands is available at: 
* http://www.stata.com/manuals13/u27.pdf
* and
* https://people.ucsc.edu/~aspearot/Econ113W13%20/basic_tutorial_stata.pdf


*always save with a new name, do not overwrite your data. 
save "FINRA_02.dta", replace 
log close


*************
**EXERCISES**
*************
*1. Start a separate, new log file and open up the original FINRA_01 data set

*Start new Log file
capture log close
log using "Stata_Class_1_EXERCISES_$S_DATE.log", replace 
*The "$S_DATE" text is a special Stata expression that will add the day you are running the program 
	*to the end of the Log file name so you can create new files/records of your work automatically every day. 

*Open base data set
use "FINRA_01.dta", clear

*2. Provide descriptive statistics of variable G22. 
	*How many and what percentage of records have the value "Don't know", "Prefer not to say", and missing?
	*How are "Don't know" and "Prefer not to say" coded in the data?
	
*Determine what type of variable G22 is (dummy/categorical/continous)
codebook G22	
*Show descriptive statistics of G22 using tabulate since it looks to be categorical 
	*(use summarize to describe continous variables usually; could use either command for dummies)
tab G22, m //don't forget the missing option to show what % of all observations have a missing value for this variable: Share "Don't know" = 0.93% , Share "Prefer not to say" = 0.05% , and Share missing (.) = 79.85%
*Add the "nolabel" option to see how "Don't know" and "Prefer not to say" are coded numerically 
tab G22, m nolabel //"Don't know" is coded as 98; "Prefer not to say" is coded as 99


*3. Create a new version of this variable called G22_clean that recodes "Don't know" and "Prefer not to say" to missing
	*Crosstab the new and old versions of the variable so that you can confirm you created it correctly.
	
*Start by setting the new variable to missing so that "Don't know" and "Prefer not to say" are recoded to missing automatically
gen G22_clean = .
*Then update the values of the new variable using replace  to the value of the old variable only when they are "valid"
replace G22_clean = 1 if G22 == 1
replace G22_clean = 2 if G22 == 2
*I can also create labels to describe the new variable and its new values
*label the variable
label var G22_clean "Clean version of G22"
*label its values 
label define G22_clean_label 1 "Yes" 2 "No"
label value  G22_clean  G22_clean_label
*Finally check the new vs. old variable using tabulate to confirm it was created correctly
tab G22 G22_clean ,m // looks good


*4. What is the average number of dependent children (depchild)? What is the 25th percentile? 75th percentile?

*You can get "standard" descriptive statistic percentiles by adding the detail option to the summarize command:
summ depchild, d //the 25th %tile is 0; the 75th %tile is 1.


*5. Use HELP to figure out how to use the "centile" command to produce the 20th, 40th, 60th, and 80th percentile
	*for the "wgt_n2" variable.

*Pull up the Stata help file
help centile
*Use centile to get the 20th, 40th, 60th, and 80th percentile of "wgt_n2" since summarize, detail does not provide these
centile wgt_n2, centile(20 40 60 80) //the syntax for centile is a little tricky as the option needed to specify the specific percentile cuts to show repeats the command name
*The 20th %tile is .4376673; the 40th %tile is .6453935; 60th %tile is 1.083546; 80th %tile is 1.534317


*6. Create a new categorical version of the weight variable called "wgt_n2_quintile" that contains information on 
	*which quintile each record's weight "wgt_n2" is in using the results of the centile command from question 5.

*Create this new variable and set to missing initially
gen wgt_n2_quintile = .
*Update the value with the percentile number; make sure the ranges you use in the "if" statements reflect what you really want and do not overlap
replace wgt_n2_quintile = 1 if wgt_n2 < .4376673
replace wgt_n2_quintile = 2 if wgt_n2 >=  .4376673 & wgt_n2 < .6453935 
replace wgt_n2_quintile = 3 if wgt_n2 >=  .6453935  & wgt_n2 < 1.083546
replace wgt_n2_quintile = 4 if wgt_n2 >=  1.083546 & wgt_n2 < 1.534317 
replace wgt_n2_quintile = 5 if wgt_n2 >=  1.534317 & wgt_n2 < . // Missing (.) is the highest numeric value in Stata, 
																*so specifying that the variable range should be less than missing here 
																*will make sure that if any missing values exist, 
																*they will not get accidentally coded into the 5th quintile (we only want to count valid values)
*Tab to desribe this new variable
tab wgt_n2_quintile, m 
*Confirm it was created correctly by summarizing the original variable by their value in the the new version fo the variable
summ wgt_n2 if wgt_n2_quintile == 1
summ wgt_n2 if wgt_n2_quintile == 2
summ wgt_n2 if wgt_n2_quintile == 3
summ wgt_n2 if wgt_n2_quintile == 4
summ wgt_n2 if wgt_n2_quintile == 5
	*The min and max value of the original variable for each group indicate that the quintile variable was created correctly 
																
*7. Save a new version of the data file called FINRA_03.dta, 
	*close your log, 
	*and then inspect your log by navigating to where you saved it and opening it with notepad.

*save new version of the data
save "FINRA_03.dta", replace
*close log
log close
*view log by navigating to it and opening it with Stata or notepad. 
	*Mine is in my working directory "D:\Users\clou\Desktop"


