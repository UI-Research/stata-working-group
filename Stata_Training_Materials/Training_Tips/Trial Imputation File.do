
*Set filepath
if c(username) == "kblagg" { // I just learned my username is lower-case :)
	cd "D:\Users\KBlagg\Box Sync\IBP\Projects\101588 - Updating Social Genome Model - CZI\"
}
if c(username) == "smartin" { 
	cd "D:\Users\SMartin\Box Sync\IBP\Projects\101588 - Updating Social Genome Model - CZI\"
}
else if c(username) == "kwerner" {
	cd "D:\Users\KWerner\Box Sync\IBP\Projects\101588 - Updating Social Genome Model - CZI\"
}

use final_matched_data_4_11_2019.dta, replace
*Drop non-matched variable
drop if no_match==1

*Make some changes/fixes to data
gen gpa_above_3_adol_i=1 if gpa_adol_i>300 & gpa_adol_i!=. //Fixed, didn't have . exclusion
replace  gpa_above_3_adol_i=0 if gpa_adol_i<300 

foreach stage in eadol_i adol_i tta_i adt_i {
replace good_health_`stage'=1 if vgood_health_`stage'==1 | excellent_health_`stage'==1
}

drop vgood_health_* excellent_health_* poor_health_* fair_health_*

*Keep model variables
keep *_eadol *_elem *_mc  *_pre  aian /// *_m_y_k *m_k_b *_m_k_y
asiannhpi black bornfirsthalfyr female hispanic mathscore midwest momageatfirstbirth18to24 ///
momageatfirstbirth25over momageatfirstbirthund18 momageatrespbirth18to24 momageatrespbirth25over ///
momageatrespbirthund18 multrace mothered northeast region south twicepovlevel urbanrural west white ///
white_other fem_hispanic male_hispanic fem_black male_black fem_white_other  ///
male_white_other high_grade_mom hh_less_hs hh_hs_ged hh_some_coll hh_ba_plus *eadol_i *_adol_i *_tta_i *_adt_i

*Drop overlapping non-imputed _eadol variables
foreach var of varlist *_eadol {
local label: var label `var'
if regexm("`label'","ECLS")!=1 {
drop `var' 
	}
}

*Remove "_i" imputation codes for NLSY
foreach var of varlist *_i {
local var2=substr("`var'", 1, strlen("`var'")-2)
di "`var2'"
rename `var' `var2'
}

*Make small changes for standardization and for imputation to run
drop enrich_environ_risk_eadol phy_environment_risk_eadol
rename how_much_conflict_partner_adol how_much_cft_ptnr_adol
rename how_much_conflict_partner_tta how_much_cft_ptnr_tta
rename college_degree_chance_adol college_deg_chance_adol
rename college_degree_chance_eadol college_deg_chance_eadol
rename std_physical_enviro_risk_eadol std_phy_enviro_risk_eadol

foreach input of varlist asks_father_advice_* biodadcontact_* cattention_* childeffort_* childhealth_* college_deg_chance_* ///
 csupport_* extbeha_* gpa_* height_inch_* how_close_* how_much_* interestmath_* intbeha_* ///
 interestread_* interpersskills_* parchildrelation_* peerrelations_* posstimmonth_* ///
 posstimbooks_* posstimweek_* psclinvolve_* psupport_*  sclrelation_* selfcontrol_* weight_* {
egen std_`input'= std(`input')
drop `input'
}

drop incomehh_eadol incomehh_elem incomehh_mc


foreach var of varlist fem_white_other  fem_black fem_hispanic male_white_other male_black male_hispanic {   
preserve  
keep if `var'==1

*A variable will not impute for female-Hispanic, too few observations
drop std_how_close_father_adol

*Check that no variables have names >29 characters
foreach var2 of varlist *_eadol *_elem *_mc  *_pre *_adol *_tta *_adt {
if strlen("`var2'")>29 {
di "`var2'"
	}
}

mi set flong
mi register imputed *_eadol *_elem *_mc  *_pre *_adol *_tta *_adt
mi impute chained (regress) *_eadol *_elem *_mc  *_pre *_adol *_tta *_adt, add(5) rseed(5501240) noisily showevery(10)

*Count number of passing T-tests
forvalues iter=1/5 { //However many iterations we have
gen test_group=1 if _mi_m==`iter'
replace test_group=0 if _mi_m!=0 & test_group==.
local test_fails_`iter'=0
local tests_`iter'=0
foreach var3 of varlist *_eadol *_elem *_mc  *_pre *_adol *_tta *_adt {
local tests_`iter'=`tests_`iter''+1
quietly ttest `var3', by(test_group)
if `r(p)'<0.10 { //Fail at 10 percent level
local test_fails_`iter'=`test_fails_`iter''+1
		}
	}
gen test_`iter'=`tests_`iter''
gen test_fail_`iter'=`test_fails_`iter''
drop test_group
}
local name="`var'"
save "Imputation\\`name'_5sets.dta", replace
restore
}


use  "Imputation\\fem_white_other_5sets.dta", clear
foreach name in  fem_black fem_hispanic male_white_other male_black male_hispanic { 
append using "Imputation\\`name'_5sets.dta"
}


foreach var of varlist absent_* finsecure_* foodstamps_* frpl_* healthinsnone_*  ///
		obesity_* tchrturn_* convict_guilt_* arrested_by_* gangs_school_neighbor_* ///
		freq_absent_* food_stamps_* res_afdc_tanf_* smoked_by_* drank_by_* multiple_sex_partners_* ///
		used_marijuana_by_* used_hard_drugs_by_* drank_work_school_* repeat_grade_* ever_repeat_by_* ///
		suspended_* more_5d_suspended_*  obese_* {
*Invert outcomes
gen `var'_iv_a=1-`var' if  _mi_m==0
gen `var'_iv_m=1-`var' if  _mi_m!=0
gen `var'_iv_t=`var'_iv_m if _mi_m!=0
replace `var'_iv_t=0 if `var'_iv_t<0 & _mi_m!=0
replace `var'_iv_t=1 if `var'_iv_t>=1 & `var'_iv_t<. & _mi_m!=0
drop `var'
}

foreach var of varlist bedtime_eadol* biodadhome_* classsize_* exercise_* healthinspriv_* ///
			meals_* ownhouse_* parrelation_* citizen_* good_health_* gifted_transcript_* ///
			volunteered_* regist_vote_* receive_pay_* receive_ba_* curr_married_* twice_pov_lev_* {
*Invert outcomes
gen `var'_a=`var' if _mi_m==0
gen `var'_m=`var' if _mi_m!=0
gen `var'_t=`var' if _mi_m!=0
replace `var'_t=0 if `var'_t<0 & _mi_m!=0
replace `var'_t=1 if `var'_t>=1 & `var'_t<. & _mi_m!=0
drop `var'
}

keep if _mi_m==0 |_mi_m==1 | _mi_m==2
keep absent_* finsecure_* foodstamps_* frpl_* healthinsnone_*  ///
		obesity_* tchrturn_* convict_guilt_* arrested_by_* gangs_school_neighbor_* ///
		freq_absent_* food_stamps_* res_afdc_tanf_* smoked_by_* drank_by_* multiple_sex_partners_* ///
		used_marijuana_by_* used_hard_drugs_by_* drank_work_school_* repeat_grade_* ever_repeat_by_* ///
		suspended_* more_5d_suspended_*  obese_* bedtime_eadol* biodadhome_* classsize_* exercise_* healthinspriv_* ///
		meals_* ownhouse_* parrelation_* citizen_* good_health_* gifted_transcript_* ///
		volunteered_* regist_vote_* receive_pay_* receive_ba_* curr_married_* twice_pov_lev_* _mi_m
		
collapse (mean) absent_* finsecure_* foodstamps_* frpl_* healthinsnone_*  ///
		obesity_* tchrturn_* convict_guilt_* arrested_by_* gangs_school_neighbor_* ///
		freq_absent_* food_stamps_* res_afdc_tanf_* smoked_by_* drank_by_* multiple_sex_partners_* ///
		used_marijuana_by_* used_hard_drugs_by_* drank_work_school_* repeat_grade_* ever_repeat_by_* ///
		suspended_* more_5d_suspended_*  obese_* bedtime_eadol* biodadhome_* classsize_* exercise_* healthinspriv_* ///
		meals_* ownhouse_* parrelation_* citizen_* good_health_* gifted_transcript_* ///
		volunteered_* regist_vote_* receive_pay_* receive_ba_* curr_married_* twice_pov_lev_*, by(_mi_m)

		
