* programmer: Cary Lou
* Date created: 2/22/19
* goal: Example of auto creating directories for Stata office hours


*setup working directory, almost all other directories will be relative to this path:
cd "C:\Users\clou\Downloads\"

*clear any data and allow continuous output:
clear all
set more off

*create a directory for examples:
mkdir "Stata_Auto Folder Example\"

*error if we do it again:
mkdir "Stata_Auto Folder Example\"

*use capture to override error and keep going
capture mkdir "Stata_Auto Folder Example\"

*use capture noisily to override error but see that it occured:
capture noisily mkdir "Stata_Auto Folder Example\"

*look at help file:
help mkdir

local dir `c(pwd)'
di "`dir'"
cd "`dir'\Stata_Auto Folder Example\"

*Open example auto data set: 
sysuse auto.dta, clear
*describe data:
des
tab foreign, m // show output by foreign/domestic status
tab foreign, m nolabel

*install tabout to export findings: 
ssc install tabout

*Run output for each type of car origin (foreign/domestic):
levelsof foreign , local(levels) 
di "`levels'"
foreach origin of local levels {
di "`origin'"
tabout rep78  using "exampleoutput_foreign_`origin'.xls" if foreign == `origin' , replace 

}

*close/clear everything:
clear
capture log close
exit

