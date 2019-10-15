/*====================================================================
Project:       AUTO LEL -- Poverty Regional Distribution
Author:        Natalia Garcia Pena
Dependencies:  The World Bank
----------------------------------------------------------------------
Creation Date:          April 2019
Modifiacation Date:     
Do-File Version:        01
References:
Output:             
====================================================================*/

program define autolel_reg, rclass
syntax, [country(string) year(numlist) iso(numlist) merge] //  For user command: year1(numlist) year2(numlist) 


* Subregion definition in LAC bins is the same as the dashboard.

tempname _main_mat_reg
tempvar _region

* To be consistent with labels:
recode subregion (1 = 484 "Mexico") (2 = 76 "Brazil") (3 = 1000 "Central America") (4 = 1001 "Andean Region") (5 = 1002 "Southern Cone"), gen(`_region')

local pls 190 320 550
levelsof `_region', local(subregions)
levelsof pais, local(countries)


foreach pl of local pls {
	gen poor`pl' = (ipcf_ppp11 < lp_`pl'usd_ppp) if (ipcf_ppp11 != .)
	
	*Total poor
	sum poor`pl' [w=pondera]  if (ipcf_ppp11 != .)
	local tot_poor = `r(sum)'
	
	mat `_main_mat_reg' = nullmat(`_main_mat_reg') \ (1, 999, `year', `pl',`tot_poor', 100)
	
	* Subregions
	foreach reg of local subregions {
		* For each subregion
		sum poor`pl' [w=pondera]  if (ipcf_ppp11 != .) & `_region' == `reg'
		local n_poor = `r(sum)'
		local share = `n_poor'/`tot_poor'
		
		mat `_main_mat_reg' = nullmat(`_main_mat_reg') \ (1, `reg', `year', `pl',`n_poor', `share')
	}
	
	* Countries
	foreach country of local countries {
		
		autolel_countrylist `country'		
		local countryiso3 = `r(countryiso3n)'
		noi di in white "autolel_reg line 51: year `year' - country `country' countryiso3 `countryiso3' ERASE"	
		* For each subregion
		sum poor`pl' [w=pondera]  if (ipcf_ppp11 != .) & pais == "`country'"
		local n_poor = `r(sum)'
		local share = `n_poor'/`tot_poor'
		
		mat `_main_mat_reg' = nullmat(`_main_mat_reg') \ (2, `countryiso3', `year', `pl',`n_poor', `share')
	}
	
	
}

* if ("`calc'" == "reg") local colnames "type indicator country year pline n_poor share"

cap return matrix _main_mat_reg = `_main_mat_reg'



end
exit
