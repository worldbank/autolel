/*====================================================================
project:       AUTO LEL -- create income and poverty lines variables
Author:        Andres Castaneda
Dependencies:  The World Bank
----------------------------------------------------------------------
Creation Date:      22 Aug 2017 
Do-file version:    01
References:
Output:             
====================================================================*/

program define autolel_varcreate

qui {
	
	* Income variables
	cap drop ipcf_ppp11
	gen ipcf_ppp11 =(12/365)*((ipcf*ipc11_sedlac)/ipc_sedlac)/(ppp11*conversion)
	
	cap drop ipcf_ppp05
	gen ipcf_ppp05 =(12/365)*((ipcf*ipc05_sedlac)/ipc_sedlac)/(ppp05*conversion)
	
	* Poverty lines variables
	
	gen lp_55usd_ppp  = 5.5
	gen lp_32usd_ppp  = 3.2
	gen lp_40usd_ppp  = 4
	gen lp_25usd_ppp  = 2.5
	gen lp_19usd_ppp  = 1.9
	gen lp_100usd_ppp = 10
	gen lp_500usd_ppp = 50	
}
	end
	
	exit
	/* End of do-file */
	><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
	
	Notes:
	1.
	2.
	3.
	
	
	Version Control:
