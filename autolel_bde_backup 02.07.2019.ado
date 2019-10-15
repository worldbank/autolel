/*====================================================================
Project:       AUTO LEL -- Shapley Decomposition by income sources (Barros et al. 2006)
Author:        Natalia Garcia Pena
Dependencies:  The World Bank
----------------------------------------------------------------------
Creation Date:          05 Oct 2018
Modifiacation Date:     07 Feb 2019
Do-File Version:        01
References:
Output:             
====================================================================*/



program define autolel_bde, rclass
syntax, [ country(string) iso(numlist) y1(numlist) y2(numlist) eq(string) bdevars(string) pl(numlist) // type() /*pl(numlist)*/] // N: See if pl can be optional, or just place all lines for now)	

local country = upper("`country'")
local countryiso3 = `iso'

* Temp:
local pls "190 320 550"
foreach pl of local pls {
*Matrix
tempname _results

	if "`country'"=="lac" {
		*Sources of income and demographics
		qui adecomp ipcf_ppp11 pocup_man ila_man_ocup pocup_woman ila_woman_ocup  pc_otinla  dependency ///
		[w=pondera] , by(year) eq(c6*((c1*c2)+(c3*c4))+c5) varpl(lp_`pl'usd_ppp) in(fgt0 fgt1 fgt2 gini) 
		
		
		* temp
		global rootdatalib "S:\Datalib"
		datalib, country(pry) year(2012 2013) mod(all) clear
		drop year
		cap rename ano year
		qui adecomp ipcf_ppp11 pocup_man ila_man_ocup pocup_woman ila_woman_ocup  pc_otinla  dependency ///
		[w=pondera] , by(year) eq(c6*((c1*c2)+(c3*c4))+c5) varpl(lp_190usd_ppp) in(fgt0 fgt1 fgt2 gini) 
		
		mat `_results' = r(b)
		
		
		*Sources of income
		adecomp ipcf_ppp11 share_occupied ila_peroccupied pc_itran_ppp pc_otinla [w=pondera] , by(year) eq((c1*c2+c3+c4)) varpl(lp_`pl'usd_ppp) in(fgt0 fgt1 fgt2 gini) 
		
		mat _main_mat_barros = nullmat(_main_mat_barros)  \ (999,  `y1', `y2', `pl', `_results'[1,3],0,1)      /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[2,3],1,1)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[3,3],2,1)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[4,3],3,1)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[5,3],4,1)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[6,3],5,1)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[7,3],6,1)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[8,3],0,2)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[9,3],1,2)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[10,3],2,2)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[11,3],3,2)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[12,3],4,2)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[13,3],5,2)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[14,3],6,2)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[15,3],0,3)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[16,3],1,3)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[17,3],2,3)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[18,3],3,3)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[19,3],4,3)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[20,3],5,3)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[21,3],6,3)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[22,3],0,4)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[23,3],1,4)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[24,3],2,4)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[25,3],3,4)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[26,3],4,4)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[27,3],5,4)  /*
							*/  \ (999,  `y1', `y2', `pl', `_results'[28,3],6,4)  
		
		
		
	
		tempvar _region
		gen `_region'=.
		autolel_def_region `_region'
		
		forvalues j = 1(1)3 {
					
			qui adecomp ipcf_ppp pocup_man ila_man_ocup pocup_woman ila_woman_ocup  pc_otinla  dependency ///
			[w=pondera] , by(year) eq(c6*((c1*c2)+(c3*c4))+c5) varpl(lp_`pl'usd_ppp) in(fgt0 fgt1 fgt2 gini theil) 
			mat `_results' = r(b)

			mat _main_mat_barros = nullmat(_main_mat_barros)  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[1,3],0,1)      /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[2,3],1,1)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[3,3],2,1)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[4,3],3,1)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[5,3],4,1)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[6,3],5,1)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[7,3],6,1)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[8,3],0,2)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[9,3],1,2)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[10,3],2,2)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[11,3],3,2)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[12,3],4,2)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[13,3],5,2)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[14,3],6,2)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[15,3],0,3)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[16,3],1,3)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[17,3],2,3)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[18,3],3,3)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[19,3],4,3)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[20,3],5,3)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[21,3],6,3)  /*  
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[22,3],0,3)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[23,3],1,4)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[24,3],2,4)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[25,3],3,4)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[26,3],4,4)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[27,3],5,4)  /*
								*/  \ (`=`j'+999',  `y1', `y2', `pl', `_results'[28,3],6,4)    
		
		
							
		} // end of regional loop				
	} // end of LAC condition
		else {
		* Keep if consistent obervation
		capture keep if cohh==1 & ipcf!=.
	
		adecomp ipcf_ppp pocup_man ila_man_ocup pocup_woman ila_woman_ocup  pc_otinla  dependency ///
		[w=pondera] , by(year) eq(c6*((c1*c2)+(c3*c4))+c5) varpl(lp_`pl'usd_ppp) in(fgt0 fgt1 gini) 
		mat `_results' = r(b)
		
    	mat _main_mat_barros = nullmat(_main_mat_barros)  \ (`n_country',  `y1', `y2', `pl', `_results'[1,3],0,1)      /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[2,3],1,1)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[3,3],2,1)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[4,3],3,1)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[5,3],4,1)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[6,3],5,1)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[7,3],6,1)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[8,3],0,2)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[9,3],1,2)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[10,3],2,2)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[11,3],3,2)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[12,3],4,2)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[13,3],5,2)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[14,3],6,2)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[15,3],0,3)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[16,3],1,3)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[17,3],2,3)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[18,3],3,3)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[19,3],4,3)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[20,3],5,3)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[21,3],6,3)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[22,3],0,4)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[23,3],1,4)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[24,3],2,4)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[25,3],3,4)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[26,3],4,4)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[27,3],5,4)  /*
							*/  \ (`n_country',  `y1', `y2', `pl', `_results'[28,3],6,4) 
		
	} // end of else condition
} //pls
	capture return matrix _main_mat_barros = _main_mat_barros
} // end of quietly
	end
	
	
	
	
	Dependency* Portion occupied men * (ila per cccupied man)
adecomp ipcf_ppp11 pocup_man ila_man_ocup pocup_woman ila_woman_ocup  pc_otinla dependency [w=pondera] , by(gyear) eq(c6*((c1*c2)+(c3*c4))+c5) varpl(lp_5usd_ppp) in(fgt0)



end

exit

****************************************



Notes:

Z:\public\Stats_Team\LAC Equity Lab\Dashboards\poverty\2018\release 1\do-files

From: 4.shapley_LAC_lel_genderNdependency.do

Dependency* Portion occupied men * (ila per cccupied man)
adecomp ipcf_ppp11 pocup_man ila_man_ocup pocup_woman ila_woman_ocup  pc_otinla dependency [w=pondera] , by(gyear) eq(c6*((c1*c2)+(c3*c4))+c5) varpl(lp_5usd_ppp) in(fgt0)

From: 4.shapley_LAC_lel15@withoutshare2.do
adecomp ipcf_ppp11 ila_man_pc ila_woman_pc  pc_otinla pc_itran_ppp pc_ijubi_ppp  [w=pondera] , by(gyear) eq(c1+c2+c3+c4+c5) varpl(lp_1usd_ppp) in(fgt0 fgt1 fgt2 gini)

