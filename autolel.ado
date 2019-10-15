*! version 0.6            <11feb2018>         Andres Castaneda
*! incorporate SEDLAC 03
/*====================================================================
project:       AUTO LEL
Author:        Carlos Felipe Balcazar
Dependencies:  The World Bank
----------------------------------------------------------------------
Creation Date:      17 Mar 2017 
Modification Date:  10 Apr 2017 -- Andres Castañeda
Modification Date:  23 May 2017 -- Carlos Felipe Balcazar
Modification Date:	6 Jun 2017 -- Natalia Garcia Pena
Do-file version:    04
References:
Output:             
====================================================================*/

/*====================================================================
0: Program set up: syntax and options
====================================================================*/
cap program drop autolel
program define autolel, rclass
version 13.0
syntax [anything(name=calculation)],  ///
[                                   ///  
update                              /// Updates autolel (checks for user id)
COUNtries(string)                   /// Input countries
Years(numlist)                      /// Input years
PROject(passthru)                   /// SEDLAC project version
VERMast(passthru)					/// Datalib master version
VERAlt(passthru)					/// Datalib alternative version
SURVEY(passthru)					/// Datalib survey
REPO(passthru)       	       		/// Name of repository repo(use `reponame')
REPOPath(string)					/// Repository Path
MODules(passthru)                   ///
circa(numlist)                      /// Input circa periods
range(numlist min=2 max=2 sort)     /// range of periods
byarea                              /// By urban/rural
cedlas			                    /// celdas statistics
inpath(string)						/// Path for autolel inputs (for external home page)
incsources(string)					/// For Shapley decompostion
dtype(passthru)						/// Decompostion type for Shapley
pls(passthru)						/// Pov lines for Shapley
lfage(string)						/// Labor Force age for labor dashboards
Quarters(numlist)					/// Quarters for LABLAC (LIPI)
path(string)                        /// Path for user to save excel results 
LANGuage(string)                    /// english, spanish or both
format(passthru)                    /// format table output
replace                             /// Replaces files saved in path
save                                /// Save results in path() or CD
noSHOW                              /// Does not show results in results window
clear  *                            /// Deletes current dataset
erase								/// Erases previous output
saverepo							/// With erase option - saves repo with the date
TROubleshoot						/// Displays key parts of the code when program is not running
]


* PERIOD(string)						/// Datalib period for LABLAC -string for indexing

/*====================================================================
	1.	Install programs, autlel default globals, ensure default conditions
====================================================================*/
quietly {
	** programs to install
	local pros "unique varlocal missings head quantiles"
	foreach pro of local pros {
		cap which `pro'
		if (_rc) ssc install `pro'
	}
	
	autolel_defaults, globals
	local lel_cedlasgen   = "${lel_cedlasgen}"
	local lel_lelgen      = "${lel_lelgen}"
	* local lel_decomp      = "${lel_decomp}" // this can be removed in the future
	local lel_crossseries = "${lel_crossseries}"
	local lel_nocounyears = "${lel_nocounyears}"
	local lel_2crosssect  = "${lel_2crosssect}"
	
	*===============================================================================
	* if ("`clear'" == "") preserve
	
	** cedlas conditional
	if ("`cedlas'"!="" & "`update'"=="") {
		disp in r "Option cedlas must be used with update option."
		error
	}
	
	**  make sure, calculations are specified correctly
	if ("`calculation'" == "") local calculation "pov"
	if (wordcount("`calculation'")>1) {
		noi disp as err "you cannot perform more than one calculation at a time"
		error 
	}
	
	** check that calculations requested are available 
	if ("`cedlas'"!="" & "`update'"!="") {   // CEDLAS
		local calclist "${lel_cedlasgen}"
	} 
	else {  // LEL
		local calclist "${lel_lelgen}"
	}
	matchlist, b("`calculation'") m("`calclist'")
	if (`r(match)' != 1) { 
		noi disp in red "Calculation must be specified from the predefined list here:" _n ///
		"`: subinstr local calclist " " " , ", all '"
		error
	}	
	

	* first and second period for decomps and changes
	if ("`range'" != "") {
		local fp: word 1 of `range'
		local sp: word 2 of `range'
	}
	
	** Add repository options for datalib (path already defined)
	if "`repopath'"!="" local repath `"path(`repopath')"'
	
	
	** countries code in lower cases	
	if ("`countries'" != "") local countries = lower("`countries'")
	
	** default is all years
	if ("`years'" == "") {
			autolel_defaults , years
			local years = "`r(years)'"
	}  //  end of years condition 
	
	*===============================================================================
	* CONDITIONS for subprograms:
	if strpos("`calculation'", "reg")!=0 {
		if ("`countries'" != "lac") {
			noi disp as err "LAC must be used for regional distribution."
			error 
		}
	}

	
	*===============================================================================
	* UPDATE ON: TEST PERMITS
	if "`update'"=="update" {
		if ("`circa'"!="") {
			disp in r "Option update cannot be used with circa option."
			error
		}
		autolel_usercheck
		local path master
	}
	*===============================================================================
	* UPDATE ON: CREATE DEFAULT PARAMETERS FOR COUNTRY AND YEARS
	*  
	matchlist, b("`calculation'") m("${lel_decomp}")
	local drmatch = `r(match)'
	
	if ("`update'"=="update") {
		if ("`countries'" == "")  {
			autolel_defaults , countries lac
			local countries= "`r(countries)'"
		}
		
		if ("`years'" == "") {
			autolel_defaults , years
			local years = "`r(years)'"
		}  //  end of years condition 
	}  // end of update selection 
	
	else {
		if "`erase'"=="" {
			if (`drmatch' != 0 & ("`fp'" == "" | "`sp'" == ""))  {
				disp in r "You must select the first and second periods for the decomposition(s)."
				error
			}
			if ("`countries'" == "") {
				disp in r "You must select at least one country OR the option update"
				error
			}
			if ("`years'" == "") & ("`circa'" == "") & `drmatch' == 0  {
				disp "You must select at least one year"
				error
			}
		} // end not erase option
	}  //  end of condition when update is not selected 
	
	*===============================================================================
	* LANGUAGE ON: CREATE LOCAL FOR SPANISH
	if ("`language'" == "")	local language "en"
	
	if !inlist("`language'", "en", "sp", "both")  {
		noi disp in red "Language availability is only English (en), or Spanish (sp), or both"
		error
	}
	
	*===============================================================================
	* OTHER LOGICAL RULES
	if ("`years'" != "" & "`circa'" != "") {
		disp "You cannot selected both years and circa options"
		error
	}
	*===============================================================================
	* CLEAR ON: DELETE CURRENT DATABASE, OTHERWISE SAVE IT AND RELOAD AT THE END 
	drop _all
	set matsize 11000
	
	*===============================================================================
	* PATHS SET-UP AND AUXILIARY FILES
	autolel_defaults, path("`path'") paths
	
	if "`update'"=="update" {
		autolel_filecheck, modules("`calculation'")  //  CHECK. ado-file modified	
		local replace "replace" 
	}
	*===============================================================================
	
	* Erase files: This option is apart so it won't accidentally replace everything.
	if "`erase'"!="" {

		foreach calc of local calculation {
			autolel_defaults, globals
			cap confirm file "${output_LEL}\\`calc'.dta"	
			if _rc {
				noi di in red "${output_LEL}\\`calc'.dta doesn't exist"
				exit
			}
			else {
				local date = "`c(current_date)'"
				use "${output_LEL}\\`calc'.dta", clear
				if "`saverepo'"!="" {
					save "${output_LEL}\\`calc'_`date'.dta", replace
					noi di in white "Repo: ${output_LEL}\\`calc'_`date'.dta saved"
				}
				erase "${output_LEL}\\`calc'.dta"
				noi di in white "${output_LEL}\\`calc'.dta erased"
				erase "${output_LEL}\\`calc'.txt"
				noi di in white "${output_LEL}\\`calc'.txt erased"
				
				exit
			}
		}
	}




/*========================================================================
	2.  SEDLAC_STATS LOOP
*========================================================================*/
	if ("`cedlas'"=="cedlas") {
		foreach ind of local calculation {
			noi disp "`ind'"
			sedlac_stats, country("`countries'") year("`years'") ind("`ind'") autolel replace // Natalia (for now option replace). Needs to be seen in future
			tempfile sedlac_`ind'
			save `sedlac_`ind'', `replace' // Natalia: Save tempfile in autolel instead of sedlac_stats or else I think it erases tempfile when program ends?
		} 
	}
/*========================================================================
	2.1  External home page
*========================================================================*/

	if ("`calculation'" == "eho") {
	
		if "`inpath'"=="" {
			autolel_eho
		}
		else {
			autolel_eho, path(`inpath')
		}
		
		exit
	}
				
/*========================================================================
	3. CROSS SECTION series - Main loop (pov, ine, inq, b40, dis, lab)
*========================================================================*/
/*========================================================================
	3.1. CROSS SECTION series - Load datalib datasets
*========================================================================*/
	
	else {  // Non-cedlas calculations
		local crosscals: list calculation & lel_crossseries
		
		if ("`crosscals'"  != "") {

			noi disp in y "I am working on your calculations. " _n /// 
			"In the meantime, go and get a nice cup of coffee or enjoy the dots" _n
			
***** Countries loop ***********************************************************
			foreach country of local countries {
				
				** country identifier 
				autolel_countrylist `country'
				
				local countryiso3 = `r(countryiso3n)'
				local countryname = "`r(countryname)'"
				local countrycode = "`r(countrycode)'"
				
				
				* If years is not empty, run years 
				if ("`years'" != "") {
					local periods="`years'"
				}
				* If circa is not empty, run circa years 
				else if ("`circa'" != "") {
					local periods="`circa'"
				}
*******  Years loop  ***********************************************************			
				foreach year of local periods  {    
					noi disp in g _c "." 
					* If years is not empty, run years
					if ("`years'" != "") {
						local yearsopt "years(`year')" 
						local circaopt ""
					}
					* If circa is not empty, run circa years
					else if ("`circa'" != "") {
						local yearsopt ""
						local circaopt "circa(`year')" 
					}
					* If all is empty, then use default circa years    EXPLANATION
					else {
						local yearsopt ""
						local circaopt "circa(`year')" 
					}
					
					
					* For LABLAC: Load all quarters:
					if strpos("`crosscals'","lip")!=0 { // LIPI-LABLAC condition
						* if "`periods'"=="" local quarters "q01 q02 q03 q04"
						* else local quarters = substr("`periods'",8,.)
						local quarters "q01 q02 q03 q04"
						
						drop _all
						tempfile lipi_
						save `lipi_', replace emptyok
						foreach q of local quarters {
							if "`troubleshoot'"!= "" noi di in white "Line 335: cap  datalib, country(`country') type(lablac) period(`q') `yearsopt' `circaopt' `project' `repath' `repo' `vermast' `veralt' `survey' `period' incppp(ipcf ila inla ilpc) nocohh clear"
							
							cap  datalib, country(`country') type(lablac) period(`q') `yearsopt' `circaopt' ///
							`project' `repath' `repo' `vermast' `veralt' `survey' `period' incppp(ipcf ila inla ilpc) nocohh clear 
							if (_rc) {
								noi disp as err "W: " as text "`country' - `year'-  `q' not loaded"
								continue
							}
							else {
								count
								if `r(N)'==0 noi disp as err "W: " as text "`country' - `year'-  `q' has 0 obs"
								else noi disp in white "`country' - `year' - `q' loaded"
								cap confirm var ipcf_ppp11
								if _rc noi di as err "ipcf_ppp11 not found"
								
							} // END else
							append using `lipi_'
							save `lipi_', replace
						} // END foreach quarter
						drop _all
						use `lipi_'
						count
						if `r(N)'== 0 continue
					} // END LIPI - LABLAC condition

					
					* FOR SEDLAC: (non-lablac)
					else { // NON-LIPI LABLAC condition
						if "`troubleshoot'"!= ""  noi di in white "Line 363: cap  datalib, country(`country') `yearsopt' `circaopt' `project' `modules' `repath' `repo' `vermast' `veralt' `survey' `period' clear" 
						
						cap  datalib, country(`country') `yearsopt' `circaopt' ///
						`project' `modules' `repath' `repo' `vermast' `veralt' `survey' `period' clear  
					
						* noi di in white "cap  datalib, country(`country') `yearsopt' `circaopt' `project' `modules' `repath' `repo' `vermast' `veralt' clear"
						if (_rc) {
							noi disp as err "W: " as text "`country' - `year' not loaded"
							continue
						}
						else {
							noi disp in white "`country' - `year' loaded"
						}
					} // END NON - LIPI LABLAC condition
				
***** Calc loop ***********************************************************
					foreach calc of local crosscals {
						
						** conditions for specific calcualtions 
						if (inlist("`calc'", "inq", "b40","lab","lip") & upper("`country'") == "LAC") {
							noi disp in red "Warning: " as text "`calc' is only available for countries, not for the whole region"
							continue
						}
						
						autolel_`calc', country(`country') year(`year') iso(`countryiso3') `byarea' // calculations
/*========================================================================
	3.3. CROSS SECTION series - Save results
*========================================================================*/	
		
						*Convert matrices into tempfiles
						if ("`calc'" == "pov") local colnames "country zone year pline rate obs indicator"
						if ("`calc'" == "ine") local colnames "country zone year rate indicator"
						if ("`calc'" == "inq") local colnames "country year quintiles inc_source shq_tot shi_by_q shq_by_i value"
						if ("`calc'" == "b40") local colnames "country year group rate indicator totals"
						if ("`calc'" == "gic") local colnames "country year percentiles mean total"
						if ("`calc'" == "dis") local colnames "country year percentiles p_share cum_dis group"
						if ("`calc'" == "eho") local colnames "country year1 year2 rate date upi circa1 circa2 indicator indicator_sp countrycode countryname countryname_sp topic year area_en area_sp circa series obs pline pline_sp"
						if ("`calc'" == "lab") local colnames "country year group lab_status rate obs pop_rate"
						if ("`calc'" == "lip") local colnames "country year quarter indicator line rate consistency inconsistent"
						if ("`calc'" == "reg") local colnames "type indicator country year pline n_poor share"
						if ("`calc'" == "nin") local colnames "country year status ages gender share obs"
						
						*Append tempfile for each country/year instead of whole matrix
						drop _all
						cap mat drop `_main_mat_`calc'' // new matrix for each country-year
						tempname _main_mat_`calc'
						mat `_main_mat_`calc'' = nullmat(`_main_mat_`calc'') /// store results
						\ r(_main_mat_`calc') // return lists martix _main_mat_`calc' saved in sub-programs
						* noi mat list `_main_mat_`calc'' // temp erase
						
						cap mat colnames `_main_mat_`calc'' =  `colnames' 
						if _rc {
							noi di in red "`_main_mat_`calc'' - is an empty matrix"
							exit
						}
						svmat double `_main_mat_`calc'', n(col)
						
						cap confirm file `tempfile_`calc'' // for first loop it makes new matrix, then appends (countries and years)
						if _rc { // if file doesn't exist
							tempfile tempfile_`calc'
							save `tempfile_`calc'', replace empty // stores matrix output in tempfile
						}
						else {
							append using `tempfile_`calc''
							save `tempfile_`calc'', replace
						} // end of else			
						local calc_aux "`calc'" // for gic
					}  // end of cross calcs calculations loop
*******  End calc loop  ***********************************************************
						
				} // end of years loop
*******  End years loop  ***********************************************************

			} // end of countries loop
*******  End countries loop  ***********************************************************

			* GIC: Comparability and reshape wide
			if ("`calc_aux'" == "gic") {
				drop _all
				use `tempfile_`calc_aux''
				
				* Comparability: Keep latest comparable series with exceptions:
				autolel_labels, countries module("gic")
				autolel_defaults, series_breaks
				autolel_defaults, comp_gic
				

				* Reshape wide for Tableau parameters
				autolel_gic, merge
				save `tempfile_`calc_aux'', replace
			}
			
			* LIPI generate relative rate
			if ("`calc_aux'" == "lip") {
				drop _all
				use `tempfile_`calc_aux''
				
				autolel_lip, merge
				autolel_defaults, comp_lip
				save `tempfile_`calc_aux'', replace
				
				
			}
			
		}  // end of cross sections

		
		
		

*============================================================================
* End of cross series calculations
*============================================================================
	
/*========================================================================
	4. TWO CROSS SECTION series - Main loop (shp drd bde gis)
*========================================================================*/			
/*========================================================================
	4.1. TWO CROSS SECTION series - Load datalib datasets
*========================================================================*/	
		
		local twocrosscals: list calculation & lel_2crosssect
		
		if ("`twocrosscals'"  != "") {

			noi disp in y "I am working on doing your calculations. " _n /// 
			"In the meantime, go and get a nice cup of coffee or enjoy the dots" _n
			foreach country of local countries {
				
				** country identifier 
				autolel_countrylist `country'
				
				local countryiso3 = `r(countryiso3n)'
				local countryname = "`r(countryname)'"
				local countrycode = "`r(countrycode)'"
				
				if ("`update'" == "") {
					local yearpairs "`range'"
				}
				if ("`update'" != "")  {   // Default pairs of years
					autolel_defaults , twocross country(`country')
					local yearpairs "`r(twoyears)'"  	
				}
				
				
				
				* Variables to keep in two-crosscalculations
				if ("`country'"!="lac") {
					if ("`keepvars'"=="") {	
						local keepvars "pais year id cohh ipcf_ppp* pondera year lp* miembros ila_ppp11"
						
						if strpos("`calculation'","bde")!=0 local keepvars "pais year id cohh ipcf_ppp* pondera year lp* miembros ila_ppp11 miembros edad hombre ipc11_sedlac ipc_sedlac conversion ppp11 id itran* ijubi* `incsources'"
						// before it was i* but there were some non-harm vars that were different types in dif years, so they didn't append.
				
					}
				}
				
				
				local ny: word count `yearpairs' // Natalia
				*************************************
				* Beginning of pairs of years loop
				*************************************
				foreach p of numlist 1(2)`ny' {
	
					local fp: word `p' of `yearpairs' // word 1 of yearpairs
					local sp: word `=`p'+1' of `yearpairs'
					

					*Append two datasets (datalib appending isn't working and option vars isn't working.
					if "`troubleshoot'"!="" {
						noi di in white "local r(twoyears) is: `r(twoyears)': local ny is `ny': local fp is `fp' and local sp is `sp'"
						noi di in white "Line 534: cap datalib, country(`country') year(`fp') `project' `modules' `vermast' `veralt' `repath' `repo' `periods'`survey' `period' clear"
					}
					 cap datalib, country(`country') year(`fp') `project' `modules' `vermast' `veralt' `repath' `repo' `periods'`survey' `period' clear
					
					if (_rc) {
						noi disp as err "W:" as text "`country' - fp: `fp' not loaded"
						continue
					}
					else noi disp in white "`country' - `fp' loaded"
					
					cap confirm var cohh
					if (_rc) gen cohh = 1
					
					if ("`country'"!="lac") {
						cap drop year
						rename ano year
						keep if cohh == 1 & ipcf_ppp11!=.
						keep `keepvars'
					}
					
				
					tempfile datalib_fp
					save `datalib_fp', replace
					
					if "`troubleshoot'"!="" noi di in white "Line 558: cap datalib, country(`country') year(`sp') `project' `modules' `vermast' `veralt' `repath' `repo' `survey' `period' clear"
					
					cap datalib, country(`country') year(`sp') `project' `modules' `vermast' `veralt' `repath' `repo' `survey' `period' clear 
					
					if (_rc) {
						noi disp as err "W:" as text "`country' - sp: `sp' not loaded"
						continue
					}
					else noi disp in white "`country' - `sp' loaded"
						
					cap confirm var cohh
					if (_rc) gen cohh = 1
					
					if ("`country'"!="lac") {
						cap drop year
						rename ano year
						keep if cohh == 1 & ipcf_ppp11!=.
						keep `keepvars'
					}
					
					
					append using `datalib_fp'
					*************************************************************
					

					
					tempfile twoperiods
					save `twoperiods', replace
					noi disp in g _c "." 
					
/*========================================================================
	4.2. TWO CROSS SECTION series - Calculations from sub-programs
*========================================================================*/	
					* Crosscalcs: drd, bde, shp, gis
					foreach calc of local twocrosscals { // NEW NATALIA
						use `twoperiods', clear
						
						* Run autolel two period subprograms
						autolel_`calc', country(`country') iso(`countryiso3') year1(`fp') year2(`sp') `dtype' `pls'
						
	
						*=====================================================================
						*        Save results in tempfiles for each country and pair of years
						*=====================================================================
						* Convert matrices into tempfiles for twocross (shp, drd, bde, gic)
		
						if ("`calc'" == "drd") local colnames "country year1 year2  pline indicator component rate"
						if ("`calc'" == "bde") local colnames "country year1 year2  dtype pline pov_ind component rate"
						if ("`calc'" == "shp") local colnames "country year1 year2 rate indicator"
						if ("`calc'" == "gis") local colnames "country year1 year2 percentiles  inc_type total_growth value"
						

						drop _all
						tempname _main_mat_`calc'
						cap mat drop `_main_mat_`calc'' // new matrix for each country-twoyear
						mat `_main_mat_`calc'' = nullmat(`_main_mat_`calc'') /// store results
						\ r(_main_mat_`calc')
						
						
						
						*  noi mat list `_main_mat_`calc'' // temp
						
						
						mat colnames `_main_mat_`calc'' = `colnames' 
						svmat double `_main_mat_`calc'', n(col)
						
						cap confirm file `tempfile_`calc''
						if _rc { // if file doesn't exist
							tempfile tempfile_`calc'
							save `tempfile_`calc'', replace empty
						}
						else {
							append using `tempfile_`calc''
							save `tempfile_`calc'', replace
						} // end appending tempfiles
					} // end of foreach twocrosscals loop
				} // end of pair of years loop
		***************************************************
			} //  end of countries loop
		}  // end of ("`twocrosscals'"  != "")
		
		
		
		
	
		/*============================================================================
		* all countries and years at the same time
		For this calculations there is no need to specify countries and years
		*============================================================================*/
		*N: I think this is supposed to be autolel update, but not sure why official poverty is here
		local nocounyearscals: list calculation & lel_nocounyears // N: note, in defaults lel_noconyears is oph is  Official poverty headcount. Why is it here? (?)
		
		if ("`nocounyearscals'"  != "") {
			foreach calc of local nocounyearscals {
				autolel_`calc', `update'
				
			}
		}
		
	} // end of non-cedlas condition
	
	
*===========================================================================
* 5. LABELING and EXPORTING DATA
*===========================================================================
	
	if ("`clear'" == "clear") drop _all
	
	* SEDLAC STATS
	if ("`cedlas'"!="") {
		foreach i of local calculation {
			if "`i'"=="bootstrap" {
				local ind bts // Natalia: Check with German best way to do this
			}
			else {
				local ind = substr("`i'",1,3)
			}
			drop _all 
			use `sedlac_`ind''
			if "`update'"!="" {
				gen date= "$S_DATE"
				gen upi = "`c(username)'"
			}
			if ("`show'" != "noshow") {
				local upper = upper("`i'")
				tempfile all
				save `all', replace //since double preserve not allowed
				gen count = _n // preliminary results. Ideal would be for user to chose which results to show
				keep if count == 1
				noi disp in g "================================================="
				noi disp in g "`upper'"
				noi disp in g "================================================="
				
				noi table indicator year, c(sum rate) by(country) //first simple table
				use `all', replace //equivalent to restore
				
			}
			if ("`save'" == "save" | "`path'" != "") autolel_export, module(`ind') path(`path') `replace' `cedlas' // Natalia: missing export for cedlas
		}
	} // end cedlas (sedlac stats)
	
	else { // non cedlas calculations
	
		foreach calc of local calculation {
			
			drop _all
			cap use `tempfile_`calc''
			noi di in white "cap use `tempfile_`calc''- autolel line 660 temp"
			if _rc {
				noi di in red "No observations found in `calc' file"
				continue
				exit
			}
			else { // if tempfile is not empty
				if ("`calc'" == "oph") { // Natalia: Check this
					use "${output_temp}\\`calc'.dta", clear				
					erase "${output_temp}\\`calc'.dta"
				}
				
				if "`update'"!="" {
					cap drop date
					cap drop upi
					gen date= "$S_DATE"
					gen upi = "`c(username)'"
				}
				
				autolel_labels,  countries module("`calc'")
				
				autolel_defaults, circaman 	module("`calc'") export
				
				
				
				*Series breaks
				if inlist("`calc'","pov", "ine", "inq", "b40", "dis") {
					autolel_defaults, series_breaks module("`calc'")
				}
				
				
				autolel_defaults, filter
				
				
				if ("`save'" == "save" | "`path'" != "") ///
				autolel_export, module(`calc') path(`path') `replace'
	
			} // end tempfile is not empty
		}  // end of calculations loop 
	} // end of all others besides CEDLAS
	* } 
} // End of qui 





end

************************************************************************************************
************************************************************************************************

*==============================================
*     Auxiliary programs
*==============================================

cap program drop matchlist 
program define matchlist, rclass

syntax, Base(string) Mlist(string) [DELIMiter(string)]

tempname match
mata: st_numscalar("`match'", _matchlist("`base'", "`mlist'"))

return local match = `match'
end

mata:

real scalar _matchlist(string scalar Base, 
string scalar List) {
	
	B = tokens(Base)
	L = tokens(List)
	M = strmatch(B, L')
	
	R = mean(colsum(M)')
	return(R)
	
}

end 



exit
/* End of do-file */
><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:
*!
*!---------------- History of the File ----------------------
*! version 0.4            <21nov2017>         Andres Castaneda
*! version 0.3            <03nov2017>         Andres Castaneda
*! version 0.2            <01jun2017>         Andres Castaneda, Natalia Garcia, German Reyes, Felipe Balcazar
*! version 0.1            <01may2017>         Andres Castaneda, Felipe Balcazar




*ERASE:
*******************************************************
						* COMPUTING POVERTY DECOMPOSITION: DATT-RAVALLION
						**********************************z*********************
						* if ("`calc'" == "drd" & "`country'"!="lac") {  //ERASE
						if ("`calc'" == "drd" ) { 
							autolel_drd, country(`country') iso(`countryiso3') year1(`fp') year2(`sp') // pl(`pl')
		
						}	 // end of Datt Ravallion

						*=====================================================================
						* COMPUTING POVERTY DECOMPOSITION: BARROS (SHAPLEY)
						if ("`calc'" == "bde" & "`country'"!="lac") { 
							autolel_bde, iso(`countryiso3') year1(`fp') year2(`sp') `dtype' `pls'
							
						} // End of Barros
						*=====================================================================
						* COMPUTING SHARED PROSPERITY 
						if ("`calc'" == "shp") {  /* CHECK condition in LAC*/
						
							autolel_shp, country(`country') iso(`countryiso3') year1(`fp') year2(`sp')
							
						}  //  end of Shared Prosperity
						
						
						*=====================================================================
						* GIS (GIC by income source)

						if ("`calc'" == "gis") {  /* CHECK condition in LAC*/	
							autolel_gis, country(`country') iso(`countryiso3') year1(`fp') year2(`sp')
							
						}  //  end of GIS























































