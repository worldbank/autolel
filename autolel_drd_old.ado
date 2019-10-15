*===============================================================================
* COMPUTING POVERTY DECOMPOSITION
cap program drop  autolel_dattravallion_calc
program define autolel_dattravallion_calc, rclass
syntax, [ country(string) n_country(numlist) y1(numlist) y2(numlist) pl(numlist)] 	
tempname _results
 *****NOTE: Natalia - Change matrices to tempmatrices
	if "`country'"=="lac" {
		qui: drdecomp ipcf_ppp [w=pondera] , by(year) varpl(lp_`pl'usd_ppp) ind(fgt0) mpl(1)
		mat `_results' = r(b)
		local growth = `_results'[1,4]
		local redis = `_results'[2,4]
		local total = `_results'[3,4]
	    mat _main_mat_dattravallion = nullmat(_main_mat_dattravallion)  \ (999,  `y1', `y2', `pl', `growth',0)      /*
							*/  \ (999,  `y1', `y2', `pl', `redis',1)  /*
							*/  \ (999, `y1', `y2', `pl', `total', 2)	 
		

	
		tempvar _region
		gen `_region'=.
		autolel_def_region `_region' // Natalia: Check
		
		forvalues j = 1(1)3 { // N: Whay does he do this three times?
		qui: drdecomp ipcf_ppp [w=pondera] , by(year) varpl(lp_`pl'usd_ppp) ind(fgt02) mpl(1)
		mat `_results' = r(b)
		local growth = `_results'[1,4]
		local redis = `_results'[2,4]
		local total = `_results'[3,4]
	    	mat _main_mat_dattravallion = nullmat(_main_mat_dattravallion)  \ (`=`j'+999',  `y1', `y2', `pl', `growth',0)      /*
							*/  \ (`=`j'+999',  `y1', `y2', `pl', `redis',1)  /*
							*/  \ (`=`j'+999', `y1', `y2', `pl', `total', 2)	
							
	
		}				
		}
		else {
		* Keep if consistent obervation
		capture keep if cohh==1 & ipcf!=.

		qui: drdecomp ipcf_ppp [w=pondera] , by(year) varpl(lp_`pl'usd_ppp) ind(fgt0) mpl(1)
		mat `_results' = r(b)
		local growth = `_results'[1,4]
		local redis = `_results'[2,4]
		local total = `_results'[3,4]
	    	mat _main_mat_dattravallion = nullmat(_main_mat_dattravallion)  \ (`n_country',  `y1', `y2', `pl', `growth',0)      /*
							*/  \ (`n_country',  `y1', `y2', `pl', `redis',1)  /*
							*/  \ (`n_country', `y1', `y2', `pl', `total', 2)		
							
	
	
	}
	capture return matrix _main_mat_dattravallion = _main_mat_dattravallion
	end
