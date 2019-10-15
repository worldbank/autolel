*===============================================================================
* PATHS
* This version: 09/SEP/2016 --- Carlos Felipe Balcazar
* modified 11 April 2017 --- Andres Castaneda
* Modified 15 May 2017 --- Christian C Gomez Canon

cap program drop autolel_paths
program define autolel_paths, rclass
syntax, user(string) [ path(string) ]
quietly {
	if ("`path'" == "")       {
		  global roota_LEL "`c(pwd)'"  // current directory
		  noi disp in w "No path defined, if you use the save option, results will be save in:"
		  noi disp in w "`c(pwd)'" _n
	} // end of path condition
	else if ("`path'" == "master") global roota_LEL "Z:\public\Stats_Team\LAC Equity Lab\Auto-LEL"
	else                           global roota_LEL "`path'"

	global output_LEL "${roota_LEL}\LEL_Ouput"
	cap mkdir "${output_LEL}"

} // end of quietly
end

