
/*====================================================================
project:       AUTO LEL -- countries codes and names
Author:        Andres Castaneda
Dependencies:  The World Bank
----------------------------------------------------------------------
Creation Date:      22 Aug 2017 
Do-file version:    01
References:
Output:             
====================================================================*/


program define autolel_countrylist, rclass
syntax [anything(name=code)]

qui {
	tempname cl
	tempfile countrylist 
	
	postfile `cl' str52(countryname countryname_sp) str3 countrycode int iso3n ///
	using `countrylist', replace
	
	post `cl' ("Aruba"                         ) ("Aruba"                         ) ("ABW") (533)  
	post `cl' ("Argentina (urban)"             ) ("Argentina (urbano)"            ) ("ARG") ( 32)  
	post `cl' ("Antigua and Barbuda"           ) ("Antigua y Barbuda"             ) ("ATG") ( 28)  
	post `cl' ("Bahamas, The"                  ) ("Bahamas, Las"                  ) ("BHS") ( 44)  
	post `cl' ("Belize"                        ) ("Belise"                        ) ("BLZ") ( 84)  
	post `cl' ("Bolivia"                       ) ("Bolivia"                       ) ("BOL") ( 68)  
	post `cl' ("Brazil"                        ) ("Brasil"                        ) ("BRA") ( 76) 
	post `cl' ("Brazil-PNADC" 				   ) ("Brasil-PNADC"    			  ) ("BR2") (998) 	
	post `cl' ("Barbados"                      ) ("Barbados"                      ) ("BRB") ( 52)  
	post `cl' ("Chile"                         ) ("Chile"                         ) ("CHL") (152)  
	post `cl' ("Colombia"                      ) ("Colombia"                      ) ("COL") (170)  
	post `cl' ("Costa Rica"                    ) ("Costa Rica"                    ) ("CRI") (188)  
	post `cl' ("Cuba"                          ) ("Cuba"                          ) ("CUB") (192)  
	post `cl' ("Cayman Islands"                ) ("Islas Caimán"                  ) ("CYM") (136)  
	post `cl' ("Dominica"                      ) ("Dominica"                      ) ("DMA") (212)  
	post `cl' ("Dominican Republic"            ) ("República Dominicana"          ) ("DOM") (214)  
	post `cl' ("Ecuador"                       ) ("Ecuador"                       ) ("ECU") (218)  
	post `cl' ("Grenada"                       ) ("Grenada"                       ) ("GRD") (308)  
	post `cl' ("Guatemala"                     ) ("Guatemala"                     ) ("GTM") (320)	
	post `cl' ("Guyana"                        ) ("Guyana"                        ) ("GUY") (328)  
	post `cl' ("Honduras"                      ) ("Honduras"                      ) ("HND") (340)  
	post `cl' ("Haiti"                         ) ("Haiti"                         ) ("HTI") (332)  
	post `cl' ("Jamaica"                       ) ("Jamáica"                       ) ("JAM") (388)  
	post `cl' ("St. Kitts and Nevis"           ) ("St. Kitts y Nevis"             ) ("KNA") (659)  
	post `cl' ("St. Lucia"                     ) ("St. Lucia"                     ) ("LCA") (662)  
	post `cl' ("Mexico"                        ) ("México"                        ) ("MEX") (484)  
	post `cl' ("Nicaragua"                     ) ("Nicaragua"                     ) ("NIC") (558)  
	post `cl' ("Panama"                        ) ("Panamá"                        ) ("PAN") (591)  
	post `cl' ("Peru"                          ) ("Perú"                          ) ("PER") (604)  
	post `cl' ("Puerto Rico"                   ) ("Puerto Rico"                   ) ("PRI") (630)  
	post `cl' ("Paraguay"                      ) ("Paraguay"                      ) ("PRY") (600)  
	post `cl' ("El Salvador"                   ) ("El Salvador"                   ) ("SLV") (222)  
	post `cl' ("Suriname"                      ) ("Surinam"                       ) ("SUR") (740)  
	post `cl' ("Turks and Caicos Islands"      ) ("Islas Turcas y Caicos"         ) ("TCA") (796)  
	post `cl' ("Trinidad and Tobago"           ) ("Trinidad y Tobago"             ) ("TTO") (780)  
	post `cl' ("Uruguay"                       ) ("Uruguay"                       ) ("URY") (858)  
	post `cl' ("St. Vincent and the Grenadines") ("St. Vincent y the Grenadines"  ) ("VCT") (670)  
	post `cl' ("Venezuela, RB"                 ) ("Venezuela, RB"                 ) ("VEN") (862)  
	post `cl' ("Virgin Islands (U.S.)"         ) ("Islas Vírgenes (U.S.)"         ) ("VIR") (850)  
	post `cl' ("Central America"               ) ("América Central"               ) ("CAR") (1000)  
	post `cl' ("Andean Region"                 ) ("Región Andina"                 ) ("ANR") (1001)  
	post `cl' ("South Cone"                    ) ("Cono Sur"                      ) ("SCR") (1002)  
	post `cl' ("Latin America & the Caribbean" ) ("América Latina y el Caribe"    ) ("LAC") (999)  
	
	postclose `cl'
	preserve 
	use `countrylist', clear
	
	varlocal countryname countryname_sp, separate(;)
	
	local nameslist = `" "`r(countryname)'" "'
	local nameslist: subinstr local nameslist ";" `"" ""', all
	return local nameslist = `"`nameslist'"'
	
	local nameslist_sp = `" "`r(countryname_sp)'" "'
	local nameslist_sp: subinstr local nameslist_sp ";" `"" ""', all
	return local nameslist_sp = `"`nameslist_sp'"'
	
	varlocal countrycode iso3n	
	return local codeslist = "`r(countrycode)'"
	return local iso3list  = "`r(iso3n)'"
	
	if ("`code'" != "") {
		if regexm(`"`code'"', "^[0-9]+$") {
			keep if iso3n == `code' 
		}
		else {
			if length(`"`code'"') == 3 {
				local code = upper(`"`code'"')
				keep if countrycode == `"`code'"'
			}
			else keep if countryname == `"`code'"'
		}
		
		count 
		if r(N) == 0 {
			noi disp in red "`code' is not a valid code"
			error
		}
	noi list 
	
	return local countrycode  = countrycode[1]
	return local countryname  = countryname[1]
	return local countryiso3n = iso3n[1]
	}
	
}
restore 

end 

exit 

/* End of do-file */
><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1. How to use the results
autolel_countrylist
local a  = "`r(codeslist)'"
local b  = "`r(iso3list)'"
local w : list posof "BRA" in a
disp word("`b'", `w')
2.
3.


Version Control:



