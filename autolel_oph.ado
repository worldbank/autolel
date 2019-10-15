/*====================================================================
project:       official poverty rates
Author:        Andres Castaneda (Based on Martha Vivero's file)
Dependencies:  The World Bank
----------------------------------------------------------------------
Creation Date:      05 Sep 2017 
Do-file version:    01
References:
====================================================================*/


program define autolel_oph, rclass 

syntax , [countries(string) years(numlist) update ]

qui {
	
	
	if ("`countries'" == "") {
		autolel_countrylist
		local countries = "`r(codeslist)'"
	}
	local countries: subinstr local countries " " "|", all 
	
	if ("`years'" != "") {
		numlist "`years'"
		local years = r(numlist)
		local y1: word 1 of `years'
		local y2: word `: word count `years'' of `years'
		local yearsopt "year(`y1':`y2')"
	}
	else local yearsopt ""
	
	
	wbopendata, indicator(SI.POV.NAHC; SI.POV.RUHC; SI.POV.URHC) ///
	long clear `yearsopt'
	
	** cleaning data
	keep if regexm(countrycode, "`countries'")
	missings dropobs si_pov_*, force
	keep countryname countrycode year si_pov_*
	
	* Reshape Long
	reshape long si_pov_, i(countryname countrycode year) j(area) string
	rename si_pov_ headcount
	label var headcount "Headcount"
	label var area      "Area"
	
	
	* Clean 
	tostring area, replace
	replace area = "Rural"    if area == "ruhc"
	replace area = "Urban"    if area == "urhc"
	replace area = "National" if area == "nahc"
	
	* Auxiliar text variables for tooltip in Tableau 
	gen str unit = "people"
	replace unit = "households" if countrycode == "HND"
	label var unit "Unit"
	
	gen str aux1="."
	replace aux1="in" 	   if area=="Rural" | area =="Urban"
	replace aux1="at the"  if area=="National"
	
	gen str aux2 ="."
	replace aux2 ="areas" if area=="Rural" | area =="Urban"
	replace aux2 ="level" if area=="National"
	
	drop if countrycode == ""
	rename countrycode country
	
	if ("`update'" != "") save "${output_temp}\oph.dta", replace 
}

end

exit
