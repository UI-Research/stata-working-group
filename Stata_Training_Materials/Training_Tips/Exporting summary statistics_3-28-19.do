*3-28-19
*Location: D:\Users\HHassani\Box Sync\Box Sync\Stata Trainings-Workgroup\Stata Office Hours tips and examples
*Exporting summary statistics from Stata
cd "D:\Users\HHassani\Box Sync\Box Sync\Stata Trainings-Workgroup\Stata Office Hours tips and examples"

*Use census data built into stata
clear all
sysuse census

***
*Manual
***
* 1. Sum, tab variables
* 2. Copy to excel
* Pros: easy
* Cons: tedious, lots of room for error, if you change parameters have to re-do everything

sum pop-divorce, d
*pull out mean, std dev, median, n
*Copy table

*By region
tab region, m
sum pop if region == 1, d
forval region = 1(1)4 {
	sum pop-divorce if region == `region', d
}



***
* Collapse
***
* 1. Add variables
* 2. Collapse
* 3. Export
* Pros: Get a dataset with collapse
* Cons: Stata can only hold one dataset at a time, so need to use preserve/restore; quite slow
global demogvars ///
	pop poplt5 pop5_17 pop18p pop65p /// age
	popurban medage death marriage divorce // other stats

* Set up the collapse. You can only get one summary stat from each var, so need to replicate each var
foreach var in $demogvars {
	gen `var'_mean = `var'
	gen `var'_sd = `var'
	gen `var'_med = `var'
	gen `var'_n = `var'
}

preserve

collapse ///
	(mean) *_mean ///
	(sd) *_sd ///
	(median) *_med /// could also do (p50)
	(count) *_n

export delim using "census1980_collapse_$S_DATE.csv", replace

restore

collapse ///
	(mean) *_mean ///
	(sd) *_sd ///
	(median) *_med /// 
	(count) *_n, ///
	by(region)

export delim using "census1980_collapse_region_$S_DATE.csv", replace

restore


***
* Tabout
***
* 1. Tabout
* Pros: Directly output summary vars
* Cons: Not as easy to batch output

tabout region using "census1980_tabout_region_$S_DATE.xls", ///
      c(mean pop sd pop median pop count pop ///
	mean poplt5 sd poplt5 median poplt5 count poplt5 ///
	mean pop5_17 sd pop5_17 median pop5_17 count pop5_17 ///
	mean pop18p sd pop18p median pop18p count pop18p ///
	mean pop65p sd pop65p median pop65p count pop65p ///
	mean popurban sd popurban median popurban count popurban ///
	mean medage sd medage median medage count medage ///
	mean death sd death median death count death ///
	mean marriage sd marriage median marriage count marriage ///
	mean divorce sd divorce median divorce count divorce) ///
	sum f(1c) replace


*lots more features available, including survey options, frequencies, formatting
tabout region using "census1980_tabout_region_freq_$S_DATE.xls", ///
	c(freq col row) ///
	f(0c 1) replace



