/*====================================================================
Project:       AUTO LEL -- Shapley Decomposition by income sources (Barros et al. 2006)
Author:        Natalia Garcia Pena
Dependencies:  The World Bank
----------------------------------------------------------------------
Creation Date:          05 Oct 2018
Modifiacation Date:     07 Feb 2019
Do-File Version:        01
References:
Output:             
====================================================================*/

cap program drop autolel_bde
program define autolel_bde, rclass
syntax, [country(string) iso(numlist) year1(numlist) year2(numlist) eq(string) bdevars(string) pls(numlist) dtype(string)]  // N: See if pl can be optional, or just place all lines for now)	- for future- define eq() and components.

noi di in white "dtype: `dtype' pls: `pls'"


* Defaults:
if "`pls'"=="" local pls "190 320 550" // temp

if "`dtype'"=="" local types "gender incsource"
else local types "`dtype'"
* Decomposition types

* levelsof `dtype', local(types) 

* Create variables
bde_vars, varcreate

* Save appended results
preserve
	drop _all
	tempfile c
	save `c', emptyok
restore

foreach type of local types {
	foreach pl of local pls {

		noi di in white "Running - pov line `pl'"
		if strpos("`type'","gender")!=0 {
			noi di in white "Running adecomp by `type', for pov line `pl'"
			noi adecomp ipcf_ppp11 pocup_man ila_man_ocup pocup_woman ila_woman_ocup  pc_otinla_g  dependency ///
			[w=pondera] , by(year) eq(c6*((c1*c2)+(c3*c4))+c5) varpl(lp_`pl'usd_ppp) in(fgt0 fgt1 fgt2 gini)
			
			
			* Matrix
			mat A = r(b)
			preserve // temp
				drop _all
				svmat double A
				sum A2
				local max = r(max)
				gen type = 1
				gen pline = `pl'
				append using `c'
				save `c', replace
			restore
			
		}
		* By income source
		if strpos("`type'","incsource")!=0 {
			noi di in white "Running adecomp by `type', for pov line `pl'"
		
			noi adecomp ipcf_ppp11 pocup_all ila_all_ocup dependency pc_itranext_ppp11 pc_itrane_ppp11 pc_ijubi_ppp11 pc_otinla_ic  [w=pondera] , by(year) eq((c1*c2*c3)+c4+c5+c6+c7) varpl(lp_`pl'usd_ppp) in(fgt0 fgt1 fgt2 gini) 
			
			* Matrix
			preserve
				mat A = r(b)
				drop _all
				svmat double A
				if strpos("`type'","gender")!=0 {
					replace A2 = A2+`max' // for distinct value labels of components
				}
				else {
					replace A2 =  A2+7
				}
				gen type = 2
				gen pline = `pl'
				append using `c'
				save `c', replace
			restore
		
		}
	}
	
}			

drop _all
use `c'


gen country = `iso'
gen year1 = `year1'
gen year2 = `year2'

local varlist "country year1 year2 type pline A1 A2 A3"

order `varlist'

* Temp matrices not working
* tempname _main_mat_bde
* mkmat `varlist', mat(`main_mat_bde') 
* cap return matrix _main_mat_bde = `main_mat_bde'

local varlist "country year1 year2 type pline A1 A2 A3"
mkmat `varlist', mat(main_mat_bde2) 
* mat list main_mat_bde2
capture return matrix _main_mat_bde = main_mat_bde2	


end


/*====================================================================
project:       Shapley vars
Author:        Natalia Garcia-Peña
Dependencies:  The World Bank
----------------------------------------------------------------------
Creation Date:    02/07/2019
=====================================================================*/

cap program drop  bde_vars
program define bde_vars
syntax, [ labels(string) varcreate incsources(string)]  

qui {
if ("`incsources'"=="") local incsources "itranext itrane ijubi"

if ("`varcreate'"!="") {
	egen itranext = rowtotal(itranext_m itranext_nm), m

	drop if miembros ==.
	gen non_dep=(15<=edad & edad<=69)
		
	* Share of occupied by gender
	gen byte ocupado2=0
	replace ocupado2=1 if (ila_ppp11>0 & ila_ppp11!=.) & non_dep==1
	gen ocup_man = ocupado2 if hombre==1 & non_dep==1
	gen ocup_woman = ocupado2 if hombre==0	& non_dep==1
	gen ocup_all = ocupado2 if non_dep==1
	
	recode ocup_woman .=0  // for hh that does not have male members
	recode ocup_man   .=0  // for hh that does not have female members
	recode ocup_all	  .=0
	

	foreach var in `incsources' {
		cap drop `var'_ppp11
		gen `var'_ppp11 = ((`var'*ipc11_sedlac)/ipc_sedlac)/(conversion*ppp11)
		local incs_ppp "`incs_ppp' `var'_ppp11" // list of non-labor income sources in ppp
	}
		
	* Totals  at the household
	foreach var in ocup_man ocup_woman ocup_all ila_ppp11 non_dep {
	    egen double t_`var' = total(`var') , by(pais year id)
	}
	noi di "incs_ppp: `incs_ppp'"
	
	* Total for other sources of income (to generate local with totals)
	foreach var in `incs_ppp'  {
	    egen double t_`var' = total(`var') , by(pais year id)
		local tot_vars "`tot_vars' t_`var'"
		local minus_tot_vars "`minus_tot_vars' - t_`var'" // for non labor income residual calculation
	}
	*	
		

	
	** Generate Labor income by gender
	egen double t_ila_man_ppp11= total(ila_ppp11) ///
		if (miembros != . & hombre==1 & non_dep==1), by(pais year id)
	egen double t_ila_woman_ppp11= total(ila_ppp11) ///
		if (miembros != . & hombre==0 & non_dep==1), by(pais year id)
	egen double t_ila_all_ppp11= total(ila_ppp11) ///
		if (miembros != . & non_dep==1), by(pais year id)

* Fixes missings (possible dependants who have possitive labor income)
	local genders "man woman all"
	foreach i of local genders {	
		rename t_ila_`i'_ppp11 aux
		egen double t_ila_`i'_ppp11 = mean(aux), by(pais year id)
		replace t_ila_`i'_ppp11 = 0 if t_ila_`i'_ppp11== .   
		drop aux
	}		
		
	* Share of occupied
	
	gen double pocup_man = t_ocup_man/t_non_dep
	gen double pocup_woman = t_ocup_woman/t_non_dep
	gen double pocup_all = t_ocup_all/t_non_dep
	
	************************ Sandra Segovia - Oct 2019
	************************
	replace pocup_all = 0 if t_non_dep == 0    // agregar a autolel
	replace pocup_woman = 0 if t_non_dep == 0    // agregar a autolel
	replace pocup_man = 0 if t_non_dep == 0    // agregar a autolel
	***********************
	***************************
	
	* Labor income from occupied
	gen double ila_man_ocup = t_ila_man_ppp/t_ocup_man
	gen double ila_woman_ocup = t_ila_woman_ppp/t_ocup_woman
	gen double ila_all_ocup = t_ila_all_ppp/t_ocup_all
	
	replace ila_woman_ocup = 0 if  ila_woman_ocup == . // for hh that do not have male members
	replace ila_man_ocup=  0 if  ila_man_ocup == .   // for hh that do not have female members
	replace ila_all_ocup=  0 if  ila_all_ocup == .   
	
	** Other Non labor income - Gender 
	gen double t_otinla_g = ipcf_ppp11*miembros - t_ila_all_ppp11    // otro ingreso no laborales en la poblacion 15-69.


	** Other Non labor income - Income source
	gen double t_otinla_ic = ipcf_ppp11*miembros - t_ila_all_ppp11 `minus_tot_vars'    // otro ingreso no laborales en la poblacion 15-69 (Only labor and non labor components)


	replace t_otinla_g=0 if t_otinla_g<0
	replace t_otinla_ic=0 if t_otinla_ic<0
	
	** Convert in per capita terms
	foreach var in `incs_ppp' otinla_g otinla_ic {    // per capita name
		gen double pc_`var' = t_`var'/miembros
	}  // end of per-capita loop


	gen dependency=t_non_dep/miembros
}


}

end

exit


****************************************



Notes:

Z:\public\Stats_Team\LAC Equity Lab\Dashboards\poverty\2018\release 1\do-files

From: 4.shapley_LAC_lel_genderNdependency.do

Dependency* Portion occupied men * (ila per cccupied man)
adecomp ipcf_ppp11 pocup_man ila_man_ocup pocup_woman ila_woman_ocup  pc_otinla dependency [w=pondera] , by(gyear) eq(c6*((c1*c2)+(c3*c4))+c5) varpl(lp_5usd_ppp) in(fgt0)


From: 4.shapley_LAC_lel15@withoutshare2.do
adecomp ipcf_ppp11 ila_man_pc ila_woman_pc  pc_otinla pc_itran_ppp pc_ijubi_ppp  [w=pondera] , by(gyear) eq(c1+c2+c3+c4+c5) varpl(lp_1usd_ppp) in(fgt0 fgt1 fgt2 gini)

