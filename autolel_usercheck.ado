*===============================================================================
* USER NAMES
* This version: 09/SEP/2016 --- Carlos Felipe Balcazar
* Update: 15/MAY/2017 --- Christian Camilo Gomez
cap program drop autolel_usercheck
program define autolel_usercheck, rclass
quietly {
	local accept = 0
	local user = lower("`c(username)'")
	disp "Datalib user: `user'" 

	if   ("`user'" == "wb384996" 		/// Andres Castaneda
		| "`user'" == "wb267475"			/// Carolina Diaz-Bonilla
		| "`user'" == "wb473845"			/// Laura Moreno
		| "`user'" == "wb375729"			/// Maria Laura Oliveri
		| "`user'" == "wb507378"			/// Natalia Garcia Pena
		| "`user'" == "wb507377"			/// Jorge Soler
		| "`user'" == "wb509172"			/// Christian Camilo Gomez
	) local accept = 1

	* Check acceptance

	if (`accept' != 1) {
		disp in red "You are not authorized to update the poverty and inequality indicators." _n ///
		"Please, send and email to: " _cont
		disp in r "{browse mailto:LAC_Stats@worldbank.org}" _cont
		disp in r " in order to have access."
		disp in r "You can use the path option to save the results in another workspace."
		error 
	}		// if (`accept' == 0) 

	return local user `user'
}
end


