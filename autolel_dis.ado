/*====================================================================
Project:       	AUTO LEL -- DIS - Distribution by percentiles
Author:        	Natalia Garcia Pena
Based on: 		Andrés Castañeda, Viviane Sanfelice, Carlos Felipe Balcazar
Creation Date:          November 15 2018 
Modifiacation Date:     
Do-File Version:        01         
====================================================================*/

program define autolel_dis, rclass
syntax, [ country(string) iso(numlist) year(numlist)] // country can be removed in the future

tempname _main_mat_dis

local keepvars "country year percentiles p_share cum_dis group"


quantiles ipcf_ppp11 [w=pondera] , n(100) gen(percentiles) stable // keeptog(id)
* Note: Although quantiles tries to leave the same amount of observations in each bin, the fact that they aren't exactly equal could mean that bins may not be monotonically increasing. Therefore, percentage share (p_share) must be rounded to the first decimal place.

drop if percentiles == .

sum ipcf_ppp11 [w=pondera], meanonly
local totinc = `r(sum)'

tempvar sum_inc mean_inc
gen double `sum_inc' = ipcf_ppp11*pondera

egen double aux_sum = sum(`sum_inc'), by(percentiles)

collapse (sum) `sum_inc' pondera (mean) aux_sum lp* , by(percentiles)


gen double p_share = `sum_inc'/`totinc'*100

gen double `mean_inc' = `sum_inc'/pondera // mean income for each percentile

*Groups
gen group = .
local plines "190 320 550 1300 7000"
foreach pl of local plines {
	replace group = `pl' if ((`mean_inc' < lp_`pl'usd_ppp) & group==.) // So it doesn't replace previous groups
}
replace group = 8000 if group == . // missing ipcf have already been removed

* Comulative distribution
gen double cum_dis = sum(p_share)

gen country = `iso'
gen year = `year'

order `keepvars'
keep `keepvars'

mkmat `keepvars', mat(`_main_mat_dis') 
capture return matrix _main_mat_dis = `_main_mat_dis'	


end
exit




/* End of do-file */
><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:





