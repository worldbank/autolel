/*====================================================================
Project:      AUTO LEL -- Dat-Ravallion Decompostion
Author:      Natalia Garcia-Peña
Dependencies:  The World Bank
----------------------------------------------------------------------
Creation Date:          05 Jun 2017
Modifiacation Date:     01 Oct 2018
Do-File Version:        01
References:			Dat-Ravallion decomposes changes in poverty between growth and redistribution components         
====================================================================*/

program define autolel_drd, rclass

syntax, [ country(string) iso(numlist) year1(numlist) year2(numlist) /*pl(numlist)*/] // N: See if pl can be optional, or just place all lines for now)	

noi di in white "Running Dat-Ravallion Decomposition: `country'"
local country = upper("`country'")
local countryiso3 = `iso'

*Matrix for results
tempname _results

*Matrix to store results
tempname _main_mat_drd
 
* local plines05  "125 250 400 1000 5000"
local plines11  "190 320 550 1300 7000"
local fgts "0 1 2"
local ppps "11"

foreach ppp of local ppps {
	foreach pl of local plines`ppp' {
		foreach fgt of local fgts {
			drdecomp ipcf_ppp`ppp' [w=pondera] , by(year) varpl(lp_`pl'usd_ppp) ind(fgt`fgt')
			mat `_results' = r(b)
			noi mat list `_results'
			local growth	= `_results'[1,3]
			local redis 	= `_results'[2,3]
			local total		= `_results'[3,3]
			
			*Matrix columns: Country Year1 Year2 Pline Indicator(fgt0..) Component Rate
			mat `_main_mat_drd' = nullmat(`_main_mat_drd')  \ (`countryiso3',  `year1', `year2', `pl',`fgt', 0,`growth')      /*
							*/  \ (`countryiso3',  `year1', `year2', `pl',`fgt', 1,`redis')  /*
							*/  \ (`countryiso3',  `year1', `year2', `pl',`fgt', 2,`total')		
							
*************************************			
			*For LAC and subregions:
			
			tempvar _region
			gen `_region'=.
			
			if (upper("`country'") == "LAC") {
				drdecomp ipcf_ppp`ppp' [w=pondera], by(year) varpl(lp_`pl'usd_ppp) ind(fgt`fgt') 
				mat `_results' = r(b)
				local growth 	= `_results'[1,3]
				local redis 	= `_results'[2,3]
				local total	 	= `_results'[3,3]
				mat `_main_mat_drd' = nullmat(`_main_mat_drd')  \ (`countryiso3',  `year1', `year2', `pl',`fgt', 0,`growth')      /*
							*/  \ (`countryiso3',  `year1', `year2', `pl',`fgt', 1,`redis')  /*
							*/  \ (`countryiso3',  `year1', `year2', `pl',`fgt', 2,`total')	
			
			
				***** For subregions
				autolel_defaults `_region', subregion // N: replaces tempvar _region = 1000 (Central America), 1001 (Andean), 1002 (Southern Cone)
				levelsof `_region', local(regions)
				foreach region of local regions {
					drdecomp ipcf_ppp`ppp' [w=pondera] if `_region' == `region', by(year) varpl(lp_`pl'usd_ppp) ind(fgt`fgt') 
					mat `_results' = r(b)
					local growth 	= `_results'[1,3]
					local redis 	= `_results'[2,3]
					local total	 	= `_results'[3,3]
					mat `_main_mat_drd' = nullmat(`_main_mat_drd')  \ (`region',  `year1', `year2', `pl',`fgt', 0,`growth')      /*
							*/  \ (`region',  `year1', `year2', `pl',`fgt', 1,`redis')  /*
							*/  \ (`region',  `year1', `year2', `pl',`fgt', 2,`total')		
				}				
			}
		}
	}		
}
duplicates drop
capture return matrix _main_mat_drd = `_main_mat_drd'

*Temp
* mat Hola = nullmat(Hola) /// store results
						* \ r(_main_mat_drd)

* noi di in red "drd"				
* mat list Hola						
						

end

exit
/* End of do-file */
><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:
