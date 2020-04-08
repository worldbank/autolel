/*====================================================================
project:       Set defaults for auto LEL project
Author:        Andres Castaneda 
Dependencies:  The World Bank
----------------------------------------------------------------------
Creation Date:    28 Aug 2017 - 12:22:12
Modification Date:   
Do-file version:    01
References:          
Output:             locals
====================================================================*/

/*====================================================================
0: Program set up
====================================================================*/

program define autolel_defaults, rclass
version 14.0
syntax [anything(name=anything)],  [ ///
circaman countries lac years circadef   ///
twocross globals SERIES_breaks path(string) paths subregion ///
country(string) module(string) export filter ///
comp_gic comp_lip reg_represent gmd sedlac survey(string)] // (gmd sedlac for reg_represent)

/*====================================================================
0:  Special conditions
====================================================================*/

if ("`module'" == "eho" & "`export'" == "export") exit

* Bra PNADC
if ("`country'" == "bra" & "`survey'"=="pnadc") local country "br2"


/*====================================================================
1: 
====================================================================*/



local lastyear = 2018 // change when new surveys are added

*--------------------1.1: COUNTRIES

if ("`countries'" != "") return local countries ///
"arg bol bra chl col cri dom ecu gtm hnd mex nic pan per pry slv ury hti lca `lac'" // Add new countries

*--------------------1.2: YEARS
if ("`years'" != "") {
	numlist "2000/`lastyear'"   // modify as needed
	return local years = r(numlist)
}

* --------------------1.3: CIRCA DEFAULT (TWOYEARS FOR TWOCROSS SECTION ) (shp, drd, bde, gic)

if strpos("$lel_2crosssect","`module'") != 0 {
			if upper("`country'") == "ARG" return local twoyears  	   "2008 2013 2013 2018 2008 2018"  //
			else if upper("`country'") == "BRA" return local twoyears  "2008 2012 . . . ."  // PNAD PNADC
			else if upper("`country'") == "BR2" return local twoyears  ". . 2013 2018 . ."  // PNAD PNADC
			else if upper("`country'") == "BOL" return local twoyears  "2008 2013 2013 2018 2008 2018" // Same
			else if upper("`country'") == "CHL" return local twoyears  "2009 2013 2013 2017 2009 2017" // Dif 
			else if upper("`country'") == "COL" return local twoyears  "2008 2013 2013 2018 2008 2018" // 
			else if upper("`country'") == "CRI" return local twoyears  "2010 2013 2013 2018 2010 2018"    // 
			else if upper("`country'") == "DOM" return local twoyears  "2008 2013 2013 2016 2008 2016" // Dif 
			else if upper("`country'") == "ECU" return local twoyears   "2008 2013 2013 2018 2008 2018"  // Same
			else if upper("`country'") == "SLV" return local twoyears  "2008 2013 2013 2018 2008 2018"  // Same
			else if upper("`country'") == "GTM" return local twoyears  ". . . . 2006 2014"			 // Dif
			else if upper("`country'") == "HND" return local twoyears   "2008 2013 2013 2018 2008 2018"  // Same
			else if upper("`country'") == "MEX" return local twoyears  "2008 2014 2016 2018 . . " // If 2016 - 2018 is too small, remove
			else if upper("`country'") == "NIC" return local twoyears  "2009 2014 . . . ." // Dif
			else if upper("`country'") == "PAN" return local twoyears   "2008 2013 2013 2018 2008 2018" // Same
			else if upper("`country'") == "PRY" return local twoyears   "2008 2013 2013 2018 2008 2018"  // Same
			else if upper("`country'") == "PER" return local twoyears   "2008 2013 2013 2018 2008 2018"  // Same
			else if upper("`country'") == "URY" return local twoyears   "2008 2013 2013 2018 2008 2018"  // Same
			else 						   return local twoyears  "2008 2013 2013 2018 2008 2018" // LAC
			

}


* --------------------1.4: Subregions
if ("`subregion'" != "") {
	replace pais = lower(pais)
	* CENTRAL AMERICA
	replace `anything'=1000 if pais=="cri" | pais=="dom" | pais=="slv" | pais=="hnd" ///
	| pais=="pan"  | pais=="nic"  | pais=="gtm" 
	
	* ANDEAN REGION
	replace `anything'=1001 if pais=="bol" | pais=="col" | pais=="ecu" | pais=="per"  
	
	* CONO SUR
	replace `anything'=1002 if pais=="arg" | pais=="chl" | pais=="pry" | pais=="ury" 
} // end of subregion



* --------------------1.5: Globals and Paths

* list of calculations
if ("`globals'" != "")  {
	* Calculations lists
	global lel_cedlasgen   "dem dur edu hou inc ine pov bts emp"  // cedlas calculations (not used)
	global lel_lelgen      "pov ine inq b40 dis gic oph drd bde shp gis eho lab lip reg nin hoi hos hod" // All LEL calculations (add new subprograms)
	global lel_decomp		"drd bde" // probably not necessary 
	global lel_crossseries "pov ine inq b40 dis gic lab lip reg nin hoi hos" // cross-section series (add new subprograms)
	global lel_seriesbreaks "pov ine inq b40 dis"  // calcs that need series breaks (trends)
	global lel_2crosssect  "drd bde shp gis hod"         // two cross-sections (add new subprograms)
	
} // end globals

* default paths (this replace previous ado-file autolel_paths)
if ("`paths'" != "") {
	if ("`path'" == "")       {
	
		global roota_LEL "`c(pwd)'"  // current directory
		noi disp in w "No path defined, if you use the save option, results will be save in:"
		noi disp in w "`c(pwd)'" _n
	} // end of path condition
	else if ("`path'" == "master") global roota_LEL "Z:\public\Stats_Team\LAC Equity Lab\Auto-LEL"
	else                           global roota_LEL "`path'"
	
	global output_LEL "${roota_LEL}\LEL_Ouput"
	global output_temp "${roota_LEL}\temp"
	cap mkdir "${output_LEL}"
	cap mkdir "${output_temp}"
}


/*====================================================================
2: CIRCA MANUAL (This replaces autolel_def_countryears)
====================================================================*/

if ("`circaman'" == "circaman") {
	confirm var country // Natalia: is this necessary?

	replace country = 998	    if (country == 76 & "`survey'"=="pnadc")  // if 	(country == 76 & year > 2015) // Add two Brazil series

	autolel_countrylist
	local codeslist      = "`r(codeslist)'"
	local iso3list       = "`r(iso3list)'"
	
	levelsof country, local(countries) 
	foreach country of local countries {
		
		local w : list posof "`country'" in iso3list
		local code : word `w' of `codeslist'
		* For two cross sections: Comparability between periods
		
		if strpos("$lel_2crosssect","`module'") != 0 {
		
		* if ("`twocross'" != "" & "`country'" != "") {
		* if inlist("`module'","shp","drd","bde","gis") {
			local circas  "2008 2013 2013 2018 2008 2018"	
			if      ("`code'" == "ARG") local years  "2008 2013 2013 2018 2008 2018" // Same
			else if ("`code'" == "BRA") local years   "2008 2012 . . . ."   // PNAD PNADC
			else if ("`code'" == "BR2") local years   ". . 2013 2018 . ."   // PNAD PNADC
			else if ("`code'" == "BOL") local years  "2008 2013 2013 2018 2008 2018" // Same
			else if ("`code'" == "CHL") local years  "2009 2013 2013 2017 2009 2017" // Dif 
			else if ("`code'" == "COL") local years  "2008 2013 2013 2018 2008 2018" // Dif 
			else if ("`code'" == "CRI") local years  "2010 2013 2013 2018 2010 2018"       // Dif 
			else if ("`code'" == "DOM") local years  "2008 2013 2013 2016 2008 2016"  // Dif 
			else if ("`code'" == "ECU") local years  "2008 2013 2013 2018 2008 2018" // Same
			else if ("`code'" == "SLV") local years  "2008 2013 2013 2018 2008 2018" // Same
			else if ("`code'" == "GTM") local years  ". . . . 2006 2014"			 // Dif
			else if ("`code'" == "HND") local years  "2008 2013 2013 2018 2008 2018" // Same
			else if ("`code'" == "MEX") local years  "2008 2014 2016 2018 . . " // Dif
			else if ("`code'" == "NIC") local years   "2009 2014 . . . ."  // Dif
			else if ("`code'" == "PAN") local years  "2008 2012 2012 2017 2008 2017" // Dif
			else if ("`code'" == "PRY") local years  "2008 2013 2013 2018 2008 2018" // Same
			else if ("`code'" == "PER") local years  "2008 2013 2013 2018 2008 2018" // Same
			else if ("`code'" == "URY") local years  "2008 2013 2013 2018 2008 2018" // Same
			else                        local years  "`circas'" 
			di in white "TEMP: autolel defaults 158: code `code' years `years'"
		}
		* Cross-section circas
		else {
			local circas "2008 2013 2018" 
			if      ("`code'" == "ARG") local years "2008 2013 2018"
			else if ("`code'" == "BOL") local years "2008 2013 2018"
			else if ("`code'" == "BRA") local years "2008 2013 2018"
			else if ("`code'" == "CHL") local years "2009 2013 2017"
			else if ("`code'" == "COL") local years "2008 2013 2018"
			else if ("`code'" == "CRI") local years "2008 2013 2018"
			else if ("`code'" == "DOM") local years "2008 2013 2018"
			else if ("`code'" == "ECU") local years "2008 2013 2018"
			else if ("`code'" == "SLV") local years "2008 2013 2018"
			else if ("`code'" == "GTM") local years "2006 2014 2014"
			else if ("`code'" == "HND") local years "2008 2013 2018"
			else if ("`code'" == "MEX") local years "2008 2014 2016"
			else if ("`code'" == "NIC") local years "2009 2014 2014"
			else if ("`code'" == "PAN") local years "2008 2013 2018"
			else if ("`code'" == "PRY") local years "2008 2013 2018"
			else if ("`code'" == "PER") local years "2008 2013 2018"
			else if ("`code'" == "URY") local years "2008 2013 2018"
			else                        local years "`circas'"
		}

		
		if ("`module'" != "gic") { // no years in gic
			desc year*, varlist
			local yv = "`r(varlist)'"
			local n: word count `circas'
			local ys:word count `yv'
			
			* Creates circa variables (circa1 circa2)
			if `ys'>1 {
				foreach s of numlist 1/`ys' {
					if regexm("year`y'", "year([0-9]+)") local s = regexs(1) // year variables suffix	
				}
			}
			else {
				cap confirm var circa
				if (_rc) gen circa = 9999
			}
			
			*For two cross sections (shp drd bde)
			if `ys'>1 { // if more than one year variable
				foreach s of numlist 1(2)`ys' { // variables: year1 circa1 (and if in the future year3, year4)
					cap confirm var circa`s' 
					if (_rc) gen circa`s' = 9999
		
					cap confirm var circa`=`s'+1' 
					if (_rc) gen circa`=`s'+1' = 9999
					
					foreach q of numlist 1(2)`n' { // word 1, 3, 5 of `circas'
						replace circa`s' = `: word `q' of `circas'' /// replace circa1 = word 1 of circas
						if year`s' == `: word `q' of `years'' & year`=`s'+1' == `: word `=`q'+1' of `years'' & country == `country'  // if year1 = (word 1 of `years') & year2 = (word 2 of `years')
						
						replace circa`=`s'+1' = `: word `=`q'+1' of `circas'' /// replace circa2 = word 2 of circas
						if year`s' == `: word `q' of `years'' & year`=`s'+1' == `: word `=`q'+1' of `years'' & country == `country'  // if year1 = (word 1 of `years') & year2 = (word 2 of `years')
	
					} // end of circa replace		
					replace  circa`s'=  9999 if circa`s' == . // why is this necessary?
					replace  circa`=`s'+1'=  9999 if circa`=`s'+1' == . // why is this necessary?
				} // end of variable circa1 circa2 loop
			} // end of if yrs>1
			
			* For cross sections: b40
			else { 
				foreach q of numlist 1/`n' { // word 1, 2, 3 of `circas'
					replace circa = `: word `q' of `circas'' ///
					if year  == `: word `q' of `years'' & country == `country' 
				} // end of q words loop
			} // end of else (cross sections)
		} // end of non gic condition (no years in gic)	
	} // end of countries loop
} // end of circaman
noi di "37: hola"

/*====================================================================
3: Filters for Tableau
====================================================================*/
if "`filter'"!="" {  // 

	cap confirm var country
	if !_rc { // 
		cap confirm var zone {
			if !_rc { // if zone exists !_rc
			* noi di "49: hola"
				drop if country == 32 & zone == 99 // drop ARG National
				drop if country == 32 & zone == 0 // drop ARG Rural
				drop if country == 858 & zone == 99 & year <2006  // drop Uruguay National before 2006
				drop if country == 858 & zone == 0 & year <2006  // drop Uruguay Rural before 2006
				drop if country == 662 & zone!= 99 // St Lucia - keep only national
				
				* Drop urban and rural from LAC and sub regions:
				local subrs "999 1000 1001 1002"
				foreach s of local subrs {
				* noi di "59: hola"
					drop if country == `s' & inlist(zone,0,1)
				} 
				
				
				
				
			} // end if zone exists
			
	} // end zones
	
	} // end country existe
	
* } // end filter

/*====================================================================
4: Other filters
Comparability GIC: 
* Keep last available survey:
Decision NG and LM 04.25.2019: 
1. Leave latest available survey for all except:
2. Brazil: Make 2 Brazils
3. Mexico- Leave 2016 missing
4. ARG? (Keep all for now)
====================================================================*/

if "`comp_gic'"!= "" {
	
	drop 						if (series > 1 & !inlist(country,76,769999,484,32)) // Keep latest available survey
	replace country = 998	    if (country == 76 & "`survey'"=="pnadc")  // if 	(country == 76 & year > 2015)
	replace year = .  			if (country == 484 & year > 2015) // MEX 2016 missing
	
	foreach var in countrycode  countryname countryname_sp { // undo country match for merging with series
		cap drop `var' 
	}	
}


if "`comp_lip'"!= "" {
	replace country = 998	    if (country == 76 & "`survey'"=="pnadc")  // if 	(country == 76 & year > 2015)

	
	foreach var in countrycode  countryname countryname_sp { // undo country match for merging with series
		cap drop `var' 
	}	
}


/*====================================================================
5: Subregional - regional representativity of surveys (For HOI and others)
====================================================================*/
* Using GMD standard regions and sedlac
if ("`reg_represent'" != "") {
	
	if "`gmd'"!= "" {
		local arg_reg "subnatid1" // "region_est2"
		local bol_reg "subnatid1" // "region_est1"
		local bra_reg "subnatid2" // "region_est2"
		local chl_reg "subnatid1" // "region_original" // PRO 2
		local col_reg "subnatid2"  // original not possible
		local cri_reg "subnatid1" // "region_est1"
		local dom_reg "subnatid1" // "region_est1"
		local ecu_reg "subnatid2" // "region_est1"
		local slv_reg "subnatid2" // "region_est2"
		local gtm_reg "subnatid2" // "region_est3" 
		local hti_reg "subnatid2" // "region_est1"
		local hnd_reg "subnatid1" // "domi"
		local mex_reg "subnatid2" // original not possbile
		local nic_reg "subnatid1" // "region_est1"
		local pan_reg "subnatid2" // "region_est2"
		local per_reg "subnatid2" // "region_est1"
		local pry_reg "subnatid1" // "region_est1" - *See note below
		local ury_reg "subnatid1" // "region_est1"
	}
	if "`sedlac'" != "" {
		local arg_reg "region_est2"
		local bol_reg "region_est1"
		local bra_reg "region_est2"
		local chl_reg "region_est1" 
		local col_reg "region_est2"
		local cri_reg "region_est1"
		local dom_reg "region_est1"
		local ecu_reg "region_est1"
		local slv_reg "region_est2"
		local gtm_reg "region_est3"
		local hti_reg "region_est1"
		local hnd_reg "region_est1"
		local mex_reg "region_est2"
		local nic_reg "region_est1"
		local pan_reg "region_est2"
		local pry_reg "region_est1"
		local per_reg "region_est1"
		local ury_reg "region_est1"
	}
	

	levelsof pais, local(paises)
	foreach pais of local paises {
		
			cap confirm string var ``pais'_reg'
			if !_rc { // if string
				noi di "defaults 370 string"
				gen states = real(regexs(1)) if regexm(``pais'_reg',"([0-9]+)")
				* gen aux3 = regexs(1) if regexm(state,"(^[a-z]+)")
				net inst jregex, from("http://wbuchanan.github.io/StataRegex/")
				clonevar state_gmd = ``pais'_reg'
				jregex replace ``pais'_reg', p(`"\d \p{Punct}"') rep(`""')
				*Encode states - var states with state labels
				levelsof ``pais'_reg', local(states)
				foreach state of local states {
					levelsof states if ``pais'_reg' == "`state'", local(x)
					label define state_lab `x' "`state'", modify
					label values states state_lab
					* tempvar aux
					* decode ``pais'_reg', gen(`aux')
					* gen states = `aux'
					
				} // end loop states
			} // end loop if string
			else { // if not string - numeric
				noi di "defaults 388 not string"
				gen states = ``pais'_reg'
			
		*****************************************
				* MEX doesn't have labels for SEDLAC (March 2020) Erase when it's fixed1		
				noi di `"defautls 393: if ("`pais'" == "mex") {"'
				if ("`pais'" == "mex") {
					label define state_lab ///
					1 "Aguascalientes" ///
					2  "Baja California" ///
					3  "Baja California Sur" ///
					4  "Campeche" ///
					5  "Cohauila" ///
					6  "Colima" ///
					7  "Chiapas" ///
					8  "Chihuahua" ///
					9  "Distrito Federal" ///
					10  "Durango" ///
					11  "Guanajuato" ///
					12  "Guerrero" ///
					13  "Hidalgo" ///
					14  "Jalisco" ///
					15  "México" ///
					16  "Michoacán" ///
					17  "Morelos" ///
					18  "Nayarit" ///
					19  "Nuevo León" ///
					20  "Oaxaca" ///
					21  "Puebla" ///
					22  "Querétaro de Arteaga" ///
					23  "Quintana Roo" ///
					24  "San Luis Potosí" ///
					25  "Sinaloa" ///
					26  "Sonora" ///
					27  "Tabasco" ///
					28  "Tamaulipas" ///
					29  "Tlaxcala" ///
					30  "Veracruz-Llave" ///
					31  "Yucatán" ///
					32  "Zacatecas", modify
					label values states state_lab
				} // end loop MEX sedlac
		*******************************************
			} // end loop else	

	} // end loop countries
} // end region representativity	




/*====================================================================
6: Breaks in series
====================================================================*/

/* Series from data comparability excel for Project 3: Z:\public\Stats_Team\LAC Equity Lab\Dashboards\data_availability\Comparability PRO(03)\Comparability_SEDLAC_PR03_v01.xlsx"
Sheet(V1) in wide format
Sheet(Labels series autolel) in long format

*/


if ("`series_breaks'" != "")  {

	tempvar country_decode
	decode countrycode, gen(`country_decode')
	
	cap gen series =.
replace series = 1 if lower(`country_decode') == "arg" & year == 2003
replace series = 1 if lower(`country_decode') == "arg" & year == 2004
replace series = 1 if lower(`country_decode') == "arg" & year == 2005
replace series = 1 if lower(`country_decode') == "arg" & year == 2006
replace series = 1 if lower(`country_decode') == "arg" & year == 2007
replace series = 1 if lower(`country_decode') == "arg" & year == 2008
replace series = 1 if lower(`country_decode') == "arg" & year == 2009
replace series = 1 if lower(`country_decode') == "arg" & year == 2010
replace series = 1 if lower(`country_decode') == "arg" & year == 2011
replace series = 1 if lower(`country_decode') == "arg" & year == 2012
replace series = 1 if lower(`country_decode') == "arg" & year == 2013
replace series = 1 if lower(`country_decode') == "arg" & year == 2014
replace series = 1 if lower(`country_decode') == "arg" & year == 2015
replace series = 1 if lower(`country_decode') == "arg" & year == 2016
replace series = 1 if lower(`country_decode') == "arg" & year == 2017
replace series = 1 if lower(`country_decode') == "arg" & year == 2018
replace series = 2 if lower(`country_decode') == "bol" & year == 2000
replace series = 2 if lower(`country_decode') == "bol" & year == 2001
replace series = 2 if lower(`country_decode') == "bol" & year == 2002
replace series = 1 if lower(`country_decode') == "bol" & year == 2005
replace series = 1 if lower(`country_decode') == "bol" & year == 2006
replace series = 1 if lower(`country_decode') == "bol" & year == 2007
replace series = 1 if lower(`country_decode') == "bol" & year == 2008
replace series = 1 if lower(`country_decode') == "bol" & year == 2009
replace series = 1 if lower(`country_decode') == "bol" & year == 2011
replace series = 1 if lower(`country_decode') == "bol" & year == 2012
replace series = 1 if lower(`country_decode') == "bol" & year == 2013
replace series = 1 if lower(`country_decode') == "bol" & year == 2014
replace series = 1 if lower(`country_decode') == "bol" & year == 2015
replace series = 1 if lower(`country_decode') == "bol" & year == 2016
replace series = 1 if lower(`country_decode') == "bol" & year == 2017
replace series = 1 if lower(`country_decode') == "bol" & year == 2018
replace series = 1 if lower(`country_decode') == "bra" & year == 2001
replace series = 1 if lower(`country_decode') == "bra" & year == 2002
replace series = 1 if lower(`country_decode') == "bra" & year == 2003
replace series = 1 if lower(`country_decode') == "bra" & year == 2004
replace series = 1 if lower(`country_decode') == "bra" & year == 2005
replace series = 1 if lower(`country_decode') == "bra" & year == 2006
replace series = 1 if lower(`country_decode') == "bra" & year == 2007
replace series = 1 if lower(`country_decode') == "bra" & year == 2008
replace series = 1 if lower(`country_decode') == "bra" & year == 2009
replace series = 1 if lower(`country_decode') == "bra" & year == 2011
replace series = 1 if lower(`country_decode') == "bra" & year == 2012
replace series = 1 if lower(`country_decode') == "bra" & year == 2013
replace series = 1 if lower(`country_decode') == "bra" & year == 2014
replace series = 1 if lower(`country_decode') == "bra" & year == 2015
replace series = 1 if lower(`country_decode') == "br2" & year == 2012
replace series = 1 if lower(`country_decode') == "br2" & year == 2013
replace series = 1 if lower(`country_decode') == "br2" & year == 2014
replace series = 1 if lower(`country_decode') == "br2" & year == 2015
replace series = 1 if lower(`country_decode') == "br2" & year == 2016
replace series = 1 if lower(`country_decode') == "br2" & year == 2017
replace series = 1 if lower(`country_decode') == "br2" & year == 2018
replace series = 2 if lower(`country_decode') == "chl" & year == 2000
replace series = 2 if lower(`country_decode') == "chl" & year == 2003
replace series = 1 if lower(`country_decode') == "chl" & year == 2006
replace series = 1 if lower(`country_decode') == "chl" & year == 2009
replace series = 1 if lower(`country_decode') == "chl" & year == 2011
replace series = 1 if lower(`country_decode') == "chl" & year == 2013
replace series = 1 if lower(`country_decode') == "chl" & year == 2015
replace series = 1 if lower(`country_decode') == "chl" & year == 2017
replace series = 1 if lower(`country_decode') == "chl" & year == 2018
replace series = 2 if lower(`country_decode') == "col" & year == 2001
replace series = 2 if lower(`country_decode') == "col" & year == 2002
replace series = 2 if lower(`country_decode') == "col" & year == 2003
replace series = 2 if lower(`country_decode') == "col" & year == 2004
replace series = 2 if lower(`country_decode') == "col" & year == 2005
replace series = 1 if lower(`country_decode') == "col" & year == 2008
replace series = 1 if lower(`country_decode') == "col" & year == 2009
replace series = 1 if lower(`country_decode') == "col" & year == 2010
replace series = 1 if lower(`country_decode') == "col" & year == 2011
replace series = 1 if lower(`country_decode') == "col" & year == 2012
replace series = 1 if lower(`country_decode') == "col" & year == 2013
replace series = 1 if lower(`country_decode') == "col" & year == 2014
replace series = 1 if lower(`country_decode') == "col" & year == 2015
replace series = 1 if lower(`country_decode') == "col" & year == 2016
replace series = 1 if lower(`country_decode') == "col" & year == 2017
replace series = 1 if lower(`country_decode') == "col" & year == 2018
replace series = 2 if lower(`country_decode') == "cri" & year == 1989
replace series = 2 if lower(`country_decode') == "cri" & year == 1990
replace series = 2 if lower(`country_decode') == "cri" & year == 1991
replace series = 2 if lower(`country_decode') == "cri" & year == 1992
replace series = 2 if lower(`country_decode') == "cri" & year == 1993
replace series = 2 if lower(`country_decode') == "cri" & year == 1994
replace series = 2 if lower(`country_decode') == "cri" & year == 1995
replace series = 2 if lower(`country_decode') == "cri" & year == 1996
replace series = 2 if lower(`country_decode') == "cri" & year == 1997
replace series = 2 if lower(`country_decode') == "cri" & year == 1998
replace series = 2 if lower(`country_decode') == "cri" & year == 1999
replace series = 2 if lower(`country_decode') == "cri" & year == 2000
replace series = 2 if lower(`country_decode') == "cri" & year == 2001
replace series = 2 if lower(`country_decode') == "cri" & year == 2002
replace series = 2 if lower(`country_decode') == "cri" & year == 2003
replace series = 2 if lower(`country_decode') == "cri" & year == 2004
replace series = 2 if lower(`country_decode') == "cri" & year == 2005
replace series = 2 if lower(`country_decode') == "cri" & year == 2006
replace series = 2 if lower(`country_decode') == "cri" & year == 2007
replace series = 2 if lower(`country_decode') == "cri" & year == 2008
replace series = 2 if lower(`country_decode') == "cri" & year == 2009
replace series = 1 if lower(`country_decode') == "cri" & year == 2010
replace series = 1 if lower(`country_decode') == "cri" & year == 2011
replace series = 1 if lower(`country_decode') == "cri" & year == 2012
replace series = 1 if lower(`country_decode') == "cri" & year == 2013
replace series = 1 if lower(`country_decode') == "cri" & year == 2014
replace series = 1 if lower(`country_decode') == "cri" & year == 2015
replace series = 1 if lower(`country_decode') == "cri" & year == 2016
replace series = 1 if lower(`country_decode') == "cri" & year == 2017
replace series = 1 if lower(`country_decode') == "cri" & year == 2018
replace series = 3 if lower(`country_decode') == "dom" & year == 2000
replace series = 3 if lower(`country_decode') == "dom" & year == 2001
replace series = 3 if lower(`country_decode') == "dom" & year == 2002
replace series = 3 if lower(`country_decode') == "dom" & year == 2003
replace series = 3 if lower(`country_decode') == "dom" & year == 2004
replace series = 2 if lower(`country_decode') == "dom" & year == 2005
replace series = 2 if lower(`country_decode') == "dom" & year == 2006
replace series = 2 if lower(`country_decode') == "dom" & year == 2007
replace series = 2 if lower(`country_decode') == "dom" & year == 2008
replace series = 2 if lower(`country_decode') == "dom" & year == 2009
replace series = 2 if lower(`country_decode') == "dom" & year == 2010
replace series = 2 if lower(`country_decode') == "dom" & year == 2011
replace series = 2 if lower(`country_decode') == "dom" & year == 2012
replace series = 2 if lower(`country_decode') == "dom" & year == 2013
replace series = 2 if lower(`country_decode') == "dom" & year == 2014
replace series = 2 if lower(`country_decode') == "dom" & year == 2015
replace series = 2 if lower(`country_decode') == "dom" & year == 2016
replace series = 1 if lower(`country_decode') == "dom" & year == 2017
replace series = 1 if lower(`country_decode') == "dom" & year == 2018
replace series = 2 if lower(`country_decode') == "ecu" & year == 2003
replace series = 2 if lower(`country_decode') == "ecu" & year == 2004
replace series = 2 if lower(`country_decode') == "ecu" & year == 2005
replace series = 2 if lower(`country_decode') == "ecu" & year == 2006
replace series = 1 if lower(`country_decode') == "ecu" & year == 2007
replace series = 1 if lower(`country_decode') == "ecu" & year == 2008
replace series = 1 if lower(`country_decode') == "ecu" & year == 2009
replace series = 1 if lower(`country_decode') == "ecu" & year == 2010
replace series = 1 if lower(`country_decode') == "ecu" & year == 2011
replace series = 1 if lower(`country_decode') == "ecu" & year == 2012
replace series = 1 if lower(`country_decode') == "ecu" & year == 2013
replace series = 1 if lower(`country_decode') == "ecu" & year == 2014
replace series = 1 if lower(`country_decode') == "ecu" & year == 2015
replace series = 1 if lower(`country_decode') == "ecu" & year == 2016
replace series = 1 if lower(`country_decode') == "ecu" & year == 2017
replace series = 1 if lower(`country_decode') == "ecu" & year == 2018
replace series = 1 if lower(`country_decode') == "gtm" & year == 2000
replace series = 5 if lower(`country_decode') == "gtm" & year == 2002
replace series = 4 if lower(`country_decode') == "gtm" & year == 2003
replace series = 3 if lower(`country_decode') == "gtm" & year == 2004
replace series = 1 if lower(`country_decode') == "gtm" & year == 2006
replace series = 2 if lower(`country_decode') == "gtm" & year == 2011
replace series = 1 if lower(`country_decode') == "gtm" & year == 2014
replace series = 1 if lower(`country_decode') == "hnd" & year == 2001
replace series = 1 if lower(`country_decode') == "hnd" & year == 2002
replace series = 1 if lower(`country_decode') == "hnd" & year == 2003
replace series = 1 if lower(`country_decode') == "hnd" & year == 2004
replace series = 1 if lower(`country_decode') == "hnd" & year == 2005
replace series = 1 if lower(`country_decode') == "hnd" & year == 2006
replace series = 1 if lower(`country_decode') == "hnd" & year == 2007
replace series = 1 if lower(`country_decode') == "hnd" & year == 2008
replace series = 1 if lower(`country_decode') == "hnd" & year == 2009
replace series = 1 if lower(`country_decode') == "hnd" & year == 2010
replace series = 1 if lower(`country_decode') == "hnd" & year == 2011
replace series = 1 if lower(`country_decode') == "hnd" & year == 2012
replace series = 1 if lower(`country_decode') == "hnd" & year == 2013
replace series = 1 if lower(`country_decode') == "hnd" & year == 2014
replace series = 1 if lower(`country_decode') == "hnd" & year == 2015
replace series = 1 if lower(`country_decode') == "hnd" & year == 2016
replace series = 1 if lower(`country_decode') == "hnd" & year == 2017
replace series = 1 if lower(`country_decode') == "hnd" & year == 2018
replace series = 1 if lower(`country_decode') == "hti" & year == 2012
replace series = 1 if lower(`country_decode') == "lac" & year == 1995
replace series = 1 if lower(`country_decode') == "lac" & year == 1996
replace series = 1 if lower(`country_decode') == "lac" & year == 1997
replace series = 1 if lower(`country_decode') == "lac" & year == 1998
replace series = 1 if lower(`country_decode') == "lac" & year == 1999
replace series = 1 if lower(`country_decode') == "lac" & year == 2000
replace series = 1 if lower(`country_decode') == "lac" & year == 2001
replace series = 1 if lower(`country_decode') == "lac" & year == 2002
replace series = 1 if lower(`country_decode') == "lac" & year == 2003
replace series = 1 if lower(`country_decode') == "lac" & year == 2004
replace series = 1 if lower(`country_decode') == "lac" & year == 2005
replace series = 1 if lower(`country_decode') == "lac" & year == 2006
replace series = 1 if lower(`country_decode') == "lac" & year == 2007
replace series = 1 if lower(`country_decode') == "lac" & year == 2008
replace series = 1 if lower(`country_decode') == "lac" & year == 2009
replace series = 1 if lower(`country_decode') == "lac" & year == 2010
replace series = 1 if lower(`country_decode') == "lac" & year == 2011
replace series = 1 if lower(`country_decode') == "lac" & year == 2012
replace series = 1 if lower(`country_decode') == "lac" & year == 2013
replace series = 1 if lower(`country_decode') == "lac" & year == 2014
replace series = 1 if lower(`country_decode') == "lac" & year == 2015
replace series = 1 if lower(`country_decode') == "lac" & year == 2016
replace series = 1 if lower(`country_decode') == "lac" & year == 2017
replace series = 1 if lower(`country_decode') == "lac" & year == 2018
replace series = 1 if lower(`country_decode') == "lca" & year == 2016
replace series = 3 if lower(`country_decode') == "mex" & year == 1989
replace series = 3 if lower(`country_decode') == "mex" & year == 1992
replace series = 3 if lower(`country_decode') == "mex" & year == 1994
replace series = 3 if lower(`country_decode') == "mex" & year == 1996
replace series = 3 if lower(`country_decode') == "mex" & year == 1998
replace series = 2 if lower(`country_decode') == "mex" & year == 2000
replace series = 2 if lower(`country_decode') == "mex" & year == 2002
replace series = 2 if lower(`country_decode') == "mex" & year == 2004
replace series = 2 if lower(`country_decode') == "mex" & year == 2005
replace series = 2 if lower(`country_decode') == "mex" & year == 2006
replace series = 2 if lower(`country_decode') == "mex" & year == 2008
replace series = 2 if lower(`country_decode') == "mex" & year == 2010
replace series = 2 if lower(`country_decode') == "mex" & year == 2012
replace series = 2 if lower(`country_decode') == "mex" & year == 2014
replace series = 1 if lower(`country_decode') == "mex" & year == 2016
replace series = 1 if lower(`country_decode') == "mex" & year == 2018
replace series = 2 if lower(`country_decode') == "nic" & year == 2001
replace series = 1 if lower(`country_decode') == "nic" & year == 2005
replace series = 1 if lower(`country_decode') == "nic" & year == 2009
replace series = 1 if lower(`country_decode') == "nic" & year == 2014
replace series = 3 if lower(`country_decode') == "pan" & year == 1989
replace series = 3 if lower(`country_decode') == "pan" & year == 1991
replace series = 2 if lower(`country_decode') == "pan" & year == 1995
replace series = 2 if lower(`country_decode') == "pan" & year == 1997
replace series = 2 if lower(`country_decode') == "pan" & year == 1998
replace series = 2 if lower(`country_decode') == "pan" & year == 1999
replace series = 2 if lower(`country_decode') == "pan" & year == 2000
replace series = 2 if lower(`country_decode') == "pan" & year == 2001
replace series = 2 if lower(`country_decode') == "pan" & year == 2002
replace series = 2 if lower(`country_decode') == "pan" & year == 2003
replace series = 2 if lower(`country_decode') == "pan" & year == 2004
replace series = 2 if lower(`country_decode') == "pan" & year == 2005
replace series = 2 if lower(`country_decode') == "pan" & year == 2006
replace series = 2 if lower(`country_decode') == "pan" & year == 2007
replace series = 1 if lower(`country_decode') == "pan" & year == 2008
replace series = 1 if lower(`country_decode') == "pan" & year == 2009
replace series = 1 if lower(`country_decode') == "pan" & year == 2010
replace series = 1 if lower(`country_decode') == "pan" & year == 2011
replace series = 1 if lower(`country_decode') == "pan" & year == 2012
replace series = 1 if lower(`country_decode') == "pan" & year == 2013
replace series = 1 if lower(`country_decode') == "pan" & year == 2014
replace series = 1 if lower(`country_decode') == "pan" & year == 2015
replace series = 1 if lower(`country_decode') == "pan" & year == 2016
replace series = 1 if lower(`country_decode') == "pan" & year == 2017
replace series = 1 if lower(`country_decode') == "pan" & year == 2018
replace series = 2 if lower(`country_decode') == "per" & year == 1997
replace series = 2 if lower(`country_decode') == "per" & year == 1998
replace series = 2 if lower(`country_decode') == "per" & year == 1999
replace series = 2 if lower(`country_decode') == "per" & year == 2000
replace series = 2 if lower(`country_decode') == "per" & year == 2001
replace series = 2 if lower(`country_decode') == "per" & year == 2002
replace series = 2 if lower(`country_decode') == "per" & year == 2003
replace series = 1 if lower(`country_decode') == "per" & year == 2004
replace series = 1 if lower(`country_decode') == "per" & year == 2005
replace series = 1 if lower(`country_decode') == "per" & year == 2006
replace series = 1 if lower(`country_decode') == "per" & year == 2007
replace series = 1 if lower(`country_decode') == "per" & year == 2008
replace series = 1 if lower(`country_decode') == "per" & year == 2009
replace series = 1 if lower(`country_decode') == "per" & year == 2010
replace series = 1 if lower(`country_decode') == "per" & year == 2011
replace series = 1 if lower(`country_decode') == "per" & year == 2012
replace series = 1 if lower(`country_decode') == "per" & year == 2013
replace series = 1 if lower(`country_decode') == "per" & year == 2014
replace series = 1 if lower(`country_decode') == "per" & year == 2015
replace series = 1 if lower(`country_decode') == "per" & year == 2016
replace series = 1 if lower(`country_decode') == "per" & year == 2017
replace series = 1 if lower(`country_decode') == "per" & year == 2018
replace series = 4 if lower(`country_decode') == "pry" & year == 1997
replace series = 3 if lower(`country_decode') == "pry" & year == 1999
replace series = 2 if lower(`country_decode') == "pry" & year == 2001
replace series = 1 if lower(`country_decode') == "pry" & year == 2002
replace series = 1 if lower(`country_decode') == "pry" & year == 2003
replace series = 1 if lower(`country_decode') == "pry" & year == 2004
replace series = 1 if lower(`country_decode') == "pry" & year == 2005
replace series = 1 if lower(`country_decode') == "pry" & year == 2006
replace series = 1 if lower(`country_decode') == "pry" & year == 2007
replace series = 1 if lower(`country_decode') == "pry" & year == 2008
replace series = 1 if lower(`country_decode') == "pry" & year == 2009
replace series = 1 if lower(`country_decode') == "pry" & year == 2010
replace series = 1 if lower(`country_decode') == "pry" & year == 2011
replace series = 1 if lower(`country_decode') == "pry" & year == 2012
replace series = 1 if lower(`country_decode') == "pry" & year == 2013
replace series = 1 if lower(`country_decode') == "pry" & year == 2014
replace series = 1 if lower(`country_decode') == "pry" & year == 2015
replace series = 1 if lower(`country_decode') == "pry" & year == 2016
replace series = 1 if lower(`country_decode') == "pry" & year == 2017
replace series = 1 if lower(`country_decode') == "pry" & year == 2018
replace series = 1 if lower(`country_decode') == "slv" & year == 2000
replace series = 1 if lower(`country_decode') == "slv" & year == 2001
replace series = 1 if lower(`country_decode') == "slv" & year == 2002
replace series = 1 if lower(`country_decode') == "slv" & year == 2003
replace series = 1 if lower(`country_decode') == "slv" & year == 2004
replace series = 1 if lower(`country_decode') == "slv" & year == 2005
replace series = 1 if lower(`country_decode') == "slv" & year == 2006
replace series = 1 if lower(`country_decode') == "slv" & year == 2007
replace series = 1 if lower(`country_decode') == "slv" & year == 2008
replace series = 1 if lower(`country_decode') == "slv" & year == 2009
replace series = 1 if lower(`country_decode') == "slv" & year == 2010
replace series = 1 if lower(`country_decode') == "slv" & year == 2011
replace series = 1 if lower(`country_decode') == "slv" & year == 2012
replace series = 1 if lower(`country_decode') == "slv" & year == 2013
replace series = 1 if lower(`country_decode') == "slv" & year == 2014
replace series = 1 if lower(`country_decode') == "slv" & year == 2015
replace series = 1 if lower(`country_decode') == "slv" & year == 2016
replace series = 1 if lower(`country_decode') == "slv" & year == 2017
replace series = 1 if lower(`country_decode') == "slv" & year == 2018
replace series = 2 if lower(`country_decode') == "ury" & year == 1992
replace series = 2 if lower(`country_decode') == "ury" & year == 1995
replace series = 2 if lower(`country_decode') == "ury" & year == 1996
replace series = 2 if lower(`country_decode') == "ury" & year == 1997
replace series = 2 if lower(`country_decode') == "ury" & year == 1998
replace series = 2 if lower(`country_decode') == "ury" & year == 2000
replace series = 2 if lower(`country_decode') == "ury" & year == 2001
replace series = 2 if lower(`country_decode') == "ury" & year == 2002
replace series = 2 if lower(`country_decode') == "ury" & year == 2003
replace series = 2 if lower(`country_decode') == "ury" & year == 2004
replace series = 2 if lower(`country_decode') == "ury" & year == 2005
replace series = 1 if lower(`country_decode') == "ury" & year == 2006
replace series = 1 if lower(`country_decode') == "ury" & year == 2007
replace series = 1 if lower(`country_decode') == "ury" & year == 2008
replace series = 1 if lower(`country_decode') == "ury" & year == 2009
replace series = 1 if lower(`country_decode') == "ury" & year == 2010
replace series = 1 if lower(`country_decode') == "ury" & year == 2011
replace series = 1 if lower(`country_decode') == "ury" & year == 2012
replace series = 1 if lower(`country_decode') == "ury" & year == 2013
replace series = 1 if lower(`country_decode') == "ury" & year == 2014
replace series = 1 if lower(`country_decode') == "ury" & year == 2015
replace series = 1 if lower(`country_decode') == "ury" & year == 2016
replace series = 1 if lower(`country_decode') == "ury" & year == 2017
replace series = 1 if lower(`country_decode') == "ury" & year == 2018




	
}

*--------------------3.1:
*--------------------3.2:


end


exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1. Subnational representativeness: PRY although excel says rep at subnatid2, region 8 has 67 obs for 2014, so we use subnatid1
2.
3.


Version Control:


