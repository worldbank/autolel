*===============================================================================
* POVERTY LINES
* This version: 23/MAY/2017 --- Carlos Felipe Balcazar	
cap program drop autolel_def_povlines
program define autolel_def_povlines, rclass
syntax, [country(string)]
quietly {
	
	* Generating cut-off points for poor at 1.9 USD 2011PPP, vulnerable and middle class
	gen lp_1usd_ppp=30.42*1.9*(ipc05_sedlac/ipc11_sedlac)*(ppp11/ppp05)
	gen lp_10usd_ppp=2.5*lp_4usd_ppp
	gen lp_50usd_ppp=12.5*lp_4usd_ppp

	/* Default cut-off points: 1.9 USD 2011PPP; 2.5 USD 2005PPP; 4 USD 2011PPP;
	10 USD 2011PPP; 50 USD 2005PPP*/
	if "`country'" == "lac" local pov_lines = "1 2 4 10 50" 
	if "`country'" == "arg" local pov_lines = "1 2 4 10 50"  
	if "`country'" == "bol" local pov_lines = "1 2 4 10 50" 
	if "`country'" == "bra" local pov_lines = "1 2 4 10 50"  
	if "`country'" == "chl" local pov_lines = "1 2 4 10 50" 
	if "`country'" == "col" local pov_lines = "1 2 4 10 50"  
	if "`country'" == "cri" local pov_lines = "1 2 4 10 50"  
	if "`country'" == "dom" local pov_lines = "1 2 4 10 50" 
	if "`country'" == "ecu" local pov_lines = "1 2 4 10 50"  
	if "`country'" == "slv" local pov_lines = "1 2 4 10 50" 
	if "`country'" == "gtm" local pov_lines = "1 2 4 10 50"  
	if "`country'" == "hnd" local pov_lines = "1 2 4 10 50" 
	if "`country'" == "mex" local pov_lines = "1 2 4 10 50" 
	if "`country'" == "nic" local pov_lines = "1 2 4 10 50" 
	if "`country'" == "pan" local pov_lines = "1 2 4 10 50"  
	if "`country'" == "pry" local pov_lines = "1 2 4 10 50" 
	if "`country'" == "per" local pov_lines = "1 2 4 10 50" 
	if "`country'" == "ury" local pov_lines = "1 2 4 10 50" 
	if "`country'" == "hti" local pov_lines = "1 2 4 10 50" 
} // end of quietly
* Local with default poverty lines
return local pl `pov_lines'
end
