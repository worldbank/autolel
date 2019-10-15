*! ver 0.1 <14 oct 2017>
*===============================================================================
* LABELS 
* First version: 23/MAY/2017 --- Carlos Felipe Balcazar
* update: Aug/2017 --- Andres Castaneda

cap program drop  autolel_labels
program define autolel_labels
syntax, [ countries module(string)]  

quietly {

	* Country ISO3 labels
	if ("`countries'" != "") {
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
		
		foreach var in countrycode  countryname countryname_sp {
			cap drop `var' 
			clonevar `var' = country
			label values `var' `var'   
		}
		
		
		cap confirm numeric variable zone 
		if (_rc == 0) {
			cap gen area_en = ""
			replace area_en = "Urban"    if zone==1
			replace area_en = "Rural"    if zone==0	
			replace area_en = "National" if zone==99	
			
			cap gen area_sp = ""
			replace area_sp = "Urbano"   if  zone==1
			replace area_sp = "Rural"    if  zone==0	
			replace area_sp = "Nacional" if  zone==99	
		}
	}
	
	*===============================================================================
	* LABELS: POVERTY 
	
	if ("`module'" != "") {
		
		if "`module'"=="pov" | "`module'"=="pov_reg" {
			clonevar indicator_sp=indicator // In spanish
			clonevar pline_sp=pline
			local renvars indicator pline
			
			
			label define indicator 			///
			0 "Poverty rate" 			///
			1 "Poverty gap"					///
			2 "Poverty severity"	, modify			
			label values indicator indicator
			
			label define pline                           ///
			125     "Poverty $1.25 (2005 PPP)"           ///
			190     "Poverty $1.9 (2011 PPP)"            ///
			320     "Poverty $3.2 (2011 PPP)"            ///
			550     "Poverty $5.5 (2011 PPP)"            ///
			250     "Poverty $2.5 (2005 PPP)"            ///
			400     "Poverty $4 (2005 PPP)"              ///
			4001000  "Vulnerable $4-$10 (2005 PPP)"      ///
			10005000 "Middle Class $10-$50 (2005 PPP)"   ///
			5501300  "Vulnerable $5.5-$13 (2011 PPP)"    ///
			13007000 "Middle Class $13-$70 (2011 PPP)", modify
			
			label values pline pline
			label var pline "Poverty Status"
			
			label define indicator_sp 			///
			0 "Tasa de pobreza" 			///
			1 "Brecha de pobreza"					///
			2 "Severidad de la pobreza"	, modify			
			label values indicator_sp indicator_sp
			
			label define pline_sp                          ///
			125     "Pobreza $1.25 (2005 PPP)"              ///
			190     "Pobreza $1.9 (2011 PPP)"                ///
			320     "Pobreza $3.2 (2011 PPP)"        ///
			550     "Pobreza $5.5 (2011 PPP)"                ///
			250     "Pobreza $2.5 (2005 PPP)"        ///
			400     "Pobreza $4 (2005 PPP)"                  ///
			4001000  "Vulnerable $4-$10 (2005 PPP)"        ///
			10005000 "Clase media $10-$50 (2005 PPP)"      ///
			5501300  "Vulnerable $5.5-$13 (2011 PPP)"      ///
			13007000 "Clase media $13-$70 (2011 PPP)", modify
			
			label values pline_sp pline_sp
			label var pline_sp "Estado de pobreza"
			
		} // end of poverty labels
		*===============================================================================
		* LABELS: DATT-RAVALLION
		if "`module'"=="drd" {
			clonevar indicator_sp=indicator // In spanish
			clonevar pline_sp=pline
			clonevar component_sp = component
			local renvars indicator pline
			
			label define indicator 			///
			0 "Poverty rate" 			///
			1 "Poverty gap"					///
			2 "Poverty severity"	, modify			
			label values indicator indicator
			
			label define pline                           ///
			125     "Poverty $1.25 (2005 PPP)"           ///
			190     "Poverty $1.9 (2011 PPP)"            ///
			320     "Poverty $3.2 (2011 PPP)"            ///
			550     "Poverty $5.5 (2011 PPP)"            ///
			250     "Poverty $2.5 (2005 PPP)"            ///
			400     "Poverty $4 (2005 PPP)"              ///
			1000  "Vulnerable $4-$10 (2005 PPP)"      ///
			5000 "Middle Class $10-$50 (2005 PPP)"   ///
			1300  "Vulnerable $5.5-$13 (2011 PPP)"    ///
			7000 "Middle Class $13-$70 (2011 PPP)", modify
			
			label values pline pline
			label var pline "Poverty Status"
			
			label define indicator_sp 			///
			0 "Tasa de pobreza" 			///
			1 "Brecha de pobreza"					///
			2 "Severidad de la pobreza"	, modify			
			label values indicator_sp indicator_sp
			
			label define pline_sp                          ///
			125     "Pobreza $1.25 (2005 PPP)"              ///
			190     "Pobreza $1.9 (2011 PPP)"                ///
			320     "Pobreza $3.2 (2011 PPP)"        ///
			550     "Pobreza $5.5 (2011 PPP)"                ///
			250     "Pobreza $2.5 (2005 PPP)"        ///
			400     "Pobreza $4 (2005 PPP)"                  ///
			1000  "Vulnerable $4-$10 (2005 PPP)"        ///
			5000 "Clase media $10-$50 (2005 PPP)"      ///
			1300  "Vulnerable $5.5-$13 (2011 PPP)"      ///
			7000 "Clase media $13-$70 (2011 PPP)", modify
			
			label values pline_sp pline_sp
			label var pline_sp "Estado de pobreza"
					
			label define component 			///
			0 "Growth" ///
			1 "Redistribution" ///
			2 "Total" , modify 
			label values component component
			
			label define component_sp 			///
			0 "Crecimiento" ///
			1 "Redistribución" ///
			2 "Total" , modify 
			label values component_sp component_sp
			
			
			
			
			/* 
			
			label define pline  ///
			1 "Poor($1.9USD a day)" ///
			2 "Extreme Poor($2.5USD a day)" ///
			4 "Poor($4USD a day)", modify
			label values pline pline
			
			
			
			label define pline_sp  ///
			1 "Pobre($1.9USD a day)" ///
			2 "Pobreza extrema($2.5USD al dia)" ///
			4 "Pobre($4USD al dia)", modify
			label values pline_sp pline_sp
			
			label define indicator 			///
			0 "Redistribution" ///
			1 "Growth" ///
			2 "Total" , modify 
			label values indicator indicator
			
			label define indicator_sp 			///
			0 "Redistribucion" ///
			1 "Crecimiento" ///
			2 "Total" , modify 
			label values indicator_sp indicator_sp
			
			
			*/
		} // end of datt-ravallion labels
		*===============================================================================
		* LABELS: BARROS
		if "`module'"=="bde" {
			gen gender="Other components"
			replace gender="Men" 		if inlist(component,1,2)
			replace gender="Women" 		if inlist(component,3,4)
			
			clonevar gender_sp=gender
			replace gender_sp="Hombre" 	if gender=="Men"
			replace gender_sp="Mujer" 	if gender=="Women"
			
			
			gen indicator=""
			replace indicator="Share who are employed" if inlist(component,1,3,8)
			replace indicator="Labor earnings" if inlist(component,2,4,9)
			replace indicator="Other non-labor income" if inlist(component,5,14) 
			replace indicator="Share of individuals 15-69 years of age" if inlist(component,6,10)
			replace indicator="Total" if inlist(component,7,15)
			
			replace indicator = "Remittances" if component == 11
			replace indicator = "Public transfers" if component == 12
			replace indicator = "Retirement and pensions" if component == 13
			
			clonevar indicator_sp=indicator
			replace indicator_sp="Porcentaje de empleados" if inlist(component,1,3,8)
			replace indicator_sp="Ingresos laborales" if inlist(component,2,4,9)
			replace indicator_sp="Ingreso no laboral" if inlist(component,5,14) 
			replace indicator_sp="Porcentaje de individuos 15-69 años de edad" if inlist(component,6,10)
			replace indicator_sp="Total" if inlist(component,7,15)
			
			replace indicator_sp = "Remesas" if component == 11
			replace indicator_sp = "Transferencias estatales" if component == 12
			replace indicator_sp = "Jubilaciones y pensiones" if component == 13
			
			
			clonevar pline_sp=pline // In spanish
			clonevar component_sp=component // In spanish
			clonevar pov_ind_sp=pov_ind // In spanish
			clonevar component_n = component
			clonevar dtype_sp = dtype
			local renvars component pov_ind pline
			
			label define pline                           ///
			125     "Poverty $1.25 (2005 PPP)"           ///
			190     "Poverty $1.9 (2011 PPP)"            ///
			320     "Poverty $3.2 (2011 PPP)"            ///
			550     "Poverty $5.5 (2011 PPP)"            ///
			250     "Poverty $2.5 (2005 PPP)"            ///
			400     "Poverty $4 (2005 PPP)"              ///
			4001000  "Vulnerable $4-$10 (2005 PPP)"      ///
			10005000 "Middle Class $10-$50 (2005 PPP)"   ///
			5501300  "Vulnerable $5.5-$13 (2011 PPP)"    ///
			13007000 "Middle Class $13-$70 (2011 PPP)", modify
			
						label values pline pline
			label var pline "Poverty Status"
			
			label define pline_sp                          ///
			125     "Pobreza $1.25 (2005 PPP)"              ///
			190     "Pobreza $1.9 (2011 PPP)"                ///
			320     "Pobreza $3.2 (2011 PPP)"        ///
			550     "Pobreza $5.5 (2011 PPP)"                ///
			250     "Pobreza $2.5 (2005 PPP)"        ///
			400     "Pobreza $4 (2005 PPP)"                  ///
			4001000  "Vulnerable $4-$10 (2005 PPP)"        ///
			10005000 "Clase media $10-$50 (2005 PPP)"      ///
			5501300  "Vulnerable $5.5-$13 (2011 PPP)"      ///
			13007000 "Clase media $13-$70 (2011 PPP)", modify
			
			label values pline_sp pline_sp
			label var pline_sp "Estado de pobreza"
							
			label define pov_ind 			///
			0 "Poverty rate" 			///
			1 "Poverty gap"					///
			2 "Poverty severity"				///	
			3 "Gini", modify			
			label values pov_ind pov_ind
			
			label define pov_ind_sp 			///
			0 "Tasa de pobreza" 			///
			1 "Brecha de pobreza"					///
			2 "Severidad de la pobreza"				///
			3 "Gini", modify				
			label values pov_ind_sp pov_ind_sp
			
			label define component  ///
			1 "Men employed" ///
			2 "Men labor earnings" ///
			3 "Women employed" ///
			4 "Women labor earnings" ///
			5 "Other income" ///
			6 "Dependency ratio" ///
			7 "Total" ///
			8 "Employed individuals" ///
			9 "Labor earnings" ///
			10 "Dependency ratio" ///
			11 "Remittances"	///
			12 "Public transfers" ///
			13 "Retirement and Pensions" ///
			14 "Other non-labor income" ///
			15 "Total", modify
			label values component component
			
			
			label define component_sp  ///
			1 "Hombres empleados" ///
			2 "Ingresos laborales de los hombres" ///
			3 "Mujeres empleadas" ///
			4 "Ingresos laborales de las mujeres" ///
			5 "Otro ingreso" ///
			6 "Tasa de dependencia" ///
			7 "Total" ///
			8 "Ocupados" ///
			9 "Ingreso laboral" ///
			10 "Tasa de dependencia" ///
			11 "Remesas" ///
			12 "Transferencias estatales" ///
			13 "Jubilaciones y pensiones" ///
			14 "Otro ingreso no laboral" ///
			15 "Total" , modify
			label values component_sp component_sp
			
			label define dtype ///
			1 "By gender" ///
			2 "By income source", modify
			label values dtype dtype
			
			label define dtype_sp ///
			1 "Por género" ///
			2 "Por fuertes de ingreso", modify
			label values dtype_sp dtype_sp
			
		} // end of barros labels
		*===============================================================================
		* LABELS: INEQUALITY 
		if "`module'"=="ine" | "`module'"=="ine_reg" {
			clonevar indicator_sp=indicator // In spanish
			local renvars indicator
			
			label define indicator 			///
			0 "Gini coefficient" 			///
			1 "Rate 90/10"					///
			2 "Rate 75/25"					///
			3 "Generalized entropy, GE(-1)"	///
			4 "Mean log deviation, GE(0)"	///
			5 "Theil index, GE(1)"			///
			6 "Generalized entropy, GE(2)"	///
			7 "Atkinson, A(0.5)"			///
			8 "Atkinson, A(1)"				///
			9 "Atkinson, A(2)"				///
			10 "Gini coefficient (no zero income)", modify 
			label values indicator indicator
			
			label define indicator_sp		///
			0 "Coeficiente Gini" 			///
			1 "Razon 90/10"					///
			2 "Razon 75/25"					///
			3 "Indice de entropia, GE(-1)"	///
			4 "Mean log deviation, GE(0)"	///
			5 "Indice de Theil, GE(1)"			///
			6 "Indice de entropia, GE(2)"	///
			7 "Atkinson, A(0.5)"			///
			8 "Atkinson, A(1)"				///
			9 "Atkinson, A(2)"				///
			10 "Coeficiente Gini (ingreso mayor a zero)", modify 
			label values indicator_sp indicator_sp
		} // end of inequality labels
		*===============================================================================
		* LABELS: INEQUALITY BY SOURCE
		if "`module'"=="inq" {
			clonevar inc_source_sp = inc_source
			clonevar quintiles_sp = quintiles
			
			label define inc_source ///
			1 "Labor income" ///
			2 "Income from transfers" ///
			3 "Income from pensions" ///
			4 "Capital income" ///
			5 "Other non-labor income", modify
			label values inc_source inc_source
			
			label define inc_source_sp ///
			1 "Ingreso laboral" ///
			2 "Ingreso por transferencias" ///
			3 "Ingreso por pensiones" ///
			4 "Ingreso por capital" ///
			5 "Otros ingresos no laborales", modify
			label values inc_source_sp inc_source_sp
						

			label define quintiles 			///
			1 "1st quintile" ///
			2 "2nd quintile" ///
			3 "3rd quintile" ///
			4 "4th quintile" ///
			5 "5th quintile", modify
			label values quintiles quintiles
			
			label define quintiles_sp 			///
			1 "1er quintil" ///
			2 "2do quintil" ///
			3 "3er quintil" ///
			4 "4to quintil" ///
			5 "5to quintil", modify
			label values quintiles_sp quintiles_sp
			
			label var shi_by_q	"Share by quintile: Share of inc source for each quintile's total income"
			label var shq_by_i 	"Share by income source: Share of quintile's income source over total income source"
			label var shq_tot 	"Share of each quintile in total income"
		} // end of inequality by source labels
		*===============================================================================
		* LABELS: DISTRIBUTION INEQUALITY
		if "`module'"=="dis" {
			clonevar group_sp=group // In spanish
			local renvars group
			
			label define group 							///
			190     "Poverty $1.9 (2011 PPP)"           ///
			320     "Poverty $3.2 (2011 PPP)"           ///
			550     "Poverty $5.5 (2011 PPP)"           ///
			1300  "Vulnerable $5.5-$13 (2011 PPP)"    	///
			7000 "Middle Class $13-$70 (2011 PPP)"  	///
			8000 "Rich" , modify
			label values group group
			
			label define group_sp 						///
			190     "Pobreza $1.9 (2011 PPP)"           ///
			320     "Pobreza $3.2 (2011 PPP)"        	///
			550     "Pobreza $5.5 (2011 PPP)"           ///
			1300  "Vulnerable $5.5-$13 (2011 PPP)"      ///
			7000 "Clase media $13-$70 (2011 PPP)"		///
			8000 "Ricos"  , modify
			label values group_sp group_sp
	
		} // end of distribution inequality labels	
		*===============================================================================
		* LABELS: SHARED PROSPERITY PROFILES
		
		if "`module'"=="shp" {
			clonevar indicator_sp=indicator // In spanish
			local renvars indicator
			
			label define indicator 			///
			1 "Growth of the bottom 40" 			///
			0 "Growth of the total population", modify
			label values indicator indicator
			
			label define indicator_sp 			///
			1 "Crecimiento del 40% mas pobre" 			///
			0 "Crecimiento del total de la población", modify
			label values indicator_sp indicator_sp
			
		} // end of shared prosperity labels 
		
		*===============================================================================
		* LABELS: GIS - Growth Incidence Curve by Source
		
		if "`module'" == "gis" {
			clonevar inc_type_sp = inc_type
			
			label define inc_type	///
			1 "Labor income"		///
			2 "Non-labor income", modify
			label values inc_type inc_type
			
			label define inc_type_sp	///
			1 "Ingreso laboral" ///
			2 "Ingreso no laboral", modify
			label values inc_type_sp inc_type_sp
		
		} // end of GIS - Growth Incidence Curve by Source labels

		*===============================================================================
		* LABELS: BOTTOM 40 PROFILES
		if "`module'"=="b40" {
			clonevar group_sp=group // In spanish
			clonevar indicator_sp=indicator // In spanish
			local renvars group indicator
			
			label define group 			///
			1 "Bottom 40" ///
			2 "Top 60" ///
			3 "Poverty $1.9 (2011 PPP)"           ///
			4 "Poverty $3.2 (2011 PPP)"           ///
			5 "Poverty $5.5 (2011 PPP)"           ///
			6 "Vulnerable $5.5-$13 (2011 PPP)"    	///
			7 "Middle Class $13-$70 (2011 PPP)"  	///
			8 "Rich" , modify
			label values group group
			
			label define indicator 			///
			1 "Age of the head of the household" ///
			2 "Household size" ///
			3 "Households living in urban areas (%)" ///
			4 "Households living with female heads (%)" ///
			5 "Number of children (ages 0-14)" ///
			6 "Years of education of the head of the household" ///
			7 "School enrollment for ages 6-14 (%)" ///
			8 "School enrollment for ages 15-24 (%)" ///
			9 "Years of education (ages 18 and older)" ///
			10 "Median daily per capita income (2011 US PPP)" , modify
			label values indicator indicator
			
			label define group_sp 			/// Revisar
			1 "40% más pobre" ///
			2 "60% más rico" ///
			3 "Pobreza $1.9 (2011 PPP)"           ///
			4 "Pobreza $3.2 (2011 PPP)"           ///
			5 "Pobreza $5.5 (2011 PPP)"           ///
			6 "Vulnerable $5.5-$13 (2011 PPP)"    	///
			7 "Clase media $13-$70 (2011 PPP)"  	///
			8 "Ricos" , modify
			label values group_sp group_sp
			
			label define indicator_sp 			///
			1 "Edad de la cabeza de hogar" ///
			2 "Tamaño del hogar" ///
			3 "Hogares residiendo en areas urbanas (%)" ///
			4 "Hogares con mujer cabeza de hogar (%)" ///
			5 "Número de niños (edades 0-14)" ///
			6 "Años de educación de cabeza de hogar" ///
			7 "Matrícula escolar (edades 6-14) (%)" ///
			8 "Matrícula escolar (edades 15-24) (%)" ///
			9 "Años de educación(edades 18 en adelante)" ///
			10 "Mediana del ingreso per cápita diario (2011 US PPP)" , modify
			label values indicator_sp indicator_sp
		} // end of b40 profiles labels
		
		*===============================================================================
		* LABELS: Labor Markets
		if "`module'"=="lab" {
			clonevar group_sp = group // In spanish
			clonevar lab_status_sp = lab_status
			
			* For tooltip
			clonevar lab_status_tt = lab_status
			clonevar lab_status_sp_tt = lab_status
			clonevar group_tt = group // In spanish
			clonevar group_sp_tt = group // In spanish
			
			label define group 							///
			40		"Bottom 40"		///
			60		"Top 60" ///
			190     "Poverty $1.9 (2011 PPP)"           ///
			320     "Poverty $3.2 (2011 PPP)"           ///
			550     "Poverty $5.5 (2011 PPP)"           ///
			1300  	"Vulnerable $5.5-$13 (2011 PPP)"    	///
			7000 	"Middle Class $13-$70 (2011 PPP)"  	///
			8000 	"Rich" ///
			201 	"Skills: Less than primary" ///
			202 	"Skills: Primary complete" ///
			203 	"Skills: Secondary complete" ///
			204 	"Skills: Tertiary complete", modify
			label values group group
			
			label define group_sp 	///
			40 		"40% más pobre" ///
			60 		"60% más rico" ///			
			190     "Pobreza $1.9 (2011 PPP)"           ///
			320     "Pobreza $3.2 (2011 PPP)"        	///
			550     "Pobreza $5.5 (2011 PPP)"           ///
			1300 	"Vulnerable $5.5-$13 (2011 PPP)"      ///
			7000 	"Clase media $13-$70 (2011 PPP)"		///
			8000 	"Ricos"   ///
			201 	"Nivel de educación: Primaria incompleta" ///
			202 	"Nivel de educación: Primaria completa" ///
			203 	"Nivel de educación: Secundaria completa" ///
			204 	"Nivel de educación: Terciaria completa", modify
			label values group_sp group_sp
			
			
			label define group_tt 							///
			40		"among the bottom 40"		///
			60		"among the top 60" ///
			190     "among the poor ($1.9 2011 PPP)"           ///
			320     "among the poor ($3.2 2011 PPP)"           ///
			550     "among the poor ($5.5 2011 PPP)"           ///
			1300  	"among the vulnerable ($5.5-$13 2011 PPP)"    	///
			7000 	"among the middle class ($13-$70 (2011 PPP)"  	///
			8000 	"among the rich" ///
			201 	"with less than primary education" ///
			202 	"with primary complete" ///
			203 	"with secondary complete" ///
			204 	"with tertiary complete", modify
			label values group_tt group_tt
			
			label define group_sp_tt 							///
			40		"entre el 40% más pobre"		///
			60		"entre el 60% más rico" ///
			190     "entre los pobres ($1.9 2011 PPP)"           ///
			320     "entre los pobres ($3.2 2011 PPP)"           ///
			550     "entre los pobres ($5.5 2011 PPP)"           ///
			1300  	"entre los vulnerables ($5.5-$13 2011 PPP)"    	///
			7000 	"entre la clase media ($13-$70 (2011 PPP)"  	///
			8000 	"entre los ricos" ///
			201 	"con menos de primaria completa" ///
			202 	"con primaria completa" ///
			203 	"con secundaria completa" ///
			204 	"con terciaria completa", modify
			label values group_sp_tt group_sp_tt 
			
			
			
			label define lab_status ///
			101 "Unemployment rate"   ///
			102 "Employment rate"   ///
			103 "Labor force participation"   ///
			301 "Economic sector: Primary" 	///	  
			302 "Economic sector: Manufacturing" 	///
			303 "Economic sector: Construction and utilities" 	///
			304 "Economic sector: Retail and services" 	///
			401 "Firm size: Small private firms"	/// 
			402 "Firm size: Large private firms"	///
			403 "Firm size: Public firms"	///
			501 "Type of worker: Employers"	///
			502 "Type of worker: Salaried workers"	///
			503 "Type of worker: Self-employed"	///
			504 "Type of worker: Unsalaried", modify
			label values lab_status lab_status
			
			label define lab_status_sp ///
			101 "Tasa de desempleo"   ///
			102 "Tasa de empleo"   ///
			103 "Tasa de participación en la fuerza laboral"   ///
			301 "Sector económico: Primario" 	///	  
			302 "Sector económico: Manufacturas" 	///
			303 "Sector económico: Construcción y servicios públicos" 	///
			304 "Sector económico: Ventas y servicios" 	///
			401 "Tamaño de firma: Empresa privada (pequeña)"	/// 
			402 "Tamaño de firma: Empresa privada (grande)"	///
			403 "Tamaño de firma: Empresa pública"	///
			501 "Tipo de trabajador: Empleadores"	///
			502 "Tipo de trabajador: Asalariados"	///
			503 "Tipo de trabajador: Independientes"	///
			504 "Tipo de trabajador: Sin salario", modify
			label values lab_status_sp lab_status_sp
			
			label define lab_status_tt   ///
			101 "the unemployment rate"   ///
			102 "the employment rate"   ///
			103 "the labor force participation"   ///
			301 "the share of workers in the primary sector" 	///	  
			302 "the share of workers in the manufacturing sector" 	///
			303 "the share of workers in construction and utilities" 	///
			304 "the share of workers in retail and services" 	///
			401 "the share of workers in small private firms"	/// 
			402 "the share of workers in large private firms"	///
			403 "the share of workers in public firms"	///
			501 "the share of workers who are employers"	///
			502 "the share of workers who are salaried workers"	///
			503 "the share of workers who are self-employed"	///
			504 "the share of workers who are unsalaried ", modify
			label values lab_status_tt lab_status_tt
			
			
			label define lab_status_sp_tt ///
			101 "la tasa de desempleo"   ///
			102 "la tasa de empleo"   ///
			103 "la tasa de participación en la fuerza laboral"   ///
			301 "el porcentaje de trabajadores en el sector primario" 	///	  
			302 "el porcentaje de trabajadores en el sector manufacturero" 	///
			303 "el porcentaje de trabajadores en el sector de construcción y servicios públicos" 	///
			304 "el porcentaje de trabajadores en el sector de ventas y servicios" 	///
			401 "el porcentaje de trabajadores en pequeñas empresas privadas"	/// 
			402 "el porcentaje de trabajadores en grandes empresas privadas"	///
			403 "el porcentaje de trabajadores en empresas públicas"	///
			501 "el porcentaje de trabajadores que son empleadores"	///
			502 "el porcentaje de trabajadores que son asalariados"	///
			503 "el porcentaje de trabajadores que son independientes"	///
			504 "el porcentaje de trabajadores sin salario", modify
			label values lab_status_sp_tt lab_status_sp_tt
			
			
			
		} // end of lab labels
		
		*===============================================================================
		* LABELS: LIPI
		if "`module'"=="lip" {
			clonevar line_sp = line
			clonevar indicator_sp = indicator
			label define line 							///
			190     "Poverty $1.9 (2011 PPP)"           ///
			320     "Poverty $3.2 (2011 PPP)"           ///
			550     "Poverty $5.5 (2011 PPP)"           ///
			100001	"Gini coefficient"
			label values line line
			
			label define line_sp 	///
			190     "Pobreza $1.9 (2011 PPP)"           ///
			320     "Pobreza $3.2 (2011 PPP)"        	///
			550     "Pobreza $5.5 (2011 PPP)"           ///
			100001	"Coeficiente Gini"
			label values line_sp line_sp
			
			label define indicator ///
			1 "Labor Income Poverty Index (LIPI)" 	///
			2 "Labor Income Gini Index (LIGI)"		
			label values indicator indicator
			
			label define indicator_sp ///
			1 "Índice de Pobreza del Ingreso Laboral (LIPI)" 	///
			2 "Índice de Gini del Ingreso Laboral (LIGI)"		
			label values indicator_sp indicator_sp
			
		
		} // END LIPI labels
		
				
		*===============================================================================
		* LABELS: NINIs
		if "`module'"=="nin" {
			clonevar status_sp 	= status
			clonevar gender_sp 	= gender
		
			
			label define ages ///
			1 "15-18" ///
			2 "15-24" ///
			3 "19-24", modify
			label values ages ages
			
			
			label define status ///
			1 "Employed (not in school)" ///
			2 "In school" ///
			3 "Neither in school nor working", modify
			label values status status
		
			label define status_sp ///
			1 "Employed (not in school)" ///
			2 "In school" ///
			3 "Neither in school nor working", modify
			label values status_sp status_sp
			
			label define gender ///
			0 "Female" ///
			1 "Male" ///
			2 "All", modify
			label values gender gender
			
			label define gender_sp ///
			0 "Mujeres" ///
			1 "Hombres" ///
			2 "Total", modify
			label values gender_sp gender_sp
		
			
			
			
		
		} // END NINI labels
		
		*===============================================================================
		* LABELS: Regional Distribution - Poverty
		if "`module'"=="reg" {
		
		* if ("`calc'" == "reg") local colnames "country year type pline n_poor share"
			clonevar pline_sp=pline
			clonevar country_sp = country
			clonevar type_sp = type
			
			label define type ///
			1 "Sub-regional" ///
			2 "By country", modify
			label values type type
		
						
			label define type_sp ///
			1 "Sub-regional" ///
			2 "Por país", modify
			label values type_sp type_sp
			
			label define pline                           ///
			125     "Poverty $1.25 (2005 PPP)"           ///
			190     "Poverty $1.9 (2011 PPP)"            ///
			320     "Poverty $3.2 (2011 PPP)"            ///
			550     "Poverty $5.5 (2011 PPP)"            ///
			250     "Poverty $2.5 (2005 PPP)"            ///
			400     "Poverty $4 (2005 PPP)"              ///
			4001000  "Vulnerable $4-$10 (2005 PPP)"      ///
			10005000 "Middle Class $10-$50 (2005 PPP)"   ///
			5501300  "Vulnerable $5.5-$13 (2011 PPP)"    ///
			13007000 "Middle Class $13-$70 (2011 PPP)", modify
			
			label values pline pline
			label var pline "Poverty Status"

			label define pline_sp                          ///
			125     "Pobreza $1.25 (2005 PPP)"              ///
			190     "Pobreza $1.9 (2011 PPP)"                ///
			320     "Pobreza $3.2 (2011 PPP)"        ///
			550     "Pobreza $5.5 (2011 PPP)"                ///
			250     "Pobreza $2.5 (2005 PPP)"        ///
			400     "Pobreza $4 (2005 PPP)"                  ///
			4001000  "Vulnerable $4-$10 (2005 PPP)"        ///
			10005000 "Clase media $10-$50 (2005 PPP)"      ///
			5501300  "Vulnerable $5.5-$13 (2011 PPP)"      ///
			13007000 "Clase media $13-$70 (2011 PPP)", modify
			
			label values pline_sp pline_sp
			label var pline_sp "Estado de pobreza"
			
			label define country ///
			484 "Mexico"  ///
			76 "Brazil"  ///
			1000 "Central America"  ///
			1001 "Andean Region"  ///
			1002 "Southern Cone" ///
			999 "Latin America and the Caribbean", modify
			label values country country
			
			label define country_sp ///
			484 "México"  ///
			76 "Brasil"  ///
			1000 "Centro América"  ///
			1001 "Región Andina"  ///
			1002 "Cono Sur" ///
			999 "América Latina y el Caribe", modify
			label values country_sp country_sp
			
		} // end of poverty labels
		
	}
	
} // end of quietly

end

exit

