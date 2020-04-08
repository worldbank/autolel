/*====================================================================
Project:       AUTO LEL -- Calculate Poverty
Author:        Andres Castaneda
Dependencies:  The World Bank
----------------------------------------------------------------------
Creation Date:          22 Aug 2017 
Modifiacation Date:     30 Jan 2018 
Do-File Version:        02
References:
Output:             
====================================================================*/

program define autolel_pov, rclass

syntax, [ country(string) year(numlist) iso(numlist) byarea noSUBRegion ] 

local country = upper("`country'")
local countryiso3 = `iso'

tempname _main_mat_poverty _area_mat_poverty

local povlines05  "125 250 400"
local mclines05   "1000 5000"
local povlines11  "190 320 550"
local mclines11   "1300 7000"

*TEMP ERASEEEE
rename ipcf_ppp11 aux
gen double ipcf_ppp11 = ((ipcf*ipc11_sedlac)/ipc_sedlac)/(ppp11*conversion)
* noi di in red "HOLA AUTOLEL POV 30"
* rename ipcf_ppp11 aux1
* gen ipcf_ppp11  = 1
drop if ipcf_ppp11 ==.

cap noi  {
	foreach ppp in /*"05"*/ "11" {
		local groups ""                     // middle  class thresholds 
		
		foreach l of local povlines`ppp' {
			tempvar h`l' g`l' s`l'
			local groups "`groups' h`l' g`l' s`l'"
			
			* headcount
			gen double `h`l'' = ipcf_ppp`ppp' < lp_`l'usd_ppp if (ipcf_ppp`ppp' != .)
			
			* GAP
			gen double  `g`l'' = 0 if ipcf_ppp`ppp' != .
			replace `g`l'' = (1 - ipcf_ppp`ppp'/lp_`l'usd_ppp) if /// 
			(ipcf_ppp`ppp' < lp_`l'usd_ppp & ipcf_ppp`ppp' != .)
			
			* Severity
			gen double  `s`l'' = 0 if ipcf_ppp`ppp' != .
			replace `s`l'' = (1 - ipcf_ppp`ppp'/lp_`l'usd_ppp)^2 if /// 
			(ipcf_ppp`ppp' < lp_`l'usd_ppp & ipcf_ppp`ppp' != .)
			
			local thd = `l' // threshold N: Only for last one so it serves a threshold for middle class lines in next section
		}
		
		foreach mline of local mclines`ppp' {
			tempvar h`thd'`mline'
			
			local groups "`groups' h`thd'`mline'"
			gen double `h`thd'`mline''  = (ipcf_ppp`ppp' >= lp_`thd'usd_ppp  & ///
			ipcf_ppp`ppp' < lp_`mline'usd_ppp)
			local thd = `mline' // threshold // NATALIA DOUBLE
		}
		
		foreach group of local groups {
			local pl = substr("`group'", 2, .)
			
			if      substr("`group'", 1, 1) == "h" local fgt  = 0 
			else if substr("`group'", 1, 1) == "g" local fgt  = 1
			else                                   local fgt  = 2
			
			// calculate and store results
			sum ``group'' [w=pondera], meanonly
			local pn = r(sum_w)
			local pm = r(mean)*100
			mat `_main_mat_poverty' = nullmat(`_main_mat_poverty')  \ ///
			(`countryiso3', 99, `year', `pl', `pm'  , `pn', `fgt') // if country is total LAC, it is calculated here. 
			
*************************************			
			*For subregions:
			
			tempvar _region
			gen `_region'=. 
			
			if (upper("`country'") == "LAC") {
				autolel_defaults `_region', subregion // N: replaces tempvar _region = 1000 (Central America), 1001 (Andean), 1002 (Southern Cone)
				levelsof `_region', local(regions)
				foreach region of local regions {
					sum ``group'' if `_region' == `region' [w=pondera], meanonly
					local pn = r(sum_w)
					local pm = r(mean)*100
					mat `_main_mat_poverty' = nullmat(`_main_mat_poverty')  \ /// zone 99 - national
					(`region', 99, `year', `pl', `pm'  , `pn', `fgt')
				}
			}

			** Rural/Urban condition
			
			foreach zone in 0 1 {
				sum ``group'' if urbano == `zone' [w=pondera], meanonly
				local pn = r(sum_w)
				local pm = r(mean)*100
				mat `_main_mat_poverty' = nullmat(`_main_mat_poverty')  \ ///
				(`countryiso3', `zone', `year', `pl', `pm'  , `pn', `fgt')
			}
		} // end of groups loop
	} // end of ppp loop
}
if _rc {
	noi mat list `_main_mat_poverty'
}


capture return matrix _main_mat_pov = `_main_mat_poverty'


end


exit
/* End of do-file */
><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:
