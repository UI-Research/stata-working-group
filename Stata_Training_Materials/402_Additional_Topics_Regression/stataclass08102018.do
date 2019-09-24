infix hspnon 9-10 race 20-21 sex 31-32 numkids 41-43 ageint 52-54 /*
*/ age1st 63-65 age2nd 74-76 using "D:\Martin_UI\STATA users group\cps695dat.txt"

* variable description: hspnon = 1 if hispanic, 2 if not
tab hspnon, missing
* race = 1 if white, 2 if black, 3 if native descent, 4 if asian, 5 if unknown
tab race, missing
* sex = 2 (females only)
tab sex, missing
* number of kids should be 1 or more (mothers only)
tab numkids, missing
* age at interview should be 306 to 366 (1965-1970 birth cohort)
tab ageint, missing
* age at first birth should be a value
tab age1st, missing
* age at second birth may be missing
tab age2nd, missing

* there is no case id, so create one
egen id = fill(1 2)

* create a dummy variable for whether a second birth occurred
generate birth2 = 9
replace birth2 = 1 if age2nd>100 & age2nd<600
replace birth2 = 0 if age2nd==.
tab birth2, missing

* create dummy variables for the race and ethnic categories
* hispanic:

generate hispanic = 9
replace hispanic = 1 if hspnon==1
replace hispanic = 0 if hspnon==2
tab hispanic
generate nhblack = 9
replace nhblack = 1 if race==2 & hspnon==2
replace nhblack = 0 if hspnon==1 | race==1 | race==3 | race==4 | race==5
tab nhblack
generate nhother = 9
replace nhother = 1 if race>=3 & hspnon==2
replace nhother = 0 if hspnon==1 | race<3
tab nhother
sort race
by race: tab nhblack nhother
by race: tab hispanic
sort hspnon
by hspnon: tab hispanic

* create a variable for interval from first birth to second or interview

generate dur = 999
replace dur = age2nd - age1st if birth2==1
replace dur = ageint - age1st if birth2==0

tab dur, missing

* create categories for age at first birth le19,ge20
generate age1teen = -9
replace age1teen = 1 if age1st < 240 & age1st >= 0
replace age1teen = 0 if age1st >= 240 & age1st <= 888

* first, tell STATA which is the duration, which is the event, and which is the id
stset dur, fail(birth2) id(id)

* life table of second birth intervals
ltable dur birth2 if(dur>0), interval(0,9,21,33,69,129)

* separate estimates by age at first birth
ltable dur birth2 if(dur>0), by(age1teen) interval(0,9,21,33,69,129)

* add hazard intervals
ltable dur birth2 if(dur>0), by(age1teen) hazard interval(0,9,21,33,69,129)

* graph results
sts graph, by(age1teen)

* calculate the event rate for the overall sample and by age groups at first birth
strate
strate age1teen

* now, we are ready for a regression-style model
* use a cox model to automatically control for duration
stcox age1teen hispanic nhblack nhother

* if you are interested in a particular duration, you must make your own
* duration variables and interactions

stsplit durcat, at(9 27 73)
egen durgroup = group(durcat)
gen dur0008 = durgroup==1
gen dur0926 = durgroup==2
gen dur2772 = durgroup==3
gen dur73p  = durgroup==4

generate teen0008 = age1teen*dur0008
generate teen0926 = age1teen*dur0926
generate teen2772 = age1teen*dur2772
generate teen73p = age1teen*dur73p

* then STATA allows you to control your own duration variables and interactions
streg age1teen hispanic nhblack nhother, dist(exp)
streg age1teen hispanic nhblack nhother dur0008 dur0926 dur73p, dist(exp)
streg age1teen hispanic nhblack nhother dur0008 dur0926 dur73p /*
*/ teen0008 teen0926 teen73p, dist(exp)
