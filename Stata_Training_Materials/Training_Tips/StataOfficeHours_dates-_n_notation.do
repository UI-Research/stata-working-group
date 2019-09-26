* programmer: Cary Lou
* Date created: 6/27/19
* goal: Example of working across records (different dates for the same entity) using _n notation for Stata office hours


*setup working directory, almost all other directories will be relative to this path:
*cd "C:\Users\urbanmeet\Downloads\"

*clear any data and allow continuous output:
clear all
set more off

*Open example calories tracking data set: 
sysuse xtline1.dta , clear
*describe data:
des
codebook
*Repeated observations of the same entities over time (person-day level observations in a long panel/longitudinal setup)
browse

*The built in _n and _N expressions allow you to explicitly reference rows/observations by absolute and relative index number (i.e., row number)
*_n is essntially the index/observation number of each row
list if _n == 1 // look at first observation
*_N is the total number of observations/number of the last observations/rows in the data set or group:
list if _n == _N // look at last observation

*Use built in _n/_N expressions and lag/lead subscript notation to work across rows of observations for the same person across multiple days:
*Create a variable showing the change in calories consumed between days:
	*sort by person and date first
	sort person day
	*Create a variable showing calories in current day minus calories in prior day/row/observation:
	gen diff_cal_from_prior = calories - calories[_n-1] if person == person[_n-1]
		*Make sure to add condition that we are looking at the same person in both the current and prior day/row/observation
	*Create a variable showing difference in calories from current day to next day:
	gen diff_cal_from_next = calories[_n+1] - calories  if person == person[_n+1]

sum diff_cal_from_prior diff_cal_from_next
browse

*Maybe you want to check the number of days gap between each observation to see if there are any days missing during the year or duplicates (could also use duplicates subset of commands for the latter)
sort person day
*Number of days between prior observation and current for each person:
gen day_gap_from_prior = day - day[_n-1] if person == person[_n-1]
*Number of days between current observation and next for each person:
gen day_gap_from_next = day[_n+1] - day   if person == person[_n+1]

*No missing or duplicate days during the year
sum day_gap_from_prior day_gap_from_next
codebook day_gap_from_prior day_gap_from_next
browse
*but this could be useful if you are only looking to retain values for sequential days or after longer gaps in other data sets.

*These expressions can be combined with the "by :"/"bysort :" prefixes, which allows you to index within groups defined by "by :"
sort person day
by person: gen obs_num_person = _n
by person: gen total_obs_person = _N
browse

*You can use them to find the starting or ending n_th value for each entity:
sort person day
by person: gen start_day = day if _n == 1
by person: gen end_day = day if _n == _N
by person: gen start_calories = calories if _n == 1
by person: gen end_calories = calories if _n == _N
browse
by person: replace  start_day = start_day[_n-1] if start_day == . & start_day[_n-1] != . & person == person[_n-1]
browse
format start_day %td
by person: replace  end_day = end_day[_n+1] if end_day == . & end_day[_n+1] != . & person == person[_n+1] 
browse // whoops this doesn't work as intended, since Stata works sequentially, have to resort with date descending:
gsort person - day
by person: replace  end_day = end_day[_n-1] if end_day == . & end_day[_n-1] != . & person == person[_n-1] 
format end_day %td
browse
*You could do the same thing to find the max or min value, by comparing each observation's value to the previous, but easier to do with by/bysort and egen/ereplace:
sort person day
by person: egen max_calories_person = max(calories)
by person: sum calories max_calories_person
browse



*close/clear everything:
clear
capture log close
exit

