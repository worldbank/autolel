
/*====================================================================
project:       AUTO LEL -- computing inequality
Author:        Andres Castaneda and Carlos Balcazar
Dependencies:  The World Bank
----------------------------------------------------------------------
Creation Date:      Oct 2017 
Do-file version:    02
References:
Output:             
====================================================================*/

program define autolel_ine, rclass
syntax, [ country(string) n_country(numlist) iso(numlist) year(numlist) byarea ] 

local country = upper("`country'")
local countryiso3 = `iso'

quietly {
	
	capture keep if cohh==1 & ipcf!=.
	tempname _main_mat_inequality _nozone_mat_inequality
	tempvar _region
	gen `_region'=.
	if upper("`country'")=="LAC" autolel_defaults `_region', subregion
	else replace `_region' = `countryiso3'
	
	levelsof `_region', local(regions)
	if upper("`country'")=="LAC" local regions "`regions' 999"
	
	local zones "0 1 99"
	
	foreach region of local regions {
		
		if ("`region'" == "999") local regcond ""
		else                     local regcond "`_region' == `region'"
		
		foreach zone of local zones {
			
			if (`zone' == 99) local zonecond ""
			else              local zonecond "urbano == `zone'"
			
			if ("`regcond'" == "" & "`zonecond'" == "") {
				local iff ""
				local and ""
			}
			else if ("`regcond'" != "" & "`zonecond'" != "") {
				local iff "if"
				local and "&"
			}
			else {
				local iff "if"
				local and ""
			}
			
			local condition "`iff' `regcond' `and' `zonecond'"
			count `condition'
			if r(N) == 0 continue		
			
			qui ineqdec0 ipcf_ppp11 [ w=pondera] `condition'
			mat `_main_mat_inequality' = nullmat(`_main_mat_inequality') /*
			*/  \ (`region', `zone', `year', `r(gini)'   , 0 )  /*
			*/  \ (`region', `zone', `year', `r(p90p10)' , 1 )   /*
			*/  \ (`region', `zone', `year', `r(p75p25)' , 2 )
			
			qui ineqdeco ipcf_ppp11 [ w=pondera] `condition'
			mat `_main_mat_inequality' = nullmat(`_main_mat_inequality') /*
			*/  \ (`region', `zone', `year', `r(gem1)'   ,  3 )  	/*
			*/  \ (`region', `zone', `year', `r(ge0)'	   ,  4 ) 	/*
			*/  \ (`region', `zone', `year', `r(ge1)'	   ,  5 ) 	/*
			*/  \ (`region', `zone', `year', `r(ge2)'	   ,  6 ) 	/*
			*/  \ (`region', `zone', `year', `r(ahalf)'  ,  7 ) 	/*
			*/  \ (`region', `zone', `year', `r(a1)'		 ,  8 ) 	/*
			*/  \ (`region', `zone', `year', `r(a2)'		 ,  9 ) 	/*
			*/  \ (`region', `zone', `year', `r(gini)'	 , 10 ) 
			
		} // end of zones loop
	} // end of regions loop
	
	mata {
		A = st_matrix(st_local("_main_mat_inequality"))
		o = select(A, A[.,2]:==99)
		//st_matrix(st_local("_nozone_mat_inequality"), (o[.,1], o[|1,3 \ .,.|]) )
		st_matrix(st_local("_nozone_mat_inequality"), o )
	}
	
	capture return matrix _main_mat_ine = `_main_mat_inequality'
	capture return matrix _nozone_mat_ine = `_nozone_mat_inequality'
	
} // end of qui 

end

exit 

*******************************************************************

tempname A B 
mat `A' = 1, 1, 1 \ 1, 2, 2 \ 1, 3, 3 \ 2, 1, 1 \ 2, 2, 2 \ 2, 3, 3 \ 3, 1, 1 \ 3, 2, 2 \ 3, 3, 3 

mata {
	A = st_matrix(st_local("A"))
	st_matrix(st_local("B"), select(A, A[.,1]:==3))
}


mat list `B'

