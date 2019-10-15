/*====================================================================
project:       decode numeric variables but prevail the name. 
Author:        Andres Castaneda 
Dependencies:  The World Bank
----------------------------------------------------------------------
Creation Date:    17 Oct 2017 - 15:13:00
Modification Date:   
Do-file version:    01
References:          
Output:             transformed variable
====================================================================*/

program define autolel_2string

syntax varlist

foreach var of local varlist {
	if ("`: value label `var''" == "") continue
	tempvar `var'
	decode `var', gen(``var'')
	drop `var'
	rename ``var'' `var'
}

end

exit 
