/*====================================================================
Project:       	AUTO LEL -- HOI - Human Opportunity Index
Author:        	Natalia Garcia Pena
Creation Date:         November 2019
Modifiacation Date:     
Do-File Version:        01         
====================================================================*/



program define autolel_hod, rclass
syntax, [ country(string) iso(numlist) year(numlist) water(string) elect(string) SEWage(string) INTERnet(string) CELular(string) pric(string) ATTendance(string) spouse(string) male(string) gmd sedlac] // Variables for HOI can be chosen by user, gmd variable names


/*===============================================================================================
                     1. Setting default variables
===============================================================================================*/

/* Natalia: 1/09/2020 - For now use sedlac database, not gmd:
GMD is needed for subnational since we have accurate subnational id variables, but it doesn't have other necessary vars: conjugue, internet */

* Default uses sedlac variables
if "`gmd'" == "" & "`sedlac'" == "" local sedlac "sedlac" 

* Turn locals to globals for easier programming
global water "`water'" 
global elect "`elect'" 
global sewage "`sewage'"
global internet "`internet'" 
global celular "`celular'"
global pric "`pric'"
global attendance "`attendance'"
global aedu "`aedu'"
global spouse "`spouse'"
global male "`male'"

* GMD variable names
if "`gmd'" != "" {
	if "${water}" == "" 	global water "water"
	if "${elect}" == "" 	global elect "electricity"
	if "${sewage}" == "" 	global sewage "cloacas"
	* if "${internet}" == "" global internet 
	if "${celular}" == "" 	global celular "cellphone"
	if "${pric}" == "" 		global pric "primarycomp"
	if "${attendance}" == "" global attendance == "school"
	if "${aedu}" == "" 		global aedu == "educy"
	* if "${spouse}" == "" 	global spouse == "conjugue" // missing in gmd
}	

if "`sedlac'" != "" {
	if "${water}" == "" 	global water "agua"
	if "${elect}" == "" 	global elect "elect"
	if "${sewage}" == "" 	global sewage "cloacas"
	if "${internet}" == "" global internet "internet_casa" 
	if "${celular}" == "" 	global celular "celular"
	* if "${pric}" == "" 		global pric "primarycomp" // doesn't exist in sedlac
	if "${attendance}" == "" global attendance == "asiste"
	if "${aedu}" == "" 		global aedu == "aedu"
	if "${spouse}" == "" 	global spouse == "conjugue" 
}	


/*=======================================================
                 2. Generate variables for HOI
=======================================================*/

* Renaming democraphic variables: (To keep format of previous do files)
**********************************************
cap clonevar year = ano      
cap clonevar country = pais   
cap clonevar hhead = jefe 
cap clonevar weight = pondera 
cap clonevar age = edad

* Gen ipcf_ppp11 when not available
cap gen ipcf_ppp11 = ipcf*(ipc11_sedlac/ipc_sedlac)*(1/ppp11)

* Opportunities variables: Services
**********************************************
* Water:
rename ${water} ${water}_aux
egen ${water} = total(${water}_aux), by(id) miss
replace ${water} = 1 if ${water} > 1 & ${water} < .

* Electricity
egen ${elect}persona = total(${elect}), by(id) miss
ren ${elect} ${elect}hogar
ren ${elect}persona elect
replace ${elect} = 1 if ${elect} > 1 & ${elect} < .
	
* Sewage
rename ${sewage} aux
egen ${sewage} = total(aux), by(id) miss
replace ${sewage} = 1 if ${sewage} > 1 & ${sewage} <.	
drop aux

* Internet
ren ${internet} aux
egen ${internet} = total(aux), by(id) miss
replace ${internet} = 1 if ${internet} > 1 & ${internet} < .
drop aux

* Cellular
ren ${celular} aux
egen ${celular} = total(aux), by(id) miss
replace ${celular}= 1 if ${celular}> 1 & ${celular}< .
drop aux
	
* Progress in school
**************************************
* Some countries have different primary school systems: BRA (76), GTM (320), NIC (558)
if inlist(`country', 76, 320, 558)	local aux = 1
else local aux = 0
	
* Finished primary school
forvalues i = 1(1)12 {
	gen edu`i' = 0
	replace edu`i' = 1 if ${aedu} >= `i'
	replace edu`i' = edu`i' if age >= 6+`i'+`aux' | age <= 10+`i'+`aux'
	replace edu`i ' = . if age < 6+`i'+`aux' | age > 10+`i'+`aux'
}
	
* Secondary attendance
gen secondary = ${attendance}
replace secondary=. if age < 13 | age > 16
	
	
* Circumstances
***************************************
	
* Sex of Child 
cap gen male = hombre

* Years of Education
gen yedu = ${aedu}
replace yedu = 17 if yedu >= 17 & yedu < .

* Years Educ. household head
gen aux = yedu if hhead == 1
egen yedu_head = total(aux), by(id) miss
drop aux

* Sex of Head of Household
gen aux = hombre if hhead == 1
egen male_head = total(aux), by(id) miss
label values male_head hombre_en
drop aux

* Dummy two parents in the house
cap confirm var ${spouse}
if !_rc { // if ${spouse} exists (doesn't exist in gmd)
	gen aux= (${spouse}==1)
	replace aux = . if ${spouse} == .
	egen popmom = total(aux), by(id) miss
	drop aux
}

* Number of children - less than 17 years old
gen cri = .
replace cri = 1 if age >= 0 & age <= 16
replace cri = 0 if age > 16 & age < .
egen number_childs = total(cri), by(id) miss
drop cri

* Income 
gen lipcf_cte = log(ipcf_ppp11)

* Age of child
forvalues i = 0(1)18 {
	gen _Iage_`i' = (age == `i')
}
   gen age2 = age^2

* Ajustments 
replace ${sewage}=. 	if age == .
replace ${water}=. 		if age == . 
replace edu6=. 			if age < 12 +`aux'| age > 16 +`aux'| age == .
replace ${pric}=. 		if age < 12 +`aux'| age > 16 +`aux'| age == .
compress
	
/*=======================================================
                  3. Calculate HOI
=======================================================*/	

postfile `h' str40 cnt str25 country str4 (circa year) str48 indicator obs_indicator double (prob dindex hoi sehoi)  using `hoi', replace	// HOI	

keep if age <19 & age!=.	
	
*Children's max & min age (currently using age<16)
local min_age = 0
local max_age = 16

* Locals for dependent variables (services)
local depvar1 "${water} ${elect} ${sewage} ${internet} ${celular}" 	// for age range [ 0 -  16]
local depvar2 " ${attendance} "   // for age range [10 -  14]
local depvar3 " ${pric} "         // for age range [12 -  16]

* Covariables for sewage, water, elect, & school
global cov1 "yedu_head male male_head lipcf_cte urban popmom number_childs"
	
* Covariables for pric (add dummies for age & age2)
if inlist(`country', 76, 320, 558) global cov2 " _Iage_14 _Iage_15 _Iage_16 _Iage_17 yedu_head male male_head lipcf_cte urban popmom number_childs" 
else global cov2 " _Iage_13 _Iage_14 _Iage_15 _Iage_16 yedu_head male male_head lipcf_cte urban popmom number_childs"

****** 3.1. HOI for Group 1: Services (Water, electricity..)
*****************************************************************

	foreach dep in `depvar1' {	// loop for opportunities group # 1
		disp in red "Calculating for ----> `dep'"
		qui:tab `dep'
		if `r(r)' == 2 {	// loop if opportunity is defined
			
			if "`dep'" == "${water}" local label "Water"
			if "`dep'" == "${elect}" local label "Electricity"
			if "`dep'" == "${sewage}1" local label "Sanitation"
			if "`dep'" == "${internet}" local label "Internet"
			if "`dep'" == "${celular}" local label "Cellular"
			
			*** HOI - All the sample
			
			noi di in red "noi hoi `dep' $cov1 [fw=weight] if age>=`min_age' & age<=`max_age', estim  "
			noi hoi `dep' $cov1 [fw=weight] if age>=`min_age' & age<=`max_age', estim
			noi di in red ``"Estimation successful -----> Continuing with next estimation of `country' in `year' "''
			
			post `h' ("`country'") ("`countryname'") ("`circa'") ("`year'") ("`label'") (`e(N)') (`r(p_1)') (`r(d_1)') (`r(hoi_1)') (`r(se_oi_1)')
							
		}	// end loop if opportunity is defined
	}	// end of loop for opportunities group # 1
	
****** 3.1. HOI for Group 2: School attendance
*****************************************************************	
	foreach dep in `depvar2' {	// loop for opportunities group # 2
		disp in red "Calculating for ----> `dep'"
		qui:tab `dep'
		if `r(r)' == 2 {	// loop if opportunity is defined
			
			*** HOI
			noi di in red "noi hoi `dep' $cov1 [fw=weight] if age>=10 & age<=14 , estim "
			noi  hoi `dep' $cov1 [fw=weight] if age>=10 & age<=14, estim
			noi di in red `"Estimation successful -----> Continuing with next estimation of `country' in `year' "'
			
			post `h' ("`country'") ("`countryname'") ("`circa'") ("`year'") ("School Enrollment") (`e(N)') (`r(p_1)') (`r(d_1)') (`r(hoi_1)') (`r(se_oi_1)')
		

			
		}	// end loop if opportunity is defined
	}	// end of loop for opportunities group # 2
	
****** 3.1. HOI for Group 3: Primary complete
*****************************************************************	
	foreach dep in `depvar3' {	// loop for opportunities group # 3
		disp in red "Calculating for ----> `dep'"
		qui:tab `dep'
		if `r(r)' == 2 {	// loop if opportunity is defined
			if ("`country'" == "bra") | ("`country'" == "gtm") | ("`country'" == "nic") {
			noi di in red "noi hoi `dep' $cov2 [fw=weight] if age>=13 & age<=17 , adjust1(_Iage_14=1 _Iage_15=0 _Iage_16=0 _Iage_17=0) estim "
			noi  hoi `dep' $cov2 [fw=weight] if age>=13 & age<=17 , adjust1(_Iage_14=1 _Iage_15=0 _Iage_16=0 _Iage_17=0) estim
			noi di in red `"Estimation successful -----> Continuing with next estimation of `country' in `year' "'
			}
			
			else {
			noi di in red "noi hoi `dep' $cov2 [fw=weight] if age>=12 & age<=16 , adjust1(_Iage_13=1 _Iage_14=0 _Iage_15=0 _Iage_16=0) estim "
			noi  hoi `dep' $cov2 [fw=weight] if age>=12 & age<=16 , adjust1(_Iage_13=1 _Iage_14=0 _Iage_15=0 _Iage_16=0) estim
			noi di in red `"Estimation successful -----> Continuing with next estimation of `country' in `year' "'
			}
			
			post `h' ("`country'") ("`countryname'") ("`circa'") ("`year'") ("Finished primary School") (`e(N)') (`r(p_1)') (`r(d_1)') (`r(hoi_1)') (`r(se_oi_1)')
			
		
					
		}	// end loop if opportunity is defined
	}	// end of loop for opportunities group # 2
	
	stop
postclose `hoi'
use `h' , clear
compress

	
	
	
	
	
	
