/*====================================================================
Project:       	AUTO LEL -- INQ - Composition of the income distribution by quintile
Author:        	Natalia Garcia Pena
Based on: 		Viviane Sanfelice, Carlos Felipe Balcazar
Creation Date:          November 20 2018 
Modifiacation Date:     
Do-File Version:        01         
====================================================================*/

program define autolel_inq, rclass
syntax, [country(string) year(numlist) iso(numlist) ] // country 

tempname _main_mat_inq

local keepvars "country year quintiles inc_source shq_tot shi_by_q shq_by_i value"

 _ebin ipcf_ppp11 [w=pondera], gen(quintiles) nq(5)
 


sum ipcf_ppp11 [w=pondera], meanonly
local total = `r(sum)'

local incvars "itran ijubi icap" // if we want to add other income sources in the future, or as option

foreach var of local incvars {
	count if `var' == .
	cap drop `var'_ppp11 
	gen `var'_ppp11 = ((`var'*ipc11_sedlac)/ipc_sedlac)/(conversion*ppp11)
	local var_ppp "`var_ppp' `var'_ppp11"
}

local var_ppp "ila_ppp11 `var_ppp'"

*Total and per capita
foreach var of local var_ppp {
	egen double t_`var' = sum(`var'), by(id)
	gen double pc_`var' = t_`var'/miembros
	local pc_vars "`pc_vars' pc_`var'"
}	

egen sumvars = rowtotal(`pc_vars')
* Other income as residual
gen double pc_onlabor = ipcf_ppp11 - sumvars

local pc_vars "`pc_vars' pc_onlabor ipcf_ppp11"		
* Weighted vars for collapse
foreach var of local pc_vars {	
	gen double w_`var' = `var'*pondera
	local w_vars "`w_vars' w_`var'"
}	

collapse (sum) `w_vars', by(quintiles)

* Share of each quintile in total income (shq_tot)
gen double shq_tot = w_ipcf_ppp11/`total'

* Share by quintile: Share of inc source for each quintile's total income (shi_by_q*) 
* Share by income source: Share of quintile's labor income over total labor income (shq_by_i*) 
* Value of income: Sum of labor income in quintile 1 in ppp (value)


* local w_vars "w_pc_ila_ppp11 w_pc_itran_ppp w_pc_ijubi_ppp w_pc_icap_ppp w_pc_onlabor w_ipcf_ppp11"

local i = 1
foreach var of local w_vars {
	gen double shi_by_q`i'  = `var'/w_ipcf_ppp
	sum `var'
	gen double shq_by_i`i' = `var'/ `r(sum)'
	gen double value`i' = `var'
	local last `i'
	local ++i
}
	
keep quintiles shq_tot shi_by_q* shq_by_i* value*

reshape long shi_by_q shq_by_i value, i(quintiles shq_tot) j(inc_source)

drop if inc_source == `last' // drop ipcf as income source
		
gen country = `iso'
gen year = `year'

order `keepvars'
keep `keepvars'

drop if quintiles ==.

mkmat `keepvars', mat(`_main_mat_inq') 
capture return matrix _main_mat_inq = `_main_mat_inq'	


end



*==============================================
*     Auxiliary programs, b40, _ebin, 
*==============================================
/** JPA 20140322 */
/** JPA 20130727 */
cap program drop b40
cap program define b40, rclass sortpreserve
    version 8.0
    syntax varlist(numeric min=1 max=1) [pweight fweight aweight] [if] [in], [ noisily generate(string)]
    tempvar tmp touse wgt
    local var `varlist'

    quietly {

         if ("`weight'" == "") {
             gen `wgt' = 1
             local weight1 `wgt'
             local weight "[fw=`wgt']"
         }
         else {
             local weight  "[`weight' `exp']"
             local weight1 = subinstr("`exp'","=","",.)
         }
         if ("`if'" == "") {
             local if2 " if (`var'!=.) & (`weight1'!=.) "
         }
          if ("`if'" != "") {
             local if2 " `if'  & (`var'!=.) & (`weight1'!=.) "
         }

         gen `touse' = 1 `in' `if2'

        _ebin `var' `if2'  `weight', gen(`tmp') nq(10)

        `noisily' sum  `var' `weight' if `touse' == 1
        local r1 = r(mean)
        local n1 = r(N)
        local s1 = r(sum)
        `noisily' sum  `var' `weight' if `touse' == 1 & `tmp' <= 4
        local r2 = r(mean)
        local n2 = r(N)
        local s2 = r(sum)
        `noisily' sum  `var' `weight' if `touse' == 1 & `tmp' > 4
        local r3 = r(mean)
        local n3 = r(N)
        local s3 = r(sum)

        return local mean = `r1'
        return local Nmean = `n1'
        return local Smean = `s1'

        return local b40  = `r2'
        return local Nb40  = `n2'
        return local Sb40  = `s2'

        return local t60  = `r3'
        return local Nt60  = `n3'
        return local St60  = `s3'

        `noisily' tab `tmp'

		if ("`generate'" != "") {
			gen `generate' = 1  if `touse' == 1 & `tmp' <= 4
			replace `generate' = 0 if `touse' == 1 & `tmp' > 4
		}

    }
end
*! version 0.1          < 24march2012>         JPAzevedo

cap program drop _ebin

    program define _ebin, rclass sortpreserve

   		version 8.0

        syntax varlist(numeric min=1 max=1) ///
                     [if] [in]       ///
                     [pweight fweight aweight] , ///
                     NQuantiles(string)  ///
                     GENerate(string) ///
                     [order(varname)]

        quietly {

            tempvar var touse rank1 rank2 rank3 rank4 wgt

            local nq `nquantiles'
            local var `varlist'

            if ("`weight'" == "") {
                gen `wgt' = 1
                local weight1 `wgt'
                local weight "[fw=`wgt']"
            }
            else {
                local weight  "[`weight' `exp']"
                local weight1 = subinstr("`exp'","=","",.)
            }

            if ("`order'" != "") {
                local iforder  " & (`order'!=.)"
            }

            if ("`if'" == "") {
                local if2 " if (`var'!=.) & (`weight1'!=.) `iforder'"
            }
             if ("`if'" != "") {
                local if2 " `if'  & (`var'!=.) & (`weight1'!=.) `iforder'"
            }

* 			mark `touse' `in' `if'
            gen `touse' = 1 `in' `if2'

            if ("`order'" != "") {
                _pecats `order'
                if (`r(numcats)' < `nq') {
                    di as err "number of bins can not greater than the number of available categories."
                    exit 198

                }
            }

            if ("`order'" == "") {
                sort `touse' `var' `weight1', stable
            }
            else {
                sort `touse' `order' `weight1' `var', stable
            }

            gen double `rank1'  = `weight1' in 1 if `touse'
			
			replace `rank1'     = `rank1'[_n-1]+`weight1'[_n]   in 2/l

			sum `weight1'                                                   if `touse' == 1
            gen double `rank2' = `rank1'/`r(sum)'							if `touse' == 1
            gen double `rank3' = `rank2'*`nq'                               if `touse' == 1
            gen double `rank4' = int(`rank3')								if `touse' == 1
            replace `rank4' = `nq'-1                                        if `rank4' >= `nq'  & `touse' == 1	
            replace `rank4' = `rank4'+1										if `touse' == 1			

            gen double `generate' = `rank4'                                 if `touse' == 1

    }

end


*********************************************
*! version 1.6.8 12/17/00
capture program drop _pecats
program define _pecats, rclass
    version 6.0
    tempname refval valnum rcount
    scalar `refval' = -999
    syntax [varlist(max=1 default=none)] [if] [in]
* only return values for models with categorical outcomes
    if "`varlist'" == "" & ( /*
    */ "`e(cmd)'"!="logit"    &  /*
    */ "`e(cmd)'"!="logistic" &  /*
    */ "`e(cmd)'"!="probit"   &  /*
    */ "`e(cmd)'"!="cloglog"  &  /*
    */ "`e(cmd)'"!="ologit"   &  /*
    */ "`e(cmd)'"!="oprobit"  &  /*
    */ "`e(cmd)'"!="mlogit"   &  /*
    */ "`e(cmd)'"!="gologit"  &  /*
    */ "`e(cmd)'"!="clogit"   &  /*
    */ ) {
        if "`e(cmd)'"=="tobit" /*
        */ | "`e(cmd)'"=="intreg" /*
        */ | "`e(cmd)'"=="cnreg" /*
        */ | "`e(cmd)'"=="regress" /*
        */ | "`e(cmd)'"!="poisson" /*
        */ | "`e(cmd)'"!="nbreg" /*
        */ | "`e(cmd)'"!="zip" /*
        */ | "`e(cmd)'"!="zinb"    {
            return scalar numcats = 2
        }
        exit
    }

    * numeric value of reference category of mlogit
    if "`e(cmd)'"=="mlogit" { scalar `refval' = e(basecat) }

    * determine names and values of outcome categories
    local catnms ""
    if "`varlist'" != "" {
        local lhs `varlist'
        quietly tabulate `1' `if' `in', matrow(`valnum') matcell(`rcount')
    }
    if "`varlist'" == "" {
        local lhs "`e(depvar)'"
        quietly tabulate `e(depvar)' if e(sample)==1, matrow(`valnum') matcell(`rcount')
    }
    local nrows = rowsof(`valnum')

    * grab value labels
    local vallbl : value label `lhs'
    local i = 1
    while `i' <= `nrows' {
        local vali = `valnum'[`i',1]

        * if value labels have been declared
        if "`vallbl'" != "" {
            local valnm : label `vallbl' `vali'
            if "`valnm'" == "" { local valnm = `vali' }
            * change blanks to _'s
            local valnm = trim("`valnm'")
            local bloc = index("`valnm'"," ")
            while `bloc' != 0 {
                local bloc = `bloc' - 1
                local bloc2 = `bloc' + 2
                local valnm = trim(substr("`valnm'",1,`bloc') /*
                */ + "_" + substr("`valnm'",`bloc2',.))
                local bloc = index("`valnm'"," ")
            }
            * change :'s to _'s
            local bloc = index("`valnm'",":")
            while `bloc' != 0 {
                local bloc = `bloc' - 1
                local bloc2 = `bloc' + 2
                local valnm = trim(substr("`valnm'",1,`bloc') /*
                */ + "_" + substr("`valnm'",`bloc2',.))
                local bloc = index("`valnm'",":")
            }
            * change {'s to _'s
            local bloc = index("`valnm'","{")
            while `bloc' != 0 {
                local bloc = `bloc' - 1
                local bloc2 = `bloc' + 2
                local valnm = trim(substr("`valnm'",1,`bloc') /*
                */ + "_" + substr("`valnm'",`bloc2',.))
                local bloc = index("`valnm'","{")
            }

        }

        * if no value labels, then use value numbers
        else { local valnm `vali' }

        * change .'s to _'s
        local bloc = index("`valnm'",".")
        while `bloc' != 0 {
            local bloc = `bloc' - 1
            local bloc2 = `bloc' + 2
            local valnm = trim(substr("`valnm'",1,`bloc') /*
            */ + "_" + substr("`valnm'",`bloc2',.))
            local bloc = index("`valnm'",".")
        }


        * if current value is refernce value, store it
        if `vali'==`refval' {
            local refnm `valnm'
            local refval `vali'
        }
        else {
            local catnms  `catnms'  `valnm'
            local catvals `catvals' `vali'

            *handle long label names for catnms8
            if length("`valnm'") > 8 { local valnm = substr("`valnm'", 1, 8) }
            local catnms8 `catnms8' `valnm'
        }
        local i = `i' + 1
    }

    * place reference value at end for mlogit
    if `refval'!=-999 {
        local catnms  `catnms'  `refnm'
        local catvals `catvals' `refval'

        *handle long label names for catnms8
        if length("`refnm'") > 8 { local refnm = substr("`refnm'", 1, 8) }
        local catnms8 `catnms8' `refnm'
    }

    * logit probit clogit for case of 0 vs > 0
    if "`varlist'"=="" & /*
    */ ("`e(cmd)'"=="logit" | "`e(cmd)'"=="probit" | "`e(cmd)'"== "clogit" | "`e(cmd)'"=="cloglog" ) /*
        */ & `nrows'~=2 {
            local catnms 0 ~0
            local catvals 0 ~0
            local catnms8 0 ~0
    }

    *number of categories as catnum
    local numcats : word count `catnms'

    *return information about reference category if mlogit
    if "`varlist'"=="" & "`e(cmd)'" == "mlogit" {
        return scalar refval =`refval'
        return local refnm "`refnm'"
    }

    return local catnms  "`catnms'"
    return local catvals "`catvals'"
    return local catnms8 "`catnms8'"
    return scalar numcats = `numcats'

end


exit



/* End of do-file */
><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


































end
exit









tempvar  _qtile
foreach inc_var in ila itran ijubi icap ionl renta_imp { 
	tempvar  `inc_var'_ppp
	tempvar  `inc_var'_ppp_t
	tempvar  `inc_var'_ppp_pcf
	* Deflating
	qui: gen ``inc_var'_ppp' = ((`inc_var'*ipc05_sedlac)/ipc_sedlac)/(conversion*ppp05)
	qui: replace ``inc_var'_ppp' = 0 if ``inc_var'_ppp' == .
	if "`inc_var'"!="renta_imp" {
		* Totals at the household level
		egen ``inc_var'_ppp_t' = sum(``inc_var'_ppp') if hogarsec==0, by(id)
		* Convert to per capita terms
		qui gen double ``inc_var'_ppp_pcf' = ``inc_var'_ppp_t'/miembros
	}
	else {
		qui gen double `renta_imp_ppp_pcf' = `renta_imp_ppp'/miembros
	} // end of else condition
} // end of income loop

* Keep if consistent obervation
keep if cohh==1 & ipcf!=.

qui quantiles ipcf_ppp11 [w=pondera] , n(5) gen(`_qtile') stable

qui: sum ipcf_ppp11 [w=pondera]
local total = `r(sum)'

forvalues iii=1/5 {
	qui: sum ipcf_ppp11 [w=pondera] if `_qtile'==`iii'
	local total`iii' = `r(sum)' 
}

local nvar = 0
foreach inc_var in ila itran ijubi icap ionl renta_imp {	
	local ++nvar
	qui: sum ``inc_var'_ppp_pcf' [w=pondera]
	local total_`inc_var'_ppp_pcf = `r(sum)'
	local p_`inc_var'_ppp_pcf=`total_`inc_var'_ppp_pcf'/`total'*100
	forvalues iii=1/5 {
		qui: sum ``inc_var'_ppp_pcf' [w=pondera] if `_qtile'==`iii'
		local p_ppp_pcf_q`iii' = `total`iii''/`total'*100
		local p_`inc_var'_ppp_pcf_q`iii' = `r(sum)'/`total_`inc_var'_ppp_pcf'*100
		local p_`inc_var'_ppp_pcf_q`iii'2 = `r(sum)'/`total`iii''*100
		mat _main_mat_inequality_source = nullmat(_main_mat_inequality_source) \ ///
		(`countryiso3', `year', `iii', `p_ppp_pcf_q`iii'', `p_`inc_var'_ppp_pcf', ///
		`p_`inc_var'_ppp_pcf_q`iii'', `p_`inc_var'_ppp_pcf_q`iii'2', `nvar')
	} // end of income group loop
} // end of income loop

return matrix _main_mat_inq = _main_mat_inequality_source

end








** Back up


program define autolel_inq, rclass
syntax, [ country(string) year(numlist) iso(numlist) ]

tempname _main_mat_inq

local keepvars ""

set seed 1234
quantiles ipcf_ppp11 [w=pondera] , n(100) gen(quintiles) keeptog(id)
drop if quintiles == .

sum ipcf_ppp11 [w=pondera], meanonly
local total = `r(sum)'

local incvars "itran ijubi icap"

foreach var of local incvars {
	qui: gen `var'_ppp11 = ((`var'*ipc11_sedlac)/ipc_sedlac)/(conversion*ppp11)
	local var_ppp "`var_ppp' `var'_ppp11"
}

local var_ppp "`var_ppp' ila_ppp11"
*Total and per capita
foreach var in ila_ppp11 itran_ppp11 ijubi_ppp11 icap_ppp11 {
	qui: egen double t_`var' = sum(`var'), by(id)
	qui: gen double pc_`var' = t_`var'/miembros
	local pc_vars "`pc_vars' pc_`var'"
}	

gen sumvars =
* Other income as residual
gen double pc_onlabor = ipcf_ppp11 - (pc_ila_ppp11+pc_itran_ppp11+pc_ijubi_ppp11+pc_icap_ppp11)
		
* Weighted vars for collapse
foreach var in ipcf_ppp11 pc_ila_ppp11 pc_itran_ppp11 pc_ijubi_ppp11 pc_icap_ppp11 pc_onlabor {	
	gen double w_`var' = `var'*pondera
}	

collapse (sum) w_ipcf_ppp11 w_pc_ila_ppp11 w_pc_itran_ppp11 w_pc_ijubi_ppp11 w_pc_icap_ppp11 w_pc_onlabor, by(quintiles)

*p_inc_quantile: share of each quintile in total income
gen double shq_tot = w_ipcf_ppp11/`total'


* Share by quintile: Share of inc source for each quintile's total income (shi_by_q*)
* Share by income source: Share of quintile's labor income over total labor income (shq_by_i*)
* Total income: Sum of labor income in quintile 1 in ppp (value)
local nvar 0
foreach var in w_pc_ila_ppp w_pc_itran_ppp w_pc_ijubi_ppp w_pc_icap_ppp w_pc_onlabor {
	local ++nvar
	gen double shi_by_q`nvar'  = `var'/w_ipcf_ppp
	sum `var'
	gen double shq_by_i`nvar' = `var'/ `r(sum)'
	gen double value`nvar' = `var'
}
	
keep quintiles shq_tot shi_by_q* shq_by_i* value*

reshape long shi_by_q shq_by_i value, i(quintiles shq_tot) j(inc_source)
						
		






