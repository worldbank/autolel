/*====================================================================
Project:       AUTO LEL -- Shared prosperity
Author:        Natalia Garcia Pena built on Carlos Felipe Balcazar
Dependencies:  The World Bank
----------------------------------------------------------------------
Creation Date:          09 Sept 2016
Modifiacation Date:     11 Feb 2017 (Changed quantiles to global commands)
Do-File Version:        01
References:
Output:             
====================================================================*/


program define autolel_shp, rclass
syntax, [ country(string) year1(numlist) year2(numlist) iso(numlist)]  	

tempname _main_mat_shp

preserve 
if ("`country'" != "lac") collapse ipcf_ppp11 (sum) pondera,  by(year id)

foreach i of numlist 1 2 {
		tempvar b40`i'
		b40 ipcf_ppp11 [aw=pondera] if year==`year`i'', generate(`b40`i'') 
		
		sum ipcf_ppp11 [aw=pondera] if `b40`i''==1 , meanonly
		local b`i'=r(mean)
		sum ipcf_ppp11 [aw=pondera] if year==`year`i'' , meanonly
		local a`i'=r(mean)	
}
restore
		
*Annualized growth rate
loc growth_tot = ((`a2'/`a1')^(1/(`year2'-`year1'))-1)*100
loc growth_bot = ((`b2'/`b1')^(1/(`year2'-`year1'))-1)*100 

mat `_main_mat_shp' = nullmat(`_main_mat_shp') \ (`iso',`year1',`year2',`growth_tot', 0) ///
\ ( `iso', `year1', `year2', `growth_bot' , 1)
				   
				   
capture return matrix _main_mat_shp = `_main_mat_shp'
		
	
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


/* End of do-file */
><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:

