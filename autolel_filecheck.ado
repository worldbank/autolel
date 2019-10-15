
program define autolel_filecheck, rclass
syntax, [path(string) modules(string)]

* Check if any one file exists and create a folder
quietly {
	
	noi disp as txt  _n "{col 6} making backup" _n "{col 8}"
	
	foreach module of local modules {
		capture confirm file "${output_LEL}\\`module'.txt"
		if _rc==0    {
			local _day : di %tdNN-DD-CCYY date("$S_DATE", "DMY")
			tempname dir
			mata: st_numscalar("`dir'", direxists("${output_LEL}\LEL_`_day'"))
			if (`dir' == 0) mkdir "${output_LEL}\LEL_`_day'"
			noi disp as result _c "."
			copy "${output_LEL}\\`module'.txt" ///
			"${output_LEL}\LEL_`_day'\\`module'.txt", replace public
		} // end of existence condition
	} // end of module loop
} // end of quietly

end

exit

