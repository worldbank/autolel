/*====================================================================
Project:       	AUTO LEL -- HOI - Human Opportunity Index
Author:        	Natalia Garcia Pena
Based on: 		Andrés Castañeda, Viviane Sanfelice, Carlos Felipe Balcazar
Creation Date:         November 2019
Modifiacation Date:     
Do-File Version:        01         
====================================================================*/



program define autolel_dis, rclass
syntax, [ country(string) iso(numlist) year(numlist)] // country can be removed in the future

tempname _main_mat_dis

* Generate opportunities at household level from sedlac variables (current only defined for head of household)

local vars agua elect cloacas internet_casa celular

foreach var of local vars {
	egen `var'hh = total(var), by(id) m
	replace `var'hh = 1 if `var'hh > 1 & `var'hh!=.
}



* Finished primary school for children 12-16 - From Do our children have a chance? WB report 
gen pri2 = (inrange(nivel,2,6)) & inrange(age,12,16)


	* Finished primary school
	forvalues i = 1(1)12 {
		gen edu`i' = 0
		replace edu`i' = 1 if aedu >= `i'
		replace edu`i' = edu`i' if age >= 6+`i'+`aux' | age <= 10+`i'+`aux'
		replace edu`i ' = . if age < 6+`i'+`aux' | age > 10+`i'+`aux'
	}
	
	

*School attendance of children 10 to 14 years old as an additional indicator. - From Do our children have a chance? WB report 

* Secondary attendance
gen secondary = asiste if inrange(edad,10,14)

* Max years of education
replace aedu = 17 if aedu>17 & aedu!=.

* Years of education of hh head
gen aux = aedu if jefe == 1
egen edu_head = total(aux), by(id) miss
drop aux

* Gender of hh head
gen aux = hombre if hhead == 1
egen male_head = total(aux), by(id) miss
label define male_head 0 "Female" 1 "Male"
label values male_head male_head
drop aux

* Dummy two parents in the household
gen aux=conyuge==1
replace aux = . if conyuge == .
egen popmom = total(aux), by(id) miss
drop aux

* Number of children - less than 17 years old
gen cri = .
replace cri = 1 if edad >= 0 & edad <= 16
replace cri = 0 if edad > 16 & edad < .
egen number_childs = total(cri), by(id) miss
drop cri

* Age of child (SACAR - creo que no sirve)
* forvalues i = 0(1)18 {
	* gen _Iedad_`i' = (edad == `i')
* }

gen edad2 = edad^2






/*===============================================================================================
                                  4: HOI and Shapley
===============================================================================================*/
keep if age <19 & age!=.
*------------------------------------4.1: Locals and Covariables ------------------------------------

*Children's max & min age (currently using age<16)
	local min_age = 0
	local max_age = 16

	* Locals for dependent variables (3 different specifications)
	local depvar1 "water elect sewage_1 internet celular" 	// for age range [ 0 -  16]
	local depvar2 " attendance "           					// for age range [10 -  14]
	local depvar3 " pric "               					// for age range [12 -  16]

	* Covariables for sewage_3, water, elect, & school
	global cov1 "yedu_head male male_head lipcf_cte urban popmom number_childs"








capture return matrix _main_mat_dis = `_main_mat_dis'	
