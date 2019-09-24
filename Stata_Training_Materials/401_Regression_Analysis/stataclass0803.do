* file stataclass08032018.do
* STATA commands for getting to know regressions and other simple analyses
* created for the STATA intro to regressions class at Urban Institute, 08/03/2018
* by Smartin, with thanks to Ekalish and Dhanson

* log the results if you wish
* log using "D:\Martin_UI\STATA users group\stataclass0803.log", replace

* first, import a data set:
* the Robert Wood Johnson 2015 County Health Rankings Analytic Data
import delimited "D:\Martin_UI\STATA users group\2015 CHR Analytic Data (2).csv"

* take a look at what we have
summarize

* some of these variable names are quite long, so use a command 
* that does not abbreviate
capture sscinstall fsum
fsum

* county code 0 refers to US states, so drop those
drop if countycode==0

* start with a simple two variable Ordinary Least Squares regression
* does higher air pollution predict more low birthweight babies?
regress lowbirthweightvalue airpollutionparticulatematterval

* maybe we should weight this by the population of each county
regress lowbirthweightvalue airpollutionparticulatematterval /*
*/ [w = populationestimatevalue]

* there are at least three big concerns with regressions which we will mention
* at different points in this activity

* CONCERN 1: unequally influential observations
* OLS assumes extreme values are very rare, and it gets squirrely when it sees them
* so let's try a standard robust variance estimator

regress lowbirthweightvalue airpollutionparticulatematterval /*
*/ [w = populationestimatevalue], vce(robust)

* we will keep this as our simplest regression finding
est store simple

* maybe water pollution is what we should worry about instead of air pollution?
regress lowbirthweightvalue airpollutionparticulatematterval /*
*/ drinkingwaterviolationsvalue /*
*/ [w = populationestimatevalue], vce(robust)

* no need to keep this finding - it was a dead end

* maybe the counties with the most air pollution are simply the poorest
regress lowbirthweightvalue airpollutionparticulatematterval /*
*/ childreninpovertyvalue  medianhouseholdincomevalue /*
*/ [w = populationestimatevalue], vce(robust)

* keep this finding - people might ask about this
est store plusincome

* maybe the counties with the most air pollution have poor access to health care
regress lowbirthweightvalue airpollutionparticulatematterval /*
*/ childreninpovertyvalue  medianhouseholdincomevalue /*
*/ primarycarephysiciansvalue couldnotseedoctorduetocostvalue /*
*/ [w = populationestimatevalue], vce(robust)

* let's keep this finding too
est store plushealthcare

* maybe the counties with the most air pollution also have high black populations
regress lowbirthweightvalue airpollutionparticulatematterval /*
*/ childreninpovertyvalue  medianhouseholdincomevalue /*
*/ primarycarephysiciansvalue couldnotseedoctorduetocostvalue /*
*/ percentofpopulationthatisnonhisp /*
*/ [w = populationestimatevalue], vce(robust)

* keep this
est store plusrace

* maybe the counties with the most air pollution also have systematic differences in behavior
regress lowbirthweightvalue airpollutionparticulatematterval /*
*/ childreninpovertyvalue  medianhouseholdincomevalue /*
*/ primarycarephysiciansvalue couldnotseedoctorduetocostvalue /*
*/ percentofpopulationthatisnonhisp /*
*/ [w = populationestimatevalue], vce(robust)

* definitely keep this
est store plusbehav


* make a table of the analyses we have built up
outreg2 [simple plusincome plushealthcare plusrace plusbehav] using myfile, replace see

* this is too wide, so here is a simpler table of the analyses we have built up
outreg2 [simple plushealthcare plusbehav] using myfile, replace see

* examine the predicted levels of low birth weight at county pollution extremes
* (net of county income, health services, and demographics)
margins, at(airpollutionparticulatematterval=(7 14)) atmeans vsquish

* and why not graph the predicted relationship?
predict plowbirthweightvalue
twoway (scatter plowbirthweightvalue airpollutionparticulatematterval)

* the graph shows evidence of another concern
* CONCERN 2: nonlinear relationships

* one approach: look for non-linearities in the residuals of 
* the main model without pollution,
regress lowbirthweightvalue /*
*/ childreninpovertyvalue medianhouseholdincomevalue/*
*/ primarycarephysiciansvalue uninsuredvalue /*
*/ percentofpopulationthatisnonhisp  percentofpopulationthatishispani /*
*/ teenbirthsvalue somecollegevalue/*
*/ adultsmokingvalue excessivedrinkingvalue physicalinactivityvalue/*
*/ if airpollutionparticulatematterval ~=. [w = populationestimatevalue], vce(robust)
predict plbw1
predict rlbw1, residuals
lowess rlbw1 airpollutionparticulatematterval

* another approach: break the key independent variable into discrete categories

gen airpollutionparticulatematterint = int(airpollutionparticulatematterval)
fvset base 11 airpollutionparticulatematterint

regress lowbirthweightvalue i.airpollutionparticulatematterint /*
*/ childreninpovertyvalue  medianhouseholdincomevalue /*
*/ primarycarephysiciansvalue couldnotseedoctorduetocostvalue /*
*/ [w = populationestimatevalue], vce(robust)

* yet another issue: the possibility of "hot-spots"

* according to summary stats, low birthweight has a sample mean of 8.2%
generate lowbirthweightcounty_yn = .
replace lowbirthweightcounty_yn = 0 if lowbirthweightvalue > 0 & lowbirthweightvalue < .082
replace lowbirthweightcounty_yn = 1 if lowbirthweightvalue >= 0.082 & lowbirthweightvalue < .24

* run the full model on the dichotomous outcome to see if the relationship still shows
logit lowbirthweightcounty_yn airpollutionparticulatematterval /*
*/ childreninpovertyvalue  medianhouseholdincomevalue /*
*/ primarycarephysiciansvalue couldnotseedoctorduetocostvalue /*
*/ percentofpopulationthatisnonhisp, vce(robust)

* according to summary stats, one in 20 counties has more than 12.5% low birthweight

generate vlowbirthweightcounty_yn = .
replace vlowbirthweightcounty_yn = 0 if lowbirthweightvalue > 0 & lowbirthweightvalue < .125
replace vlowbirthweightcounty_yn = 1 if lowbirthweightvalue >= .125 & lowbirthweightvalue < .24

* run the full model on the extreme dichotomous outcome to see if the relationship still shows
logit vlowbirthweightcounty_yn airpollutionparticulatematterval /*
*/ childreninpovertyvalue  medianhouseholdincomevalue /*
*/ primarycarephysiciansvalue couldnotseedoctorduetocostvalue /*
*/ percentofpopulationthatisnonhisp, vce(robust)

* unrelated but useful stuff

* if you want to compare a treatment and a control group values on a continuous variable
* ttesti (Ntreat, meantreat, sdtreat, Ncont, meancont, sdcont)
ttesti 4252 18.1 12.9 6764 32.6 18.2, unequal

* to compare a treatment and a control group values on a categorical variable
* prtesti (Ntreat, ptreat, Ncont, pcont)
prtesti 345 .3536 1900 .1411

* make sure to close the log
* log close
