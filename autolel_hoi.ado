/*====================================================================
Project:       	AUTO LEL -- HOI - Human Opportunity Index
Author:        	Natalia Garcia Pena
Creation Date:         November 2019
Modifiacation Date:     
Do-File Version:        01         
====================================================================*/



program define autolel_hoi, rclass
syntax, [ country(string) iso(numlist) year(numlist) circa(numlist) water(string) elect(string) SEWage(string) INTERnet(string) CELular(string) pric(string) ATTendance(string) spouse(string) male(string) gmd sedlac subregion troubleshoot] // Variables for HOI can be chosen by user, gmd variable names

* Hoi subprograms: hoi hos hod
/*===============================================================================================
                     1. Setting default variables
===============================================================================================*/

* Natalia: 1/09/2020 - For now use gmd: with no internet


* Creation of states
* autolel_defaults, reg_represent gmd

* TEMP:
* local iso "600" // pry
* local year 2017
* local circa 2017
* local gmd gmd
noi di in white "Running HOI - Ignore WARNING signs"
* Troubleshoot option - either display hoi calc or quietly execute
if "${troubleshoot}" != "" {
	* local qui_ "qui {"
	* local endqui_ "} // end qui"
	local display_ "noi di in red"
	local noi_hoi "noi  hoi"
}
else {
	* local qui_ "*"
	* local endqui_ "*"
	local display_ "qui di"
	local noi_hoi "qui hoi"
}




qui {

* Default uses gmd variables
if "`gmd'" == "" & "`sedlac'" == "" local gmd gmd

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
	if "${water}" == "" 	global water "improved_water" // "water"
	if "${elect}" == "" 	global elect "electricity"
	if "${sewage}" == "" 	global sewage "improved_sanitation" // "cloacas"
	if "${internet}" == "" global internet " " //  missing in GMD pov 
	if "${celular}" == "" 	global celular "cellphone"
	if "${pric}" == "" 		global pric "primarycomp"
	if "${attendance}" == "" global attendance "school"
	if "${aedu}" == "" 		global aedu "educy"
	if "${spouse}" == "" 	global spouse "conyugue" // missing in gmd pov - but is created in this ado file
}	

if "`sedlac'" != "" {
	if "${water}" == "" 	global water "agua"
	if "${elect}" == "" 	global elect "elect"
	if "${sewage}" == "" 	global sewage "cloacas"
	if "${internet}" == "" global internet "internet_casa" 
	if "${celular}" == "" 	global celular "celular"
	if "${pric}" == "" 		global pric "primarycomp" // doesn't exist in sedlac, but is created in this do file
	if "${attendance}" == "" global attendance "asiste"
	if "${aedu}" == "" 		global aedu "aedu"
	if "${spouse}" == "" 	global spouse "conyugue" 
}
	
autolel_defaults, reg_represent `gmd' `sedlac'

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
cap gen double ipcf_ppp11 = ((ipcf*ipc11_sedlac)/ipc_sedlac)/(ppp11*conversion)

* Opportunities variables: Services
**********************************************
* New syntax - in case variable doesn't exist (like internet)
local services "water elect sewage internet celular"
local  aux_var aux_var

foreach var of local services {
if "${troubleshoot}" != "" di "${`var'} "
cap confirm var ${`var'}
	if !_rc {
	if "${troubleshoot}" != "" di in white "${`var'} exists"
		ren ${`var'} `aux_var'
		egen ${`var'} = total(`aux_var'), by(id) miss
		replace ${`var'} = 1 if ${`var'} > 1 & ${`var'} < .
		drop `aux_var'
	}
	if _rc {
		if "${troubleshoot}" != ""  di in red "`var' variable does not exist"
	}
}

	
* Progress in school
**************************************
* Some countries have different primary school systems: BRA (76), GTM (320), NIC (558)
if inlist(`iso', 76, 320, 558)	local aux = 1
else local aux = 0
	
* Finished primary school
forvalues i = 1(1)12 {
	gen edu`i' = 0
	replace edu`i' = 1 if ${aedu} >= `i'
	replace edu`i' = edu`i' if age >= 6+`i'+`aux' | age <= 10+`i'+`aux'
	replace edu`i ' = . if age < 6+`i'+`aux' | age > 10+`i'+`aux'
}

/* Primary complete:
currently doesn't exist in sedlac, and nivel not in gmd, but primarycomp is in GMD*/


if "`sedlac'" != "" {
		cap gen ${pric} = (nivel>=2 & nivel!=.)
}
noi di "local sedlac `sedlac'"
* Both GMD and SEDLAC
cap clonevar pric = primarycomp

	
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
if _rc gen ${spouse} = (relacion == 2)
* if !_rc { // if ${spouse} exists (doesn't exist in gmd)
	gen aux= (${spouse}==1)
	replace aux = . if ${spouse} == .
	egen popmom = total(aux), by(id) miss
	drop aux
* }

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
tempfile hoi
tempname h
postfile `h' country year str48(Opportunity var) obs_indicator double (prob dindex hoi sehoi)  using `hoi', replace	// HOI	

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
if inlist(`iso', 76, 320, 558) global cov2 " _Iage_14 _Iage_15 _Iage_16 _Iage_17 yedu_head male male_head lipcf_cte urban popmom number_childs" 
else global cov2 " _Iage_13 _Iage_14 _Iage_15 _Iage_16 yedu_head male male_head lipcf_cte urban popmom number_childs"

****** 3.1. HOI for Group 1: Services (Water, electricity..)
*****************************************************************

	foreach dep in `depvar1' {	// loop for opportunities group # 1
		noi disp in green "Calculating for ----> `dep'"
		qui:tab `dep'
		if `r(r)' == 2 {	// loop if opportunity is defined
			
			if "`dep'" == "${water}" local label "Water"
			if "`dep'" == "${elect}" local label "Electricity"
			if "`dep'" == "${sewage}" local label "Sanitation"
			if "`dep'" == "${internet}" local label "Internet"
			if "`dep'" == "${celular}" local label "Cellular"
			
			*** HOI - All the sample
			
			`display_' "noi hoi `dep' $cov1 [fw=weight] if age>=`min_age' & age<=`max_age', estim  "
			`noi_hoi' `dep' $cov1 [fw=weight] if age>=`min_age' & age<=`max_age', estim
			`display_' ``"Estimation successful -----> Continuing with next estimation of `country' in `year' "''
			
			post `h' (`iso') (`year') ("`label'") ("`dep'") (`e(N)') (`r(p_1)') (`r(d_1)') (`r(hoi_1)') (`r(se_oi_1)')
							
		}	// end loop if opportunity is defined
	}	// end of loop for opportunities group # 1
	
****** 3.1. HOI for Group 2: School attendance
*****************************************************************	
	foreach dep in `depvar2' {	// loop for opportunities group # 2
		noi disp in green "Calculating for ----> `dep'"
		qui:tab `dep'
		if `r(r)' == 2 {	// loop if opportunity is defined
			
			*** HOI
			`display_' "noi hoi `dep' $cov1 [fw=weight] if age>=10 & age<=14 , estim "
			`noi_hoi' `dep' $cov1 [fw=weight] if age>=10 & age<=14, estim
			`display_' `"Estimation successful -----> Continuing with next estimation of `country' in `year' "'
			
			post `h' (`iso') (`year') ("School Enrollment") ("`dep'") (`e(N)') (`r(p_1)') (`r(d_1)') (`r(hoi_1)') (`r(se_oi_1)')
		

			
		}	// end loop if opportunity is defined
	}	// end of loop for opportunities group # 2


****** 3.1. HOI for Group 3: Primary complete
*****************************************************************	
	foreach dep in `depvar3' {	// loop for opportunities group # 3
		noi disp in green "Calculating for ----> `dep'"
		qui:tab `dep'
		if `r(r)' == 2 {	// loop if opportunity is defined
			if ("`country'" == "bra") | ("`country'" == "gtm") | ("`country'" == "nic") {
			`display_' "noi hoi `dep' $cov2 [fw=weight] if age>=13 & age<=17 , adjust1(_Iage_14=1 _Iage_15=0 _Iage_16=0 _Iage_17=0) estim "
			`noi_hoi' `dep' $cov2 [fw=weight] if age>=13 & age<=17 , adjust1(_Iage_14=1 _Iage_15=0 _Iage_16=0 _Iage_17=0) estim
			`display_' `"Estimation successful -----> Continuing with next estimation of `country' in `year' "'
			}
			
			else {
			`display_' "noi hoi `dep' $cov2 [fw=weight] if age>=12 & age<=16 , adjust1(_Iage_13=1 _Iage_14=0 _Iage_15=0 _Iage_16=0) estim "
			`noi_hoi' `dep' $cov2 [fw=weight] if age>=12 & age<=16 , adjust1(_Iage_13=1 _Iage_14=0 _Iage_15=0 _Iage_16=0) estim
			`display_' `"Estimation successful -----> Continuing with next estimation of `country' in `year' "'
			}
			
			post `h' (`iso') (`year') ("Finished primary School")  ("`dep'") (`e(N)') (`r(p_1)') (`r(d_1)') (`r(hoi_1)') (`r(se_oi_1)')
			
		
					
		}	// end loop if opportunity is defined
	}	// end of loop for opportunities group # 2


****** 4. Create output
*****************************************************************
postclose `h'
use `hoi' , clear
compress
gen Universe = "All"
gen Indicator = "HOI" 
rename prob Coverage

encode Opportunity, gen(Oportunidades)
label define Oportunidades  1 "Celular" 2 "Electricidad" 3 "Primaria completa" 4 "Saneamiento" 5 "Matrícula Escolar"  6 "Agua"  7 "Internet", modify

* encode Universe, gen(Universo)
* label define Universo 1 "Todos" 2 "Presencia de ambos padres" 3 "Efecto de composición" 4 "Cambio de Decomposición" 5 "Efecto de distribución" 6 "Género" 7 "Género jefe del hogar" 8 "Número de hermanos" 10 "Educación de los padres" 11 "Ingreso per cápita" 12 "Efecto de escala" 13 "Urbano o Rural", modify




} // end qui 







end

exit



* TEMP ERASE		

stop 
	
	
	
	
	
