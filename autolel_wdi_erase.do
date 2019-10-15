





* set checksum off, permanently
* wbopendata, indicator("6.0.GDP_current") year(1990:2016) long clear




* Literacy rate, youth
* total (% of people ages
* 15-24)

										 
* 1.1_YOUTH.LITERACY.RATE 

/*===========================================================================
project:       LAC Equity LAB  - Gender Do Files 
Author:        Santiago Garriga 
Modify by:		Laura Moreno 
Modify by 2:	Giselle Del Carmen
Dependencies:  LCSPP - World Bank
---------------------------------------------------------------------------
Creation Date:    February 7, 2014 
Modification Date:   August 15, 2014
Modification Date 2:  January 14, 2016
Do-file version:    02
References:          
Output:             Excel
Note: 		Labor indicators are excluded from this version, gender labor dashboard is dropped from LEL
===========================================================================*/

/*===============================================================================================
                                  0: Set locals and Paths
===============================================================================================*/
/* En esta seccion se indican los directorios donde se guardara la informacion*/

clear all

* Set paths
local path "Z:\public\Stats_Team\LAC Equity Lab\Dashboards\gender\2016\release 1"

local do_path "`path'\do-files"
local xls "`path'\excel"
local xls_name "gender_indicators"
local dta "`path'\dta"

* Set directory
cd "`path'"

* Set temporary file
tempfile aux
************************************************-1- Indicators & Dimensions *************************************************
* En esta seccion se seleciona los temas y las variables por temas que son de interes

* Political Participation 
local agency "SG.GEN.LSOM.ZS SG.GEN.MNST.ZS SG.GEN.PARL.ZS"

* Health
local health "SP.ADO.TFRT SH.STA.BRTC.ZS SP.DYN.CONU.ZS SH.STA.MMRT SH.STA.ANVC.ZS SH.STA.ANV4.ZS SH.HIV.1524.FE.ZS SH.HIV.1524.MA.ZS"

* Education
local education "SE.ADT.LITR.FE.ZS SE.ADT.LITR.MA.ZS SE.ENR.SECO.FM.ZS SE.ADT.1524.LT.FM.ZS SE.PRM.NENR.FE SE.PRM.NENR.MA SE.SEC.NENR.FE SE.SEC.NENR.MA SE.TER.ENRR.FE SE.TER.ENRR.MA SE.ENR.TERT.FM.ZS "
* -> Excluded: BAR.TER.CMPT.1519.FE.ZS, SE.PRM.ENRR.FE, SE.PRM.ENRR.MA

* Financial
local financial "WP11623_4.3 WP11623_4.2  WP11651.3 WP11651.2 SL.UEM.1524.FM.ZS IC.FRM.GEN.GEND1 IC.FRM.GEN.GEND4"

* Violence
local violence  "SG.VAW.ARGU.ZS SG.VAW.BURN.ZS SG.VAW.GOES.ZS SG.VAW.NEGL.ZS SG.VAW.REAS.ZS SG.VAW.REFU.ZS" 

** Other
local other "SP.HOU.FEMA.ZS"

*************************************************-2- Extraccion de indicadores *************************************************
* En esta seccion se llaman del WDI los indicadores utilizando <<wbopendata>> 

local a: subinstr local a " " "; ", all

local c = 0

foreach a in agency health education financial violence other {	
	local ++c
	local `a': subinstr local `a' " " "; ", all
	
	* Download Data from WDI
	qui:wbopendata, indicator(``a'') clear  year(2000:2015)
	noi ret list
	* Keep relevant variables
	keep countryname - yr2015
		
	* Keep LAC
	keep if regioncode == "LCN" | (regioncode == "NA" & countrycode == "LCN")
	
	* Erase irrelevant countries
	drop if countrycode == "ABW" | countrycode == "BHS" | countrycode == "BRB" | countrycode == "CUB" | countrycode == "CYM" | countrycode == "PRI" | countrycode == "TCA" | countrycode == "VIR" | countrycode == "CUW"
	
	* Add source, description and frequency
	local vars = "`r(indicator)'"
	local count: list sizeof vars
	stop
	gen time = ""
	gen source = ""
	gen description = ""
	
	foreach b of numlist 1/`count' {

		local var = "`r(indicator`b')'"
		local time = "`r(time`b')'"
		local source = "`r(source`b')'"
		local description = "`r(varlabel`b')'"

		replace time = "`time'" if indicatorname == "`var'"
		replace source = "`source'" if indicatorname == "`var'"
		replace description = "`description'" if indicatorname == "`var'"
				
	}
	
	gen dimension = "`a'"
		
	compress
	if `c' > 1 	append using `aux'
	saveold `aux', replace

	* Export Results
	* export excel using "`xls'\\`xls_name'.xlsx", sheet("`a'") sheetreplace first(variable) 
	} // end loop

*************************************************-3- Variables adicionales *************************************************
	
/*Los indicadores estan construidos de forma diferente, para poder hacer graficas enrriquesedoras y proveer a tableu las desagregaciones necesarias, es util crear dos variables adicoinales. 1) El tipo de indicador. De este grupo se identificaron 4 grupos: Female^/Total female, Male^/Total male, Female/Male y otros. El siguiente codigo se contruye con el fin de crear la primera de esas categorias. 
Female^/Total female -> note que todas menos la primera tienen FE
"WP11623_4.3 SL.TLF.ACTI.1524.FE.ZS SL.TLF.CACT.FE.ZS SE.ADT.LITR.FE.ZS WP11651.3 SH.HIV.1524.FE.ZS SE.PRM.ENRR.FE SL.UEM.TOTL.FE.ZS SL.UEM.1524.FE.ZS BAR.TER.CMPT.1519.FE.ZS SL.EMP.INSV.FE.ZS" 
Male^/Total male -> todas menos la primera tienen MA
"WP11623_4.2 SL.TLF.ACTI.1524.MA.ZS SL.TLF.CACT.MA.ZS SE.ADT.LITR.MA.ZS WP11651.2 SH.HIV.1524.MA.ZS SE.PRM.ENRR.MA SL.UEM.TOTL.MA.ZS SL.UEM.1524.MA.ZS "
Female/Male->  todas tienen FM
"SL.TLF.CACT.FM.ZS SE.ENR.PRIM.FM.ZS SE.ENR.SECO.FM.ZS SL.UEM.1524.FM.ZS SE.ADT.1524.LT.FM.ZS"
otros->  no tienen nada en comun
"SP.ADO.TFRT SH.STA.BRTC.ZS SP.DYN.CONU.ZS SP.HOU.FEMA.ZS SG.GEN.LSOM.ZS SH.STA.MMRT SH.STA.ANVC.ZS SH.STA.ANV4.ZS SG.GEN.PARL.ZS SG.GEN.MNST.ZS"
*/

gen clas="OO"
replace clas="FE" if strpos(indicatorname, ".FE")>01 	
replace clas="MA" if strpos(indicatorname, ".MA")>01 
replace clas="FM" if strpos(indicatorname, ".FM")>01 

/*---------------------------------------------------------------------------
* OJO: Casos particulares
---------------------------------------------------------------------------*/

replace clas="FE" if indicatorname=="WP11623_4.3" | indicatorname=="WP11651.3"
replace clas="MA" if indicatorname=="WP11623_4.2" | indicatorname=="WP11651.2"
replace clas="OO" if indicatorname=="SP.HOU.FEMA.ZS" 

/*2) La variable genero en las que se compara genero^/genero total y la unidad*/

gen Female=""
replace Female="Female" if clas=="FE"
replace Female="Male" if clas=="MA"

gen unit=""
replace unit="Female/Total Female" if clas=="FE"
replace unit="Male/Total Male" if clas=="MA"
replace unit="Female/Male" if clas=="FM"

* agrupar los indicadores que cumplen con la siguiente caracteristica: female^/total female y male^/total male
gen indicator=description
replace indicator=subinstr(description,"female","",.) if clas=="FE"
replace indicator=subinstr(description,"male","",.) if clas=="MA"

* ajuste del nombre en algunos casos
replace indicator=subinstr(indicator,"% of","%",.) if clas=="FE" 
replace indicator=subinstr(indicator,"% of","%",.) if clas=="MA"

* Se arregla la variable de fuente, para que se vea mejor.
egen SourceWDI=ends(source), punct(>) trim last

* Generate download date
gen download_date = "`c(current_date)'"

* Order variables
order countryname countrycode iso2code region regioncode indicatorname indicatorcode time source description download_date

 * Reshape
reshape long yr,i(countrycode indicatorname) j(a)

ren a year
ren yr value

* casos especiales. dejar solo a;o con mayor informacion.

drop if (indicatorname=="IC.FRM.FEMM.ZS" | indicatorname=="IC.FRM.GEN.GEND1") & year!=2010

************************************************* Guardar *************************************************

export excel using "`xls'\\`xls_name'_completa.xlsx", sheet("`xls_name'") sheetreplace first(variable) 

save "`dta'\\`xls_name'_completa.dta", replace 

************* NO MISSING VALUES - Borrar las observaciones donde los valores son missing.

drop if value==. 

**Translate Spanish indicators
clonevar countryname_sp=countryname

replace indicator = "School enrollment, primary, (% net)" 						if indicator == "Net enrolment rate, primary,  (%)"
replace indicator = "School enrollment, secondary, (% net)" 					if indicator == "Net enrolment rate, secondary,  (%)"
replace indicator = "School enrollment, tertiary, (% gross)" 					if indicator == "Gross enrolment ratio, tertiary,  (%)"
replace indicator = "Literacy rate, adult (% ages 15+)" 						if indicator == "Adult literacy rate, population 15+ years,  (%)"
replace indicator = "Ratio of young literate females to males (% ages 15-24)" 	if indicator == "Youth literacy rate, population 15-24 years, gender parity index (GPI)"
replace indicator = "Ratio of female to male secondary enrollment (%)"			if indicator ==	"Gross enrolment ratio, secondary, gender parity index (GPI)"
replace indicator = "Ratio of female to male tertiary enrollment (%)"			if indicator ==	"Gross enrolment ratio, tertiary, gender parity index (GPI)"

clonevar indicador_sp=indicator

replace indicador_sp="Proporción de mujeres jóvenes alfabetizadas en relación a los hombres jóvenes alfabetizados (edades 15-24)"	if indicator==  "Ratio of young literate females to males (% ages 15-24)"
replace indicador_sp="Tasa de alfabetización, adultas (% mas de 15)"																if indicator==  "Literacy rate, adult (% ages 15+)"
replace indicador_sp="Proporcion de niñas con respecto a niños matriculados en primaria"											if indicator==	"Ratio of female to male primary enrollment (%)"
replace indicador_sp="Proporcion de niñas con respecto a niños matriculados en secundaria"											if indicator==	"Ratio of female to male secondary enrollment (%)"
replace indicador_sp="Proporcion de niñas con respecto a niños matriculados en educacion terciaria"									if indicator==	"Ratio of female to male tertiary enrollment (%)"
replace indicador_sp="Inscripcion escolar, nivel primaria (% neto)"																	if indicator==	"School enrollment, primary, (% net)"
replace indicador_sp="Inscripcion escolar, nivel secundaria (% neto)"																if indicator==	"School enrollment, secondary, (% net)"
replace indicador_sp="Inscripcion escolar, nivel terciaria (% bruto)"																if indicator==	"School enrollment, tertiary, (% gross)"
replace indicador_sp="Prevalencia de VIH (% edades 15-24)"																			if indicator==	"Prevalence of HIV,  (% ages 15-24)"
replace indicador_sp="Mujeres embarazadas que recibieron cuidado prenatal, al menos 4 veces (% mujeres)"							if indicator==	"Pregnant women receiving prenatal care of at least four visits (% of pregnant women)"
replace indicador_sp="Mujeres embarazadas que recibieron cuidado prenatal"															if indicator==	"Pregnant women receiving prenatal care (%)"
replace indicador_sp="Porcentaje de partos con asistencia de personal sanitario especializado (% del total)"						if indicator==	"Births attended by skilled health staff (% of total)"
replace indicador_sp="Tasa de mortalidad materna (estimado mediante modelo, por cada 100.000 nacidos vivos)"						if indicator==	"Maternal mortality ratio (modeled estimate, per 100,000 live births)"
replace indicador_sp="Tasa de fertilidad adolescente (número de nacimientos por cada 1.000 mujeres de edades 15-19)"				if indicator==	"Adolescent fertility rate (births per 1,000 women ages 15-19)"
replace indicador_sp="Prevalencia de uso de métodos anticonceptivos (% de mujeres entre 15 y 49)"									if indicator==	"Contraceptive prevalence (% of women ages 15-49)"

clonevar dimension_sp=dimension

replace dimension_sp="educacion" if dimension=="education"
replace dimension_sp="salud" if dimension=="health"

**Create variable with spanish articles (la, el etc.) for Tableau tooltip
gen text =""
*Health
replace text = "la" if indicador_sp =="Prevalencia de VIH (% edades 15-24)"	| indicador_sp =="Tasa de mortalidad materna (estimado mediante modelo, por cada 100.000 nacidos vivos)" | indicador_sp =="Tasa de fertilidad adolescente (número de nacimientos por cada 1.000 mujeres de edades 15-19)" | indicador_sp == "Prevalencia de uso de métodos anticonceptivos (% de mujeres entre 15 y 49)" | indicador_sp == "Porcentaje de partos con asistencia de personal sanitario especializado (% del total)" 

replace text = "el porcentaje de" if indicador_sp == "Mujeres embarazadas que recibieron cuidado prenatal" 

*Political Participation
replace text = "the" if indicator == "Proportion of seats held by women in national parliaments (%)" 
replace text = "the" if indicator == "Proportion of women in ministerial level positions (%)" 
replace text = "" if indicator == "Female legislators, senior officials and managers (% of total)"

gen end =""
replace end = "was" if indicator == "Proportion of seats held by women in national parliaments (%)" 
replace end = "was" if indicator == "Proportion of women in ministerial level positions (%)" 
replace end = "were" if indicator == "Female legislators, senior officials and managers (% of total)"

*Violence
replace text = "women believed a husband is justified in beating his wife (any of five reasons)" if indicator == "Women who believe a husband is justified in beating his wife (any of five reasons) (%)"
replace text = "women believed a husband is justified in beating his wife when she argues with him" if indicator == "Women who believe a husband is justified in beating his wife when she argues with him (%)"
replace text = "women believed a husband is justified in beating his wife when she burns the food" if indicator == "Women who believe a husband is justified in beating his wife when she burns the food (%)"
replace text = "women believed a husband is justified in beating his wife when she goes out without telling him" if indicator == "Women who believe a husband is justified in beating his wife when she goes out without telling him (%)"
replace text = "women believed a husband is justified in beating his wife when she goes out without telling him" if indicator == "Women who believe a husband is justified in beating his wife when she goes out without telling him (%)"
replace text = "women believed a husband is justified in beating his wife when she neglects the children" if indicator == "Women who believe a husband is justified in beating his wife when she neglects the children (%)"
replace text = "women believed a husband is justified in beating his wife when she refuses sex with him" if indicator == "Women who believe a husband is justified in beating his wife when she refuses sex with him (%)"

*Financial Inclusion
replace text = "of" if indicator == "Percent of firms with a female top manager (%)"
replace text = "women believed a husband is justified in beating his wife when she refuses sex with him" if indicator == "Women who believe a husband is justified in beating his wife when she refuses sex with him (%)"

save "`dta'\\`xls_name'_nom.dta", replace 
export excel using "`xls'\\`xls_name'_nom.xlsx", sheet("`xls_name'") sheetreplace first(variable) 

exit
