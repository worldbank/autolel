/*====================================================================
Project:       	AUTO LEL -- HOI - Human Opportunity Index
Author:        	Natalia Garcia Pena
Creation Date:         November 2019
Modifiacation Date:     
Do-File Version:        01         
====================================================================*/



program define autolel_dis, rclass
syntax, [ country(string) iso(numlist) year(numlist) water(string) elect(string) SEWage(string) INTERnet(string) CELular(string) pric(string) ATTendance(string) spouse(string) gmd sedlac] // Variables for HOI can be chosen by user, gmd variable names


/*===============================================================================================
                     1. Setting default variables
===============================================================================================*/



* Default uses sedlac variables
if "`gmd'" == "" & "`sedlac'" == "" local sedlac "sedlac" 

* Turn locals to globals for easier programming
global water "`water'" 
global elect "`elect'" 
global sewage "`sewage'"
global internet "`internet'" 
global celular "`celular'"
global pric "`pric'"
global attendance "`attendance'"
global aedu "`aedu'"
global spouse "`spouse'"

* GMD variable names
if "`gmd'" != "" {
	if "${water}" == "" 	global water "water"
	if "${elect}" == "" 	global elect "electricity"
	if "${sewage}" == "" 	global sewage "cloacas"
	* if "${internet}" == "" global internet 
	if "${celular}" == "" 	global celular "cellphone"
	if "${pric}" == "" 		global pric "primarycomp"
	if "${attendance}" == "" global attendance == "school"
	if "${aedu}" == "" 		global aedu == "educy"
	* if "${spouse}" == "" 	global spouce == "conjugue" // missing in gmd
}	

if "`sedlac'" != "" {
	if "${water}" == "" 	global water "agua"
	if "${elect}" == "" 	global elect "elect"
	if "${sewage}" == "" 	global sewage "cloacas"
	if "${internet}" == "" global internet "internet_casa" 
	if "${celular}" == "" 	global celular "celular"
	* if "${pric}" == "" 		global pric "primarycomp" // doesn't exist in sedlac
	if "${attendance}" == "" global attendance == "asiste"
	if "${aedu}" == "" 		global aedu == "aedu"
	if "${spouse}" == "" 	global spouse == "conjugue" 
}	



/*===============================================================================================
                     2. Generate variables for HOI
===============================================================================================*/

* Creation of states
autolel_defaults, reg_represent






