*===============================================================================
* MODULE EXPORT
* This version: 08/MAY/2017 --- Christian Camilo Gomez, based on Carlos Felipe Balcazar autolel_export adofiles.
* Modified by Natalia Garcia Pena (04/02/2019)

cap program drop  autolel_export	
program define autolel_export
syntax, [ byarea module(string) path(string) replace cedlas]  

* qui {
noi di in green "***************** Exporting `module' ******************"
tempfile _module_calc_temp
if ("`cedlas'"!="") {
	
	local form "txt"
	local delim `"delim(";")"'
	local ex_im_type delimited
	local first ""
	local firstvar ""
	
	local varmerge "country year indicator group1 group2"
	if "`module'"=="emp" {
		local varmerge "country year indicator group1 group2 gr"
	}
	
	*saving the temporal file
	
	save `_module_calc_temp'
	
	*confirm if the file exists 

	cap confirm file "${output_LEL}\\`module'_cedlas.dta"	
	if (_rc == 0) {
		
		cap use "${output_LEL}\\`module'_cedlas.dta", clear
		
		if (_rc) {
			noi disp in red "Something went wrong importing the file `module'_cedlas. Please check"
			error
		}
		
		merge 1:1 `varmerge' using `_module_calc_temp', update replace nogen
		cap drop circa
		
	} //  end of condition when file exists
	
	// export results
	save "${output_LEL}\\`module'_cedlas.dta", replace
	export `ex_im_type' using "$output_LEL\\`module'_cedlas.`form'", `delim' `firstvar' `replace'		
	noi disp in w "The file `module'_cedlas.`form' has been replaced in the following path:" _n /// 
	"${output_LEL}" _n
	
}
else {  // non-cedlas calculations
	noi di in red "Module: `module'"
	if "`byarea'"!=""  {
		local area "area"
	}
	
	*Define export format 
	local form "txt"
	local delim `"delim(";")"'
	local ex_im_type delimited
	local first ""
	local firstvar ""
	
	if ("`path'" != "master") {
		local form "xlsx"	
		local delim ""
		local ex_im_type excel
		local first "first"
		local firstvar "first(variables)"
	}
	
	
	if "`module'"!="eho" { // for external home page, replace all file
	
		*Generate locals of variables for merge
		local id_year year
		local id_indicator indicator
		if inlist("`module'", "drd", "bde",	"shp", "gis") local id_year year1 year2
		if inlist("`module'","gic") local id_year ""
		
		if inlist("`module'", "pov")  local id_indicator zone pline indicator
		if inlist("`module'", "ine")  local id_indicator zone indicator
		if inlist("`module'", "b40")  local id_indicator indicator group
		if inlist("`module'", "gic")  local id_indicator percentiles
		if inlist("`module'", "dis")  local id_indicator percentiles group
		
		if inlist("`module'", "lab")  local id_indicator group lab_status
		if inlist("`module'", "lip")  local id_indicator base_year indicator line
		
		if inlist("`module'", "bde")  local id_indicator pline dtype  pov_ind component
		if inlist("`module'", "inq")  local id_indicator quintiles inc_source
		if inlist("`module'", "drd")  local id_indicator indicator pline component
		if inlist("`module'", "gis")  local id_indicator percentiles inc_type
		if inlist("`module'", "reg")  local id_indicator type pline
		if inlist("`module'", "nin")  local id_indicator status ages gender
		
		* if inlist("`module'", "eho")  local id_indicator indicator zone universe measure
		if inlist("`module'", "oph")  local id_indicator 
		
		local varmerge "country `id_year' `area' `id_indicator'"
		
		
	
		* describe, varlist
		* local allvars = r(varlist)
		* autolel_2string `allvars'
		duplicates drop // bug drd - runs lac twice
		save `_module_calc_temp'
		
		
		*confirm if the file exist 
		
		cap confirm file "${output_LEL}\\`module'.dta"	
		if !_rc {
			
			cap use "${output_LEL}\\`module'.dta", clear
			if (_rc) {
				noi disp in red "Something went wrong importing the file `module'. Please check"
				error
			}
			
			* describe, varlist
			* local allvars = r(varlist)
			* autolel_2string `allvars'

			
			cap noi merge 1:1 `varmerge' using `_module_calc_temp', update replace nogen
			if (_rc) {
				drop _all
				use `_module_calc_temp'
				autolel_2string `allvars'
				save `_module_calc_temp', replace
				
				use "${output_LEL}\\`module'.dta", clear
				cap noi merge 1:1 `varmerge' using `_module_calc_temp', update replace nogen
				if (_rc) {
					noi disp in red "error merging $output_LEL\\`module'.dta"
					error
				}
			}
			
		} //  end of condition when file exists
			
	}  // end condition if not eho (external home page)
}
	
	// include country names again (bug)
	autolel_labels, countries
	
	// export results
	save "${output_LEL}\\`module'.dta", replace
	export `ex_im_type' using "${output_LEL}\\`module'.`form'", `delim' `firstvar' `replace'		
	noi disp in w "The file `module'.`form' has been replaced in the following path:" _n /// 
	"${output_LEL}" _n
* }
* }



end

exit 


