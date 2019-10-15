/*====================================================================
Project:       AUTO LEL -- NINIs
Author:        Natalia Garcia Pena
Dependencies:  The World Bank
----------------------------------------------------------------------
----------------------------------------------------------------------
Creation Date:         April 24th 2019

====================================================================*/

cap program drop autolel_nin
program define autolel_nin, rclass

syntax, [ country(string) year(numlist) iso(numlist) byarea noSUBRegion ] 



* Define groups:
tempname _main_mat_nin
tempvar _emp _school _nini aux
gen `_emp'		= 	(ocupado == 1 & asiste == 0) // Works, doesn't study
gen `_school' 	= 	(ocupado == 0 & asiste == 1) // Studies, doesn't work
gen `_nini' 	= 	(ocupado == 0 & asiste == 0) // NINI


* Age groups
local age_ranges "15,18 15,24 19,24"
foreach age_range of local age_ranges {
	di "age range `age_range'"
}

* Gender
levelsof hombre, local(genders)

local statuses "`_emp' `_school' `_nini'"

gen `aux' = 1
local s_index = 1 // status index

	
foreach status of local statuses {
	local a_index = 1 // age index
	foreach age_range of local age_ranges {
		
		* Total
		sum `aux' [w = pondera] if inrange(edad,`age_range')
		local tot = r(sum)
		sum `aux' [w = pondera] if inrange(edad,`age_range') & `status' == 1
		local share = `r(sum)'/`tot'
		local obs = `r(sum)'
		
		mat `_main_mat_nin' = nullmat(`_main_mat_nin')  \ /// 
		(`iso', `year', `s_index', `a_index', 2 ,`share', `obs')
			
		foreach gender of local genders {
			sum `aux' [w = pondera] if inrange(edad,`age_range') & hombre == `gender'
			local tot = r(sum)
			sum `aux' [w = pondera] if inrange(edad,`age_range') & hombre == `gender' & `status' == 1
			local share = `r(sum)'/`tot'
			local obs = `r(sum)'
			
			mat `_main_mat_nin' = nullmat(`_main_mat_nin')  \ /// 
			(`iso', `year', `s_index', `a_index',`gender',`share', `obs')
			
		}
		local ++ a_index // age index
	} // end age range loop
	local ++ s_index // status index
} // end status loop




cap return matrix _main_mat_nin = `_main_mat_nin'


* drop _all
* local colnames "country year status ages gender share obs"
* mat colnames `_main_mat_lab' = `colnames'
* svmat `_main_mat_lab', n(col)



end

exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


