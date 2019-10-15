

/*====================================================================
Project:       AUTO LEL -- GIC by income source
Author:        Natalia Garcia Pena
Dependencies:  The World Bank
----------------------------------------------------------------------
Creation Date:          November 15 2018 
Modifiacation Date:     
Do-File Version:        01
References:
Output:             
====================================================================*/


datalib, countr(slv) year(2007) incppp(itranext_m itranext_nm ipcf ila) mod(all) clear

tempfile c
save `c', replace

datalib, countr(slv) year(2017) incppp(itranext_m itranext_nm ipcf ila) mod(all) clear

append using `c', force

stop


local year1 2007
local year2 2017

rename ano year

local keepvars "country year1 year2 percentiles  inc_type total_growth value"



foreach i of numlist 1 2 {
	preserve
		keep if year == `year`i'' // year1 en primer loop 
		
		tempvar  ilatf ilapcf_y`i' ipcf_y`i'
		
		* Per capita labor income
		bysort id: egen `ilatf' = sum(ila_ppp11) // old-erase
		gen `ilapcf_y`i''	= `ilatf' / miembros // ila per capita ppp11 for year i (old-erase)
		
		
		
		 * gen `ilapcf_y`i'' = ila_ppp11
		 
		* ipcf per capita
		gen `ipcf_y`i'' 	=  ipcf_ppp11 // ipcf per capita ppp11 for year i
		
		* Generate deciles
		* set seed 1234
		* quantiles ipcf_ppp11 [w=pondera], n(10) gen(percentiles) keeptog(id) // ERASE
		 _ebin ipcf_ppp11 [w=pondera], gen(percentiles) nq(10)
		 

		collapse (mean) `ipcf_y`i'' `ilapcf_y`i'', by(percentiles)
		drop if percentiles == .
		tempfile inc_y`i'
		save `inc_y`i'', replace
	restore
}

use `inc_y1', clear
merge 1:1 percentiles using `inc_y2', nogen

*Annualized growth rate of per capita family income
gen total_growth = ((`ipcf_y2' / `ipcf_y1')^(1/(`year2'-`year1')) - 1)*100 
	
* Types of income growth:
* Labor income 
gen value1 = ((`ilapcf_y2' / `ilapcf_y1')^(1/(`year2'-`year1')) - 1)*100 

* Non-labor income as residual
gen value2 =  total_growth - value1 // residual ipcf growth - labor income growth

reshape long value, i(percentiles) j(inc_type)

* gen country = `iso'
gen year1 = `year1'
gen year2 = `year2'	

order `keepvars'

mkmat `keepvars', mat(`_main_mat_gis') 

capture return matrix _main_mat_gis = `_main_mat_gis'	   

exit



