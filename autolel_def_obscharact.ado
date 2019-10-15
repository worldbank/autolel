*===============================================================================
* CHARACTERISTICS TO BE USED
* This version: 23/MAY/2017 --- Carlos Felipe Balcazar
program define autolel_def_obscharact
quietly {
	* Gender household Head 
	gen  mujer_HH=1 if   jefe ==1 & hombre == 0
	replace mujer_HH=0 if   jefe ==1  & mujer_HH==. 

	* Years of education 
	gen aedu_higher=aedu if edad>=18
	bys id pais: egen aedu_h = mean(aedu_higher)
	drop  aedu_higher 

	* Enrollment  6-14 years of age 
	gen attainment_aux= asiste==1 & edad>5 & edad<15
	replace attainment_aux=. if edad<=5 | edad>=15
	bys id pais: egen attainment = mean(attainment_aux)
	drop attainment_aux

	* Enrollment  15-24 years of age
	gen aux_univ_enrollment= asiste==1 & edad>=15 & edad<=24
	replace aux_univ_enrollment=. if edad<15 | edad>24
	replace aux_univ_enrollment=1 if nivel==6 & aux_univ_enrollment==0
	bys id pais: egen univ_education = mean(aux_univ_enrollment)
	drop aux_univ_enrollment

	* Number of Children
	cap drop persona
	gen persona = 1
	 
	cap drop aux
	bys id pais: egen aux = sum(persona) if edad <15 & jefe != 1
	bys id pais: egen num_children  = max(aux)
	recode num_children  . = 0 

	* Calculate population
	qui: su id [w = pondera]
	loc pop_tot = r(sum_w)
} // end of quietly
end
