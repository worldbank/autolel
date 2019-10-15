
/*====================================================================
project:       AUTO LEL 
Author:        Natalia Garcia-Peña Bersh

Dependencies:  The World Bank
----------------------------------------------------------------------
Creation Date:      08/23/2018
Modification Date:  04/02/2019
Do-file version:    01
References:
Output:             
====================================================================*/

program define autolel_eho, rclass
syntax, [path(string)] 

tempname main_mat_eho

if "`path'"!="" {
	local path "`path'"
}
else {
	local path "Z:\public\Stats_Team\LAC Equity Lab\Auto-LEL\LEL_Ouput"
}


local topics "pov ine shp"
clear
tempfile c
save `c', replace empty

foreach topic of local topics {
	drop _all
	use "`path'\\`topic'"
	foreach i in indicator indicator_sp {
		rename `i' ind
		decode ind, gen(`i') // They have to be string, or else it uses shp labels for indicators
		drop ind
	}
	gen topic = "`topic'"
	append using `c'
	save `c', replace

}


* Relabel countries (issue with new label for ARG urban)

autolel_countrylist
		local codeslist      = "`r(codeslist)'"
		local iso3list       = "`r(iso3list)'"
		local nameslist      = `"`r(nameslist)'"'
		local nameslist_sp   = `"`r(nameslist_sp)'"'
		local countries      = upper("`countries'")
		
		local i = 0
		foreach code of local codeslist {
			local ++i 
			local name    : word `i' of `nameslist'
			local name_sp : word `i' of `nameslist_sp'
			local iso3    : word `i' of `iso3list'
			label define countrycode    `iso3' `"`code'"', modify 
			label define countryname    `iso3' `"`name'"', modify 
			label define countryname_sp `iso3' `"`name_sp'"', modify 
		}
		

save "`path'\\eho.dta", replace
export delimited using "`path'\\eho.txt", delimit(";") replace

noi disp in w "The file eho.dta has been replaced in the following path:`path'"


end
exit

*************************************************************
























end
exit

******************************************************************
* Version 08/21/2017



/*********************************************************************
->LEL Dashboards: External Website Homepage
Overvew Poverty, ShP, Inequality
Author: Giselle Del Carmen								
Modified: Andres Castaneda		
Original version:  12/09/2013	      
Moidified version: 09/09/2014	(Giselle Del Carmen) 		
Moidified version: 08/21/2017	(Andres Castaneda)	
Modified version: 08/23/2018	(Natalia Garcia Peña)		

*********************************************************************/

program define autolel_eho

qui {
	drop _all
	* Generate tempfiles
	tempfile aux1 aux2 aux3
	
	
	*-----------------*
	* (1) Inequality:
	*-----------------*
	use "${output_LEL}\ine.dta", clear
	
	keep if indicator == "Gini coefficient"
	rename indicator universe
	gen indicator = "Inequality"
	tostring circa, replace
	
	keep country circa year indicator universe rate
	save `aux1'
	
	*----------------------*
	* (2)Shared Prosperity
	*----------------------*
	
	use "${output_LEL}\shp.dta", clear
	
	gen decomp = strofreal(year1)+"-"+strofreal(year2)
	gen circa  = strofreal(round(year1, 5))+"-"+strofreal(round(year2, 5))
	
	
	rename indicator universe
	replace universe = "Annualized growth rate bottom 40%" ///
	if universe == "Growth bottom 40"
	replace universe = "Annualized growth rate overall population" ///
	if universe == " Growth total population"
	
	gen indicator = "Shared Prosperity"
	
	keep country circa decomp indicator universe rate
	
	* Save
	save `aux2'
	
	
	*-----------------*
	* (3) Poverty
	*-----------------*
	
	use "${output_LEL}\pov.dta", clear
	
	* Rename
	rename pline universe
	rename indicator measure
	tostring circa, replace
	
	* Indicator
	gen indicator = "Poverty"
	
	* Order variables
	keep  country year circa indicator universe measure rate
	order country year circa indicator universe measure rate
	
	
	drop if indicator == ""
	drop if measure == ""
	
	* Save
	save `aux3'
	
	use `aux1', clear
	
	append using `aux2', force
	append using `aux3', force 
	
	
	*labels for Tableau
	label var year      "Year"
	label var circa     "Circa"
	label var indicator "Indicator"
	label var universe  "Universe"
	label var country   "Country"
	
	* Fixing data
	autolel_labels, countries
	
	
	* Edit country names
	label var countryname    "Country name"
	label var countryname_sp "Nombre del País"
	decode countrycode, gen(countrystr)
	
	
	*Create regions for map overview
	gen subregion = ""
	replace subregion = "Andean Region" if inlist(countrystr, ///
	"BOL", "COL", "ECU", "PER")  
	
	replace subregion = "Central America, the Caribbean and Mexico " if ///
	inlist(countrystr, "CRI", "DOM", "SLV",  "HND", "MEX", "PAN",  "NIC", ///
	"GTM", "HTI")   
	
	replace subregion = "Southern Cone" if inlist(countrystr, ///
	"ARG", "BRA", "CHL", "PRY", "URY")  
	
	clonevar subregion_sp = subregion
	label var subregion_sp  "Subregión"
	
	replace subregion_sp = "Region Andina" if subregion_sp=="Andean Region"
	replace subregion_sp = "Cono Sur" if subregion_sp=="Southern Cone"
	replace subregion_sp = "Centro America, el Cariba y Mexico" if subregion_sp=="Central America, the Caribbean and Mexico"
	
	**Spanish translations
	clonevar country_sp = countrystr
	
	*Indicators
	gen indicador_sp = cond(indicator == "Inequality", "Desigualdad", ///
	cond(indicator == "Poverty"   , "Pobreza",   ///
	"Prosperidad Compartida"))
	
	*clone spanish variables
	clonevar universe_sp = universe
	clonevar measure_sp = measure
	
	label var universe_sp   "Universo"
	label var rate          "Rate"
	label var measure       "measure"
	label var measure_sp    "Medida"
	label var subregion     "Subregion"
	
	replace measure_sp = "Brecha de la pobreza" if measure_sp=="Poverty gap"
	replace measure_sp = "Severidad de la pobreza" if measure_sp=="Poverty severity"
	replace measure_sp = "Tasa de incidencia de la pobreza" if measure_sp=="Poverty rate"
	
	**Inequality
	replace universe_sp = "Coeficiente de Gini" if universe_sp == "Gini coefficient"  
	
	**Poverty
	replace universe_sp = "Pobreza $2.50 (2005PPP)" if universe == "Poverty $2.50 (2005PPP)"  
	replace universe_sp = "Pobreza $1.90 (2011PPP)" if universe == "Poverty $1.90 (2011PPP)" 
	replace universe_sp = "Clase Media $10-$50 (2005PPP)" if universe == "Middle Class $10-$50 (2005PPP)"  
	replace universe_sp = "Pobreza $4 (2005PPP)" if universe == "Poverty $4 (2005PPP)"  
	replace universe_sp = "Población Vulnerable $4-$10 (2005PPP)" if universe == "Vulnerable $4-$10 (2005PPP)" 
	
	**Shared Prosperity
	replace universe_sp = "Tasa anualizada de crecimiento del 40% mas pobre de la poblacion" if universe_sp == "Annualized growth rate bottom 40%" 
	replace universe_sp = "Tasa anualizada de crecimiento del ingreso medio" if universe_sp == "Annualized growth rate overall population" 
	
	
	gen universe_tooltip = ""
	
	replace universe_tooltip = "annualized growth rate of the bottom 40%" if universe == "Annualized growth rate bottom 40%"
	replace universe_tooltip = "annualized growth rate of the overall population" if universe == "Growth total population"
	replace universe_tooltip = "Gini coefficient" if universe == "Gini coefficient"
	replace universe_tooltip = "Middle Class $10-$50 (2005 PPP)" if universe == "Middle Class $10-$50 (2005 PPP)"
	replace universe_tooltip = "Global Extreme Poor $1.90 (2011 PPP)" if universe == "Poverty $1.9 (2011 PPP)"
	replace universe_tooltip = "Extreme Poor $2.50 (2005 PPP)" if universe == "Poverty $2.5 (2005 PPP)"
	replace universe_tooltip = "Poor $4 (2005 PPP)" if universe == "Poverty $4 (2005 PPP)"
	replace universe_tooltip = "Poor $3.2 (2011 PPP)" if universe == "Poverty $3.2 (2011 PPP)"
	replace universe_tooltip = "Poor $5.5 (2011 PPP)" if universe == "Poverty $5.5 (2011 PPP)"
	replace universe_tooltip = "Vulnerable $4-$10 (2005 PPP)" if universe == "Vulnerable $4-$10 (2005 PPP)"
	
	noi tab circa 
	
	drop if countrystr == ""
	
	
}

end 

exit 
