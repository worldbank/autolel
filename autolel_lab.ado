/*====================================================================
Project:       AUTO LEL -- Labor Market
Author:        Natalia Garcia Pena
Dependencies:  The World Bank
----------------------------------------------------------------------
----------------------------------------------------------------------
Creation Date:         April 01 2019

====================================================================*/

cap program drop autolel_lab
program define autolel_lab, rclass

syntax, [ country(string) year(numlist) iso(numlist) byarea noSUBRegion lfage(string) ] 


if "`lfage'" == "" local lfage "18,65"

tempname _main_mat_lab

* Generate group dummies:
* Poverty
local pls "190 320 550"
foreach pl of local pls {
 	gen _p`pl' = (ipcf_ppp11 < lp_`pl'usd_ppp) if (ipcf_ppp11 != .)
	local pl_groups "`pl_groups' _p`pl'"
}

* BOL has s302a s303b


*B40, Top 60
b40 ipcf_ppp11 [aw=pondera] , generate(_b40) // & pais == "`country'"
gen _t60 = (_b40==0 & ipcf_ppp11 != .)


* Skill level
gen _e201 = (inrange(nivel,0,1))	 // 	Less than primary
gen _e202 = (inrange(nivel,2,3)) 	// 	Primary & less than secondary
gen _e203 = (inrange(nivel,4,6)) 	// 	Secondary
gen _e204 = (nivel==6)			 // 	Tertiary


* Economic sector (primary, manufacturing, construction and utilities, retail and services)
* Some cases sector1d is missing (PRY 2017) so use sector
count if sector1d != .
if r(N) != 0 {
	gen _s301 = (inrange(sector1d,1,3))		// Primary
	gen _s302 = (sector1d==4)				// Manufacturing
	gen _s303 = (inrange(sector1d,5,6))		// Construction and utilities
	gen _s304 = (inrange(sector1d,7,17))  	// Retail Services
}
else {
	cap confirm var sector
	if !_rc {
		count if sector != .
		if r(N)!=0 {
			gen _s301 = (sector == 1)					// Primary
			gen _s302 = (inrange(sector,2,3))			// Manufacturing
			gen _s303 = (inlist(sector,4,6))				// Construction and utilities
			gen _s304 = (sector==5) | (inrange(sector,7,10))  // Retail Services
		}
		else { // Some countries don't have sector defined (BOL 2000)
			gen _s301 = .
			gen _s302 = .
			gen _s303 = .
			gen _s304 = .
		}
	}
}

* Firm size:
gen _f401 = (empresa == 1)			// Small
gen _f402 = (empresa == 2)			// Large
gen _f403 = (empresa == 3)			// Public

* Type of worker:
gen _w501 = (relab == 1) // Employers
gen _w502 = (relab == 2) // Salaried workers
gen _w503 = (relab == 3) // Self-employed
gen _w504 = (relab == 4) // Unsalaried



local groups "`pl_groups' _b40 _t60 _e201 _e202 _e203 _e204"

foreach group of local groups {
	*Group index
	local g_index = substr("`group'",3,.)
	* Unemployment rate
	sum desocupa [w=pondera] if inrange(edad,`lfage') & pea == 1 & `group' == 1 // unemp are econ active
	local rate = r(mean)
	local obs = r(N)
	
	* Total
	sum desocupa [w=pondera] if inrange(edad,`lfage') & pea == 1 // unemp are econ active
	local tot_pop = r(mean)
	mat `_main_mat_lab' = nullmat(`_main_mat_lab')  \ /// 
	(`iso', `year', `g_index',  101 , `rate', `obs',`tot_pop')
	
	
	* Employment rate 
	sum ocupado [w=pondera] if inrange(edad,`lfage') & `group' == 1 // employment is over working age pop
	local rate = r(mean)
	local obs = r(N)
	sum ocupado [w=pondera] if inrange(edad,`lfage') // employment is over working age pop
	local tot_pop = r(mean)
	mat `_main_mat_lab' = nullmat(`_main_mat_lab')  \ /// 
	(`iso', `year', `g_index', 102 , `rate', `obs',`tot_pop')
	
	* Labor force participation
	sum pea [w = pondera] if inrange(edad,`lfage') & `group' == 1
	local rate = r(mean)
	local obs = r(N)
	sum pea [w = pondera] if inrange(edad,`lfage')
	local tot_pop = r(mean)
	mat `_main_mat_lab' = nullmat(`_main_mat_lab')  \ /// 
	(`iso', `year',`g_index', 103  , `rate', `obs',`tot_pop')
	
	
	*****************************************
	* Shares
	local status "_s301 _s302 _s303 _s304 _f401 _f402 _f403 _w501 _w502 _w503 _w504" 
	tempvar aux
	gen `aux' = 1
	
	foreach stat of local status {
		* Total workers in group
		sum `aux' [w = pondera] if inrange(edad,`lfage')  & ocupado == 1  & `group' == 1
		local tot = r(N)
		
		* Total workers in population
		sum `aux' [w = pondera] if inrange(edad,`lfage')  & ocupado == 1
		local tot_pop1 = r(N)
	
		* Share of workers in group
		sum `aux' [w=pondera] if inrange(edad,`lfage') & ocupado == 1 & `group' == 1 & `stat' == 1
		local rate = r(N)/`tot'
		local obs = r(N) 
		
		* Share of workers in total population
		sum `aux' [w=pondera] if inrange(edad,`lfage') & ocupado == 1 & `stat' == 1
		local tot_pop = r(N)/`tot_pop1'

		local s_index = substr("`stat'",3,.)
		mat `_main_mat_lab' = nullmat(`_main_mat_lab')  \ /// 
		(`iso', `year', `g_index', `s_index'  , `rate', `obs',`tot_pop')
	
	}
}

local vars "b40 t60 e201 e202 e203 e204 s301 s302 s303 s304 f401 f402 f403 w501 w502 w503 w504"
foreach var of local vars {
	cap drop _`var'
}

* drop _all
* local colnames "country year group lab_status rate obs"
* mat colnames `_main_mat_lab' = `colnames'
* svmat `_main_mat_lab', n(col)

cap return matrix _main_mat_lab = `_main_mat_lab'

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



