/*===========================================================================
project:       Human Opportunity Index dashboard
Author:        Germán Reyes based on 2013's PLB
Dependencies:  World Bank
---------------------------------------------------------------------------
Creation Date:      07/12/2013	
Modification Date:  March, 2016
Output:             database, excelfile
Running time: 18hs
Please see comments on the HOI sub-national do-file for Mexico and Colombia for missing data at the end of the do-file
===========================================================================*/

/*===============================================================================================
                                  1: Setting up paths and globals
===============================================================================================*/

* clear all

* Set paths
glo rootdatalib "S:\Datalib"
glo path "Z:\public\Stats_Team\LAC Equity Lab\Dashboards\hoi\2019_test"
glo dofiles "${path}\do-files"
glo dta "${path}\dta"
glo xls "${path}\excel"
glo xls_name "HOI_all.xlsx"

* Set directory
cd "${path}"

**** locals
levelsof pais, local(country)

* Creation of states
autolel_defaults, reg_represent

local circa1 "2007"
local circa2 "2012"
local circa3 "2017"

local years "2007 2012 2017"
*------------------------------------1.1: Temp files ------------------------------------

tempfile survey hoi hoi_share hoi_sub shapley decomp dta_append
tempname svy h c h_s h_sub s d 

postfile `svy' str10 veralt str10 vermast str10 project str30 survey str30 year str30 acronym str30 country str30 type str30 nature using `survey', replace // Survey Module
postfile `h' str40 cnt str25 country str4 (circa year) str48 indicator - obs_indicator double (prob dindex hoi sehoi)  using `hoi', replace	// HOI
postfile `h_sub' str40 state str25 country str4 (circa year) str48 indicator obs_indicator double (prob dindex hoi sehoi)  using `hoi_sub', replace	// Sub-national HOI

postfile `d' str10 cnt str25 country str12 period str48 indicator obs_indicator str20 estad value using `decomp', replace	// Decomposition of the change of the HOI between 2 years - Circa 2000 and 2014

* Year loop

	local append = 0
	
foreach year of local years {
		local ++append
		di in yellow `"Country: `country' | Year: `year'"'



/*===============================================================================================
                                  3: Variable creation
===============================================================================================*/

*------------------------------------3.1: ${water} and saniation from RAW data ------------------------------------
	* Renaming
	* To keep format of previous do files
	cap clonevar year = ano      
    cap clonevar country = pais   
	cap clonevar hhead = jefe 
	cap clonevar weight = pondera 
	cap clonevar age = edad
	
	
	*HOI variables may have same names as original dataset, so clonevar them - ERASE
	* cap clonevar ${${attendance}}  =  ${${attendance}} 
	* cap clonevar ${water} = ${water} 
	* cap clonevar ${sewage} = ${sewage} 
	* cap clonevar ${elect} = ${elect}
	* cap clonevar ${internet} = ${internet}
	
	

	
*------------------------------------3.2: Opportunities ------------------------------------
	* Opportunities: mobile, school enrolment, electricity, finished primary school, sanitation, ${water}, internet

	* ${water}
	rename ${water} ${water}_aux
	
    egen ${water} = total(${water}_aux), by(id) miss
    replace ${water} = 1 if ${water} > 1 & ${water} < .
    tab ${water}, mis

	* Electricity
    egen ${elect}persona = total(${elect}), by(id) miss
    ren ${elect} ${elect}hogar
    ren ${elect}persona elect
    replace ${elect} = 1 if ${elect} > 1 & ${elect} < .
    tab ${elect}, miss

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

	* Progress in School
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
	
	* primary complete // not used in the rest of do file - replaced by pric
	gen pric2 = 0	
	replace pric2 = 1 if ${aedu} >=6 & ${aedu} !=.

	* Secondary ${attendance}
	gen secondary = ${attendance}
	replace secondary=. if age < 13 | age > 16


		
*------------------------------------3.3: Circumstances ------------------------------------

	* Sex of Child 
	cap gen male = hombre
	label define male 0 "female" 1 "male"
	label values male male
	tab male

	* Years of Education
	gen yedu = ${aedu}
	replace yedu = 17 if yedu >= 17 & yedu < .
	tab yedu, miss

	* Years Educ. household head
	gen aux = yedu if hhead == 1
	egen yedu_head = total(aux), by(id) miss
	drop aux

	* Sex of Head of Household
	gen aux = hombre if hhead == 1
	egen male_head = total(aux), by(id) miss
	label define male_head 0 "female" 1 "male"
	label values male_head male_head
	drop aux
	tab male_head, mis


	* Dummy two parents in the house
	cap confirm var ${spouse}
	if !_rc { // if ${spouse} exists
		gen aux= (${spouse}==1)
		replace aux = . if ${spouse} == .
		egen popmom = total(aux), by(id) miss
		drop aux
		tab popmom, mis
	}

	* Number of children - less than 17 years old
	gen cri = .
	replace cri = 1 if age >= 0 & age <= 16
	replace cri = 0 if age > 16 & age < .
	egen number_childs = total(cri), by(id) miss
	drop cri
	tab number_childs, mis

	* Income 
	gen lipcf_cte = log(ipcf_ppp11)
	
	* Age of child
	forvalues i = 0(1)18 {
		gen _Iage_`i' = (age == `i')
	}
    gen age2 = age^2

	* Ajustes en las variables
	replace ${sewage}=. 			if age == .
	replace ${water}=. 			if age == . 
	replace edu6=. 				if age < 12 +`aux'| age > 16 +`aux'| age == .
	replace ${pric}=. 				if age < 12 +`aux'| age > 16 +`aux'| age == .
	compress


/*===============================================================================================
                                  4: HOI and Shapley
===============================================================================================*/
keep if age <19 & age!=.
*------------------------------------4.1: Locals and Covariables ------------------------------------

	*Children's max & min age (currently using age<16)
	local min_age = 0
	local max_age = 16

	* Locals for dependent variables (3 different specifications)
	local depvar1 "${water} ${elect} ${sewage} ${internet} ${celular}" 	// for age range [ 0 -  16]
	local depvar2 " ${attendance} "           					// for age range [10 -  14]
	local depvar3 " ${pric} "               					// for age range [12 -  16]

	* Covariables for ${sewage}, ${water}, elect, & school
	global cov1 "yedu_head male male_head lipcf_cte urban popmom number_childs"
	
	* Covariables for ${pric} (add dummies for age & age2)
	if ("`country'" == "bra") | ("`country'" == "gtm") | ("`country'" == "nic") global cov2 " _Iage_14 _Iage_15 _Iage_16 _Iage_17 yedu_head male male_head lipcf_cte urban popmom number_childs" 
	else global cov2 " _Iage_13 _Iage_14 _Iage_15 _Iage_16 yedu_head male male_head lipcf_cte urban popmom number_childs"
	
	* Locals for circa (Change in HOI is only made between 2000 and 2014)

	* erase - if `append' == 1  local circa "2000" // First year
	* erase - if `append' == 2  local circa "2012" // Second year
	* erase - if `append' == 3  local circa "2014" // Last year

	* erase - if "`circa'" == "2000" | "`circa'" == "2012" | "`circa'" == "2014" {	

*------------------------------------4.2: Human Opportunity Index (HOI) ------------------------------------
	
*------------------------------------4.3.1: Group 1: ${water} ${elect} ${sewage} ${internet}${celular}------------------------------------

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
	
	
	
*------------------------------------4.3.2: Group 2: School ${attendance} ------------------------------------
	
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

	
*------------------------------------4.3.3: Group 3: primary complete ------------------------------------

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
* } erase


/*===============================================================================================
                                  5: HOI - Subnational level 
===============================================================================================*/


						
*------------------------------------5.2: HOI at state level ------------------------------------
			
			cap tab states	
			if _rc == 0 {
				
				levelsof states, local(states)   
				local asis "asis"
				
				foreach state of local states {
					encode state, 
				* Model specification level

				* Group 1: ${water} ${elect} ${sewage} ${internet}celular

					local lab_states `state'

					noi di in red in y "`lab_states'"
					foreach dep in `depvar1' {	// loop for opportunities group # 1
						disp in red "Calculating for ----> `dep'"
						qui:tab `dep' if age>=`min_age' & age<=`max_age' & state == "`state'"
						local row = `r(r)'

							if "`dep'" == "${water}" local label "Water"
							if "`dep'" == "${elect}" local label "Electricity"
							if "`dep'" == "${sewage}1" local label "Sanitation"
							if "`dep'" == "${internet}" local label "Internet"
							if "`dep'" == "${celular}" local label "Cellular"
							
						if `row' == 2 {	// loop if opportunity is defined
							
							* HOI
							* All the sample
							noi hoi `dep' $cov1 [fw=weight] if age>=`min_age' & age<=`max_age' & state == "`state'", estim `asis'
								
							post `h_sub' ("`lab_states'") ("`countryname'") ("`circa'") ("`year'") ("`label'") (`e(N)') (`r(p_1)') (`r(d_1)') (`r(hoi_1)') (`r(se_oi_1)')	
				
						}

						if `row' == 1 {	// Loop if opportunity is not defined
							
							qui: sum `dep' if age>=`min_age' & age<=`max_age' & state == "`state'"		
							if `r(mean)' == 1 {								
								post `h_sub' ("`lab_states'") ("`countryname'") ("`circa'") ("`year'") ("`label'") (`r(N)') (`r(mean)'*100) (0) (`r(mean)'*100) (0)
							}
						}	// end loop if opportunity is defined
					}	// end of loop for opportunities group # 1
					
					* Group 2: School ${attendance}	
					
					foreach dep in `depvar2' {	// loop for opportunities group # 2
						disp in red "Calculating for ----> `dep'"
						qui:tab `dep' if age>=10 & age<=14 & state == "`state'"
						local row = `r(r)'
						
						if `row' == 2 {	// loop if opportunity is defined
							
							* HOI
							* All the sample
							noi  hoi `dep' $cov1 [fw=weight] if age>=10 & age<=14 & state == "`state'", estim `asis'
							
							post `h_sub' ("`lab_states'") ("`countryname'") ("`circa'") ("`year'") ("School Enrollment") (`e(N)') (`r(p_1)') (`r(d_1)') (`r(hoi_1)') (`r(se_oi_1)')
						}

						if `row' == 1 {	// Loop if opportunity is not defined
							
							qui: sum `dep' if age>=10 & age<=14 & state == "`state'"		
							if `r(mean)' == 1 {								
								post `h_sub' ("`lab_states'") ("`countryname'") ("`circa'") ("`year'") ("School Enrollment") (`r(N)') (`r(mean)'*100) (0) (`r(mean)'*100) (0)
							}	// end loop if opportunity is not defined
						}	// end loop if opportunity is defined
					}	// end of loop for opportunities group # 2

					
					* Group 3: primary complete
					
					foreach dep in `depvar3' {	// loop for opportunities group # 3
						disp in red "Calculating for ----> `dep'"
						qui:tab `dep'
						local row = `r(r)'
						if `row' == 2 {	// loop if opportunity is defined
							if ("`country'" == "bra") | ("`country'" == "gtm") | ("`country'" == "nic") {
							noi  hoi `dep' $cov2 [fw=weight] if age>=13 & age<=17 & state == "`state'", adjust1(_Iage_14=1 _Iage_15=0 _Iage_16=0 _Iage_17=0) estim asis
							}
							
							else {
							noi  hoi `dep' $cov2 [fw=weight] if age>=12 & age<=16 & state == "`state'", adjust1(_Iage_13=1 _Iage_14=0 _Iage_15=0 _Iage_16=0) estim asis
							}
							
							post `h_sub' ("`lab_states'") ("`countryname'") ("`circa'") ("`year'") ("Finished primary School") (`e(N)') (`r(p_1)') (`r(d_1)') (`r(hoi_1)') (`r(se_oi_1)')		
						}

						if `row' == 1 {	// Loop if opportunity is not defined
							
							if ("`country'" == "bra") | ("`country'" == "gtm") | ("`country'" == "nic")  {
								qui: sum `dep' if age>=13 & age<=17 & state == "`state'"		
							}
							else {
								qui: sum `dep' if age>=12 & age<=16 & state == "`state'"	
							}
							if `r(mean)' == 1 {								
								post `h_sub' ("`lab_states'") ("`countryname'") ("`circa'") ("`year'") ("Finished primary School") (`r(N)') (`r(mean)'*100) (0) (`r(mean)'*100) (0)
							}	
						}	// end loop if opportunity is defined
					}	// end of loop for opportunities group # 3
				} // end loop for states
			}
		
		
/*===============================================================================================
                                  6: Decompositions
===============================================================================================*/
			
			* Append years for a given country to calculate Decomposition
			
			keep if inlist(year,`circa1',`circa2')
			if `append' == 1 {
				keep id com country year weight age ${water} ${elect} ${sewage} ${attendance} ${pric} ${internet} ${celular} yedu_head male male_head lipcf_cte urban popmom number_childs _Iage_13 _Iage_14 _Iage_15 _Iage_16 _Iage_17 
				save `dta_append', replace
			}
			
			if `append' == 3 {
				keep id com country year weight age ${water} ${elect} ${sewage} ${attendance} ${pric} ${internet} ${celular} yedu_head male male_head lipcf_cte urban popmom number_childs _Iage_13 _Iage_14 _Iage_15 _Iage_16 _Iage_17 
				append using `dta_append'
			}
				
			*Children's max & min age (currently using age<16)
			local min_age = 0
			local max_age = 16

			* Locals for dependent variables (3 different spcifications)
			local depvar1 "${water} ${elect} ${sewage} ${internet} ${celular}"  // for age range [ 0 -  16]
			local depvar2 " ${attendance} "           // for age range [10 -  14]
			local depvar3 " ${pric} "                 // for age range [12 -  16]

			* Covariance for ${sewage}, ${water}, elect, & school
			global cov1 "yedu_head male male_head lipcf_cte urban popmom number_childs"
			
			* Covariance for ${pric} (add dummies for age & age2)
			if ("`country'" == "bra") | ("`country'" == "gtm") | ("`country'" == "nic") {
				global cov2 " _Iage_14 _Iage_15 _Iage_16 _Iage_17 yedu_head male male_head lipcf_cte urban popmom number_childs"
			}

			else {
				global cov2 " _Iage_13 _Iage_14 _Iage_15 _Iage_16 yedu_head male male_head lipcf_cte urban popmom number_childs"
			}


			* Model specification level

			* Group 1: ${water} ${elect} ${sewage} ${internet}celular
			
			foreach dep in `depvar1' {	// loop for opportunities group # 1
				disp in red "Calculating for ----> `dep'"
				qui:tab year `dep'
				capture local a = `r(r)'
				if _rc != 0 local a = 0
				
				capture local b = `r(c)'
				if _rc != 0 local b = 0
				
				if `a' == 2 & `b' == 2 {	// loop if opportunity is defined
					
					if "`dep'" == "${water}" local label "Water"
					if "`dep'" == "${elect}" local label "Electricity"
					if "`dep'" == "${sewage}1" local label "Sanitation"
					if "`dep'" == "${internet}" local label "Internet"
					if "`dep'" == "${celular}" local label "Cellular"
					
					noi di in red "noi hoi `dep' $cov1 [fw=weight] if age>=`min_age' & age<=`max_age', estim  by(year) decomp2"
					noi hoi `dep' $cov1 [fw=weight] if age>=`min_age' & age<=`max_age', estim by(year) decomp2
					noi di in red `"Estimation successful -----> Continuing with next estimation of `country' in `year' "'
					
					local base: word 2 of `r(byvalues)'
					
					post `d' ("`country'") ("`countryname'") ("`r(byvalues)'") ("`label'") (0) ("Decomp Change pp") (`r(change_`base')')
					post `d' ("`country'") ("`countryname'") ("`r(byvalues)'") ("`label'") (0) ("Composition pp") (`r(composition_`base')')
					post `d' ("`country'") ("`countryname'") ("`r(byvalues)'") ("`label'") (0) ("Scale pp") (`r(scale_`base')')
					post `d' ("`country'") ("`countryname'") ("`r(byvalues)'") ("`label'") (0) ("Equalization pp") (`r(equalization_`base')')
					
				}	// end loop if opportunity is defined
			}	// end of loop for opportunities group # 1

			
			* Group 2: School ${attendance}	
			
			foreach dep in `depvar2' {	// loop for opportunities group # 2
				disp in red "Calculating for ----> `dep'"
				qui:tab year `dep'
				capture local a = `r(r)'
				if _rc != 0 local a = 0
				
				capture local b = `r(c)'
				if _rc != 0 local b = 0
				
				if `a' == 2 & `b' == 2 {	// loop if opportunity is defined
					noi di in red "noi hoi `dep' $cov1 [fw=weight] if age>=10 & age<=14 , estim by(year) decomp2"
					noi  hoi `dep' $cov1 [fw=weight] if age>=10 & age<=14, estim by(year) decomp2
					noi di in red `"Estimation successful -----> Continuing with next estimation of `country' in `year' "'
					
					local base: word 2 of `r(byvalues)'
					post `d' ("`country'") ("`countryname'") ("`r(byvalues)'") ("School Enrollment") (0) ("Decomp Change pp") (`r(change_`base')')
					post `d' ("`country'") ("`countryname'") ("`r(byvalues)'") ("School Enrollment") (0) ("Composition pp") (`r(composition_`base')')
					post `d' ("`country'") ("`countryname'") ("`r(byvalues)'") ("School Enrollment") (0) ("Scale pp") (`r(scale_`base')')
					post `d' ("`country'") ("`countryname'") ("`r(byvalues)'") ("School Enrollment") (0) ("Equalization pp") (`r(equalization_`base')')
				}	// end loop if opportunity is defined
			}	// end of loop for opportunities group # 2

			* Group 3: primary complete
			
			foreach dep in `depvar3' {	// loop for opportunities group # 3
				disp in red "Calculating for ----> `dep'"
				qui:tab year `dep'
				capture local a = `r(r)'
				if _rc != 0 local a = 0
				
				capture local b = `r(c)'
				if _rc != 0 local b = 0
				
				if `a' == 2 & `b' == 2 {	// loop if opportunity is defined
						
					if ("`country'" == "bra") | ("`country'" == "gtm") | ("`country'" == "nic") {
					noi di in red "noi hoi `dep' $cov2 [fw=weight] if age>=13 & age<=17 , adjust1(_Iage_14=1 _Iage_15=0 _Iage_16=0 _Iage_17=0) estim by(year) decomp2 "
					noi  hoi `dep' $cov2 [fw=weight] if age>=13 & age<=17 , adjust1(_Iage_14=1 _Iage_15=0 _Iage_16=0 _Iage_17=0) estim by(year) decomp2
					noi di in red `"Estimation successful -----> Continuing with next estimation of `country' in `year' "'
					}
					
					else {
					noi di in red "noi hoi `dep' $cov2 [fw=weight] if age>=12 & age<=16 , adjust1(_Iage_13=1 _Iage_14=0 _Iage_15=0 _Iage_16=0) estim by(year) decomp2 "
					noi  hoi `dep' $cov2 [fw=weight] if age>=12 & age<=16 , adjust1(_Iage_13=1 _Iage_14=0 _Iage_15=0 _Iage_16=0) estim by(year) decomp2
					noi di in red `"Estimation successful -----> Continuing with next estimation of `country' in `year' "'
					}
					
					local base: word 2 of `r(byvalues)'
					post `d' ("`country'") ("`countryname'") ("`r(byvalues)'") ("Finished primary School") (0) ("Decomp Change pp") (`r(change_`base')')
					post `d' ("`country'") ("`countryname'") ("`r(byvalues)'") ("Finished primary School") (0) ("Composition pp") (`r(composition_`base')')
					post `d' ("`country'") ("`countryname'") ("`r(byvalues)'") ("Finished primary School") (0) ("Scale pp") (`r(scale_`base')')
					post `d' ("`country'") ("`countryname'") ("`r(byvalues)'") ("Finished primary School") (0) ("Equalization pp") (`r(equalization_`base')')
					
				}	// end loop if opportunity is defined
			}	// end of loop for opportunities group # 3
		} // end of loop for years
	* }	// end decomposition
	
* }  	// end loop with the number of countries

*===============================================================================================
*                                  7: Saving Results and Export data
*===============================================================================================*/

* HOI
postclose `h'
use `hoi', clear
duplicates drop
export excel using "${xls}\\${xls_name}", sheet("HOI_raw") sheetreplace first(variable)

* Decomposition
postclose `d'
use `decomp', clear
export excel using "${xls}\\${xls_name}", sheet("HOI_decomps") sheetreplace first(variable)
	
*HOI - Sub-National
postclose `h_sub'
use `hoi_sub', clear
tab state 
if r(N)== 0 set obs 1
export excel using "${xls}\\${xls_name}", sheet("HOI_subnational") sheetreplace first(variable)

exit


/*===============================================================================================
                                  8: Set up for Tableau
								  ******** IMPORTANT ********
								  RUN THIS WITH STATA 13 -> NOT STATA 14! 
===============================================================================================*/



* Set paths
clear all
glo rootdatalib "S:\Datalib"
glo path "Z:\public\Stats_Team\LAC Equity Lab\Dashboards\hoi\2019_test"
glo dofiles "${path}\do-files"
* glo dta "${path}\dta"
glo xls "${path}\excel"
glo xls_name "HOI_all.xlsx"
glo xls_fixed "HOI_fixed.xlsx"

* Set directory
cd "${path}"

clear all
tempfile aux1 aux2 aux3 aux4 

*------------------------------------8.1: HOI ------------------------------------

import excel using "${xls}\\${xls_name}", sheet("HOI_raw") firstrow clear
destring year, replace
drop if cnt == "gtm" & year == 2011
gen Universe = "All"
ren indicator Opportunity
gen Indicator = "HOI" 
replace circa = "2014" if country == "Colombia" & year == 2014
replace country = "Paraguay" if cnt == "pry"
save `aux1', replace
export excel using "${xls}\\${xls_fixed}", sheet("HOI_raw") sheetreplace first(variable)

*------------------------------------8.2: Change in HOI ------------------------------------

import excel using "${xls}\\${xls_name}", sheet("HOI_decomps") firstrow clear
ren indicator Opportunity
ren estad Universe
ren period circa
gen Indicator = "Decomps Change"
replace country = "Paraguay" if cnt == "pry"
save `aux2', replace
export excel using "${xls}\\${xls_fixed}", sheet("HOI_decomps") sheetreplace first(variable)


*------------------------------------8.4: HOI - Subnational ------------------------------------

import excel using "${xls}\\${xls_name}", sheet("HOI_subnational") firstrow clear

replace country = "Argentina - urban" if country == "Argentina"
replace country = "Uruguay - urban" if country == "Uruguay"
destring year, replace
ren indicator Opportunity
tostring circa, replace
gen Indicator = "HOI - Subnational"

save `aux4', replace
export excel using "${xls}\\${xls_fixed}", sheet("HOI_subnational") sheetreplace first(variable)

*------------------------------------8.5: Final editing ------------------------------------

use `aux1', clear
append using `aux2'
append using `aux3'
append using `aux4'

* Renaming 
ren circa Circa
ren country Country
ren year Year
ren value Value
destring Value, replace

replace Opportunity = "Mobile phone" if Opportunity == "Cellular"
replace Universe = "Both parents in household" if Universe == "Presence of Parents"

gen Region = "LAC" if Country != ""
replace Region = Country if state != ""

gen Subregion = Country
replace Subregion = state if state != ""


*===============================================================================================
*                                  9: Spanish translation
*===============================================================================================*/


encode Opportunity, gen(Oportunidades)
label define Oportunidades  1 "Electricidad" 2 "primaria completa" 3 "Internet" 4 "Teléfono móvil" 5 "Saneamiento"  6 "Matrícula Escolar"  7 "Agua", modify

encode Universe, gen(Universo)
label define Universo 1 "Todos" 2 "Presencia de ambos padres" 3 "Efecto de composición" 4 "Cambio de Decomposición" 5 "Efecto de distribución" 6 "Género" 7 "Género jefe del hogar" 8 "Número de hermanos" 10 "Educación de los padres" 11 "Ingreso per cápita" 12 "Efecto de escala" 13 "Urbano o Rural", modify

encode Indicator, gen(Indicador)
label define Indicador 2 "IOH" 3 "IOH-Subnacional" , modify

clonevar IOH = hoi					  
rename coverage Prob
rename prob coverage
clonevar Cobertura = coverage

clonevar Region_es = Region
clonevar Subregion_es = Subregion
clonevar País = Country

foreach reg in Region_es Subregion_es País {
	replace `reg' = "Argentina - urbano" if `reg' == "Argentina - urban"
	replace `reg' = "Brasil" if `reg' == "Brazil"
	replace `reg' = "República Dominicana" if `reg' == "Dominican Republic"
	replace `reg' = "Uruguay - urbano" if `reg' == "Uruguay - urban"
	replace `reg' = "México" if `reg' == "Mexico"
	replace `reg' = "Panamá" if `reg' == "Panama"
	replace `reg' = "Perú" if `reg' == "Peru"
}

order Region Subregion
drop cnt
export excel using "${xls}\dash_data.xlsx", sheet("raw") sheetreplace firstrow(variables)


exit

/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

/*  Country Notes

Chl: didn't have a survey in 2014
Col: Circa 2000, doesn't have hh information
Pan: HOI only for Education outcomes
Dom: 2014 is shady, we use 2013





