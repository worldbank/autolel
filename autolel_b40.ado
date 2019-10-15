
/*====================================================================
project:       AUTO LEL -- countries codes and names
Author:        Carlos Balcazar
modified:      Andres Castaneda and Natalia Garcia Pena
Dependencies:  The World Bank
----------------------------------------------------------------------
Creation Date:      09/SEP/2016
Modification Date:  03/2019
Do-file version:    01
References:
Output:             
====================================================================*/

program define autolel_b40, rclass
syntax, [ country(string) iso(numlist) year(numlist)] 

local country = upper("`country'")
local countryiso3 = `iso'


autolel_b40_vars  // this program is at the end of the file. 
tempname _temp_mat_calc _main_mat_b40

* Keep if consistent observation
cap keep if cohh==1 & ipcf!=.

* Global Stats Team command for generating quantiles
 _ebin ipcf_ppp11 [aw=pondera], generate(_q_tile)  nq(100)

* Global b40 command
b40 ipcf_ppp11 [aw=pondera], generate(b40) 

gen t60 = (b40==0)

* Generate income groups
************************************************
	cap gen lp_0usd_ppp = 0
	local pls 0 190 320 550 1300 7000
	local num : word count `pls'
	tokenize `pls' 
	foreach i of numlist 1/`=`num'-1' {
		local pl = `i'+1
		cap confirm var poor``i''_``pl''
		if !_rc noi di "poor``i''_``pl'' already exists****"
		
		else {
			gen poor``i''_``pl'' = inrange(ipcf_ppp11,lp_``i''usd_ppp, lp_``pl''usd_ppp) if (ipcf_ppp11 != .)
			label define poor``i''_``pl'' 1 "Poor between ``i''-``pl''" 0 "Non-poor ``i''-``pl''", modify
			label values poor``i''_``pl'' poor``i''_``pl''
			
			local pls_ "`pls_' poor``i''_``pl''"
		}
	}
	drop lp_0usd_ppp
***********************************************

* Computing profiles
local iii=0
foreach obs_group in b40 t60 `pls_' {
	local ++iii
	local jjj=0
	foreach obs_charac in age_hh miembros urbano_h female_hh n_children aedu_hh enroll_614 enroll_1524 years_edu ipcf_ppp_d { 
		local ++jjj
		sum `obs_charac' [w=pondera], detail
		if "`obs_charac'"=="ipcf_ppp_d" local tot = `r(p50)'
		if inlist("`obs_charac'","urbano_h","female_hh","enroll_614","enroll_1524") local tot = `r(mean)'*100
		else local tot = `r(mean)'
		
		sum `obs_charac' [w=pondera] if `obs_group'==1, detail
		if "`obs_charac'"=="ipcf_ppp_d" local rate = `r(p50)'
		if inlist("`obs_charac'","urbano_h","female_hh","enroll_614","enroll_1524") local rate = `r(mean)'*100
		else local rate = `r(mean)'
		
		mat `_main_mat_b40' = nullmat(`_main_mat_b40') ///
		\ ( `countryiso3' , `year', `iii', `rate'  , `jjj', `tot')  
	} // end of income group loop
} // end of population group loop

capture return matrix _main_mat_b40 = `_main_mat_b40'

drop age_hh female_hh n_children aedu_hh poor* b40 t60 _q_tile urbano_h enroll_614 enroll_1524 years_edu ipcf_ppp_d

end


program define autolel_b40_vars

* Age of the head of the household
gen age_hh=edad if jefe==1

* Households living with female heads (%)
gen female_hh = (jefe == 1 & hombre == 0) if jefe==1


* Number of children (per household, so if jefe==1)
gen t_n_children=(edad<=14) if edad!=.
bys id: egen n_children = sum(t_n_children)
replace n_children = . if jefe!=1

*Households living in urban areas
gen urbano_h = urbano if jefe==1

* Education of the household head (Check)
gen aedu_hh=aedu if jefe==1

*School enrollment for ages 6-14 (%)
gen enroll_614 = asiste if inrange(edad,6,14)

*School enrollment for ages 15-24 (%)
gen enroll_1524 = asiste if inrange(edad,15,24)

*Years of education (ages 18 and older)
gen years_edu = aedu if edad>=18

*Median daily per capita income (2011 US PPP)
gen ipcf_ppp_d = ipcf_ppp11*12/365 if jefe==1


drop t_n_children

end

/* Note: before 02/11/2019: 		
* set seed 1234
* qui quantiles ipcf_ppp11 [w=pondera], nqua(100) gen(`_pctile`i'') keeptog(id)

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
*********************************************************************************
* Previous way of calculating income groups (Before 04/01/2019)

* 1.9, 
mpovline ipcf_ppp11 [w=pondera], varpl(lp_550usd_ppp) mpl(.34545455 .58181818 1 2.3636364 12.727273) max
tempname _temp_mat_calc _main_mat_b40
mat `_temp_mat_calc' =  r(fgt0)
local epov = `_temp_mat_calc'[1,2] // 1.9
local pov  = `_temp_mat_calc'[2,2] // 3.2
local pov1 = `_temp_mat_calc'[3,2] // 5.5
local vul  = `_temp_mat_calc'[4,2] // Vulnerable
local mid  = `_temp_mat_calc'[5,2] // Middle class
local ric  = `_temp_mat_calc'[6,2] // Rich

gen 	group=1 if _q_tile<=`epov' // below 1.9
replace group=2 if _q_tile>`epov' & _q_tile<=`epov'+`pov' // 1.9 3.2
replace group=3 if _q_tile>`epov'+`pov' & _q_tile<=`epov'+`pov'+`pov1' // 3.2 5.5
replace group=4 if _q_tile>`epov'+`pov'+`pov1' & _q_tile<=`epov'+`pov'+`pov1'+`vul' // 5.5 13
replace group=5 if _q_tile>`epov'+`pov'+`pov1'+`vul' & _q_tile<=`epov'+`pov'+`pov1'+`vul'+`mid' // 13 70
replace group=6 if _q_tile>`epov'+`pov'+`pov1'+`vul'+`mid' //70+
noi di "replace group=6 if _q_tile>`epov'+`pov'+`pov1'+`vul'+`mid' //70+"
tab group, gen(g_)
cap confirm var g_5
if (_rc) {
	tab1 g_*
	noi disp as err "variagle g_5 not found"
	error _rc
}

