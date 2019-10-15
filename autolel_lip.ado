/*====================================================================
Project:       AUTO LEL -- LIPI (Labor income poverty index)
Author:        Natalia Garcia Pena
Dependencies:  The World Bank
----------------------------------------------------------------------
Creation Date:          22 Aug 2017 
Modifiacation Date:     30 Jan 2018 
Do-File Version:        02
References:
Output:             
====================================================================*/

program define autolel_lip, rclass

syntax, [ country(string) year(numlist) iso(numlist) merge noSUBRegion ] 

if "`merge'" == "" {
local country = upper("`country'")
local countryiso3 = `iso'

tempname _main_mat_lip

***********************************************************
* Variables and consistency checks for all trimesters
***********************************************************
	keep if ilpc!=.
	keep if miembros!=.
	count
	if `r(N)'==0 {
		noi di in red "`country'-`year': All quarters - Database has no observations"
		exit
	}
	
	sum ila
	if `r(N)' == 0 {
		noi di in red "`country'-`year': ILA has 0 obs - All quarters"
		exit
	}

	
	*Consistency of the compute of labor income 
	*ila_ppp ambiguous abbreviation change for ila_ppp11 
	bysort trimestre id  hogarsec: egen ilf_ppp_tmp= sum (ila_ppp11) if hogarsec==0
	replace ilf_ppp_tmp=. if hogarsec==1
	count if hogarsec==0
	local t=`r(N)'
	gen ilpc_ppp11_tmp=ilf_ppp_tmp/miembros
	count if (abs(ilpc_ppp11_tmp/ilpc_ppp11)>1.01 | abs(ilpc_ppp11_tmp/ilpc_ppp11)<0.99) & (ilpc_ppp11_tmp!=.) & hogarsec==0

	local f_pc=100*`r(N)'/`t' // N: percent of inconsistent income households 
	
	* Number or employed with missing or zero income 
	count if (ila==0 | ila==.) & ocupado==1 & relab!=4 
	local no_cohh=`r(N)'
	count if ocupado==1 & relab!=4 
	local t_oc=`r(N)' 
	local p=100*`no_cohh'/`t_oc'
	
	* Labor income without the people that still have the same issue.
	gen aux_ila_ppp11_wb=1 if (ila==0 | ila==.) & ocupado==1 & relab!=4
	bysort trimestre id ano: egen cohh_wb=total(aux_ila_ppp11_wb)
	drop aux_ila_ppp11_wb
	replace cohh_wb=cohh_wb!=0
	clonevar ilpc_ppp11_wb=ilpc_ppp11
	replace ilpc_ppp11_wb=. if cohh_wb==1 // In past do file they calculated loop for both  ilpc_ppp11_wb and ilpc_ppp11, and then dropped ilpc_ppp11. So now, I use only ilpc_ppp11_wb
*******************************************************************

local povlines11  "190 320 550"

levelsof trimestre, local(quarters)
foreach quarter of local quarters {
	noi di in white "Running autolel_lip `country' -  `year' - `quarter'"
	
	sum ila if trimestre == `quarter'
	if `r(N)' == 0 {
		noi di in red "`country'-`year': ILA has 0 obs - for quarter `quarter'"
		exit
	}
	
	foreach pl of local povlines11 {
	
		apoverty ilpc_ppp11_wb [aw=pondera] if trimestre == `quarter', varpl(lp_`pl'usd_ppp) 
		local rate = `r(head_1)'
		
		mat `_main_mat_lip' = nullmat(`_main_mat_lip') \ (`countryiso3', `year', `quarter', 1, `pl',`rate', `f_pc', `p')
		
	} // END Poverty lines loop
	* Gini
	ineqdeco ilpc_ppp11_wb [aw=pondera] if trimestre == `quarter' 
	* noi di in red "ineqdeco ilpc_ppp11_wb [aw=pondera] if trimestre == `quarter' "
	* ainequal ilpc_ppp11_wb [aw=pondera] if trimestre == `quarter' // not working
	local rate = `r(gini)'
	mat `_main_mat_lip' = nullmat(`_main_mat_lip') \ (`countryiso3', `year', `quarter', 2, 100001,`rate', `f_pc', `p')
	
} // END Quarters

capture return matrix _main_mat_lip = `_main_mat_lip'
}

* Second part of LIPI: Adding base year, and calculating relative index with respect to base year:
if "`merge'"!="" {
	save "Z:\public\Stats_Team\LAC Equity Lab\Auto-LEL\LEL_Ouput\lipi_temp_erase",replace // Temp

	preserve
	tempfile lip_long
	drop _all
	save `lip_long', emptyok 
	restore
	
	sort country year indicator line quarter
	bysort country year indicator line: keep if _n == _N

	levelsof country, local(countries)
	
	foreach country of local countries {
		keep if country == `country'
		tempfile country_1
		save `country_1', replace
		
		levelsof line, local(lines)
		levelsof year, local(years)
		foreach line of local lines {
			foreach year of local years {
				preserve 
				keep country line year rate
				keep if line == `line' & year == `year'
				cap drop base_rate
				cap drop base_year
				rename rate base_rate
				rename year base_year
				merge 1:m country line using `country_1'
				keep if _merge == 3
				drop _merge
				append using `lip_long'
				save `lip_long', replace
				restore
			}
		}
	
	}
	use `lip_long', clear
	gen lipi_index = rate/base_rate
}




end














exit
/* End of do-file */
><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.

Version Control:

mat colnames a = country year quarter line rate consistency inconsistent 
mat a = nullmat(a) \ (`n_c', `year', `n_q', `n_l', `f_pc', `b', `g', `t', `p', `n_lab')
mat colnames a = country year quarter line consistency pov gin the inconsistent sample // this needs to change, so it's already long.


	* bysort country year indicator line: gen n = _n
	* bysort country year indicator line: gen N = _N
	* order n N


	* Merge options:
		levelsof year, local(years)
	* Keep latest available quarter
	sort country year indicator line quarter
	bysort country year indicator line: keep if _n == _N
	
	preserve
	local base_vars "country indicator line year rate"
	keep `base_vars'
	foreach var in year rate {
		rename `var' base_`var'
	}
	tempfile _base
	save `_base', replace
	restore
	
	merge 1:m country indicator line using `_base'
	
	egen group = group(country indicator line)
	
	egen group2 = group(country indicator line base_year)
	
	* Temp
	rename base_year year
	rename base_rate rate

	
	tempfile _base
	save `_base', replace

	
	preserve
		drop group2
		tempfile _base
		save `_base', replace
	restore
	
	drop group
	rename group2 group
	merge 1:1 using `_base'
