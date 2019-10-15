*===============================================================================
* ESTABLISHING THE MACRO REGIONS BESIDES LAC
* This version: 23/MAY/2017 --- Carlos Felipe Balcazar
cap program drop  autolel_def_region
program define autolel_def_region, rclass
syntax varlist
quietly {
	replace pais = lower(pais)
* CENTRAL AMERICA
	replace `varlist'=1000 if pais=="cri" | pais=="dom" | pais=="slv" | pais=="hnd" | pais=="pan"  | pais=="nic"  | pais=="gtm" 

	* ANDEAN REGION
	replace `varlist'=1001 if pais=="bol" | pais=="col" | pais=="ecu" | pais=="per"  

	* CONO SUR
	replace `varlist'=1002 if pais=="arg" | pais=="chl" | pais=="pry" | pais=="ury" 
} // end of quietly
end
