{smcl}
{* *! version 1.0 12 Apr 2017}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "autolel##syntax"}{...}
{viewerjumpto "Description" "autolel##description"}{...}
{viewerjumpto "Options" "autolel##options"}{...}
{viewerjumpto "Remarks" "autolel##remarks"}{...}
{viewerjumpto "Examples" "autolel##examples"}{...}
{title:Title}
{phang}
{bf:autolel} {hline 2} Calculates the indicators hosted in LAC Equity Lab (LEL).{p_end}
{phang}
{bf:Note}:{err: help file in progress}

{marker description}{...}
{title:Description}

{pstd}
{cmd:autolel} is a Stata command developed by the LAC Team for Statistical 
Development (TSD) in the Poverty Global Practice of the World Bank that allows
users to calculate the numbers in LEL using the microdata library maintained by the LAC TSD. In 
addition, {cmd:autolel} is used by LAC TSD to update LEL.   

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmd:autolel} [{it:calculation}]{cmd:,} [{it:{help autolel##options:Options}}] 

{pstd}
where {it:calculation} refers to the type/s of analysis that the user
wants to perform. See {help autolel##calclist:list} of available calculations. 

{marker sections}{...}
{title:sections}

{pstd}
Sections are presented under the following headings:

		{it:{help autolel##desc:Command description}}
		{it:{help autolel##calclist:List of available calculations}}
		{it:{help autolel##Options2:Options description}}
		{it:{help autolel##Examples:Examples}}


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:{help autolel##basics:Basics}}
{synopt:{opt coun:tries(string)}}Three-letter {help autolel##isocodes:ISO code} of LAC countries.{p_end}
{synopt:{opt y:ears(numlist)}}List of years for which the data is requested.{p_end}
{synopt:{opt cir:ca(numlist)}}List of circa years for which the data is requested. 
based on circa criteria [-2,2]{p_end}
{synopt:{opt range(numlist)}}First and second period for decompositions and changes.{p_end}
{synopt:{opt byarea}}Specify calculations by Urban and Rural areas.{p_end}

{syntab:{help autolel##saving:Saving and Update}}
{synopt:{opt path(string)}}Directory path to save results. Default {it:current directory}.{p_end}
{synopt:{opt save}}Save results when option {it:path()} is empty.{p_end}
{synopt:{opt update}}Update LEL dashboards. Functionality is upi-dependent.{p_end}
{synopt:{opt cedlas}}Updates the CEDLAS-LEL dashboards. Functionality is upi-dependent. It must be used with {bf: update} option.{p_end}
{synopt:{opt replace}}replace existing results files.{p_end}

{syntab:{help autolel##various:Various}}
{synopt:{opt lang:uage(string)}}Language of results. Only English {it:(en)}, Spanish {it:(sp)}, or {it:both} available.{p_end}
{synopt:{opt noshow}}Do not show results.{p_end}
{synopt:{opt clear}}Clear current dataset in memory.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}


{marker calclist}{...}
{title:Calculations Available}

{col 8}Entry{col 28}Description
{col 8}{hline 61}

{col 8}   {c TLC}{hline 14}{c TRC}
{col 8}{hline 3}{c RT}{it:Cross-sections}{c LT}{hline}
{col 8}   {c BLC}{hline 14}{c BRC}

{col 8}{bf:{browse "http://globalpractices.worldbank.org/teamsites/Poverty/LACDataLab/SitePages/Headcount.aspx":pov}}{...}
{col 28}Poverty numbers. this is the default

{col 8}{bf:{browse "http://globalpractices.worldbank.org/teamsites/Poverty/LACDataLab/SitePages/trends.aspx":ine}}{...}
{col 28}Inequality indices e.g., Gini, theil, etc

{col 8}{bf:{browse "http://globalpractices.worldbank.org/teamsites/Poverty/LACDataLab/SitePages/quintile.aspx":inq}}{...}
{col 28}Decomposition of income distribution by quintile

{col 8}{bf:{browse "http://globalpractices.worldbank.org/teamsites/Poverty/LACDataLab/SitePages/incomedistribution.aspx":dis}}{...}
{col 28}Distribution by percentiles

{col 8}{bf:{browse "http://globalpractices.worldbank.org/teamsites/Poverty/LACDataLab/SitePages/Bottom40.aspx":b40}}{...}
{col 28}The profiles for the bottom 40 and other income groups

{col 8}{bf:{browse "http://globalpractices.worldbank.org/teamsites/Poverty/LACDataLab/SitePages/Official%20Poverty.aspx":oph}}{...}
{col 28}Official poverty headcount

{col 8}   {c TLC}{hline 35}{c TRC}
{col 8}{hline 3}{c RT}{it: Two cross-sections (range needed) }{c LT}{hline}
{col 8}   {c BLC}{hline 35}{c BRC}

{col 8}{bf:{browse "http://globalpractices.worldbank.org/teamsites/Poverty/LACDataLab/SitePages/growthbottom40.aspx":shp}}{...}
{col 28}Shared prosperity indicators

{col 8}{bf:{browse "http://globalpractices.worldbank.org/teamsites/Poverty/LACDataLab/SitePages/Headcount.aspx":drd}}{...}
{col 28}Datt-Ravallion decomposition

{col 8}{bf:{browse "http://globalpractices.worldbank.org/teamsites/Poverty/LACDataLab/SitePages/Headcount.aspx":bde}}{...}
{col 28}Barros (income source) decomposition

{col 8}   {c TLC}{hline 24}{c TRC}
{col 8}{hline 3}{c RT}{it: CEDLAS (update needed) }{c LT}{hline}
{col 8}   {c BLC}{hline 24}{c BRC}

{col 8}{bf:{browse "http://globalpractices.worldbank.org/teamsites/Poverty/LACDataLab/SitePages/Headcount.aspx":dem}}{...}
{col 28}Demographic characteristics

{col 8}{bf:{browse "http://globalpractices.worldbank.org/teamsites/Poverty/LACDataLab/SitePages/Headcount.aspx":dur}}{...}
{col 28}Durable goods

{col 8}{bf:{browse "http://globalpractices.worldbank.org/teamsites/Poverty/LACDataLab/SitePages/Headcount.aspx":edu}}{...}
{col 28}Educational outcomes

{col 8}{bf:{browse "http://globalpractices.worldbank.org/teamsites/Poverty/LACDataLab/SitePages/Headcount.aspx":hou}}{...}
{col 28}Housing outcomes

{col 8}{bf:{browse "http://globalpractices.worldbank.org/teamsites/Poverty/LACDataLab/SitePages/Headcount.aspx":inc}}{...}
{col 28}Income indicators

{col 8}{bf:{browse "http://globalpractices.worldbank.org/teamsites/Poverty/LACDataLab/SitePages/Headcount.aspx":ine}}{...}
{col 28}Inequality indices e.g., Gini, theil, etc

{col 8}{bf:{browse "http://globalpractices.worldbank.org/teamsites/Poverty/LACDataLab/SitePages/Headcount.aspx":pov}}{...}
{col 28}Poverty numbers.

{col 8}{bf:{browse "http://globalpractices.worldbank.org/teamsites/Poverty/LACDataLab/SitePages/Headcount.aspx":emp}}{...}
{col 28}Labor market indicators

{col 8}   {c TLC}{hline 25}{c TRC}
{col 8}{hline 3}{c RT}{it: Second order dashboards }{c LT}{hline}
{col 8}   {c BLC}{hline 25}{c BRC}

{col 8}{bf:{browse "http://www.worldbank.org/en/topic/poverty/lac-equity-lab1/overview":eho}}{...}
{col 28}External Homepage Overview

{col 8}{hline 61}


{marker options}{...}
{title:Options}
{marker basics}{...}
{dlgtab:Basics}

{phang}
{opt update} This option updates the files that feed the LAC Equity Lab Tableau dashboards, and creates a vintage copy
of the current version of LAC Equity LAB's files. Only authorized users can use this option. This option allows to
replace computations for specific countries and years, adds them if they do not exist (e.g., if there is a new year and 
an update is required), or replaces all existent computations (i.e., performs a full update) if no country or years are
specified by the user. If you are not authorized to update the LAC Equity Lab, this option will return error. 

{phang}
{opt cedlas} This option needs the {bf: update} option to be used. This option updates the files that feed the CEDLAS LAC
Equity Lab Tableau dashboards, and creates a vintage copy of the current version of LAC Equity LAB's files. Only authorized
users can use this option. This option allows to replace computations for specific countries and years, adds them if they 
do not exist (e.g., if there is a new year and an update is required), or replaces all existent computations 
(i.e., performs a full update) if no country or years are specified by the user. If you are not authorized to update 
the CEDLAS LAC Equity Lab, this option will return error.

{phang}
{opt coun:tries(string)}  Specifies the {help autolel##isocodes:ISO code} of the country(ies) for which
calculations will be carried out. ISO codes must be input in lower case. {p_end}

{phang}
{opt y:ears(numlist)}  List of years for which calculations will be carried out. If country-year combination does not exist 
calculations the program will not provide any results for such combination; user can use circa option instead.{p_end} 

{phang}
{opt cir:ca(numlist)}  It is a list of years based on the circa criteria. If a circa year is requested and such data set exists
{bf: autolel} will use the corresponding data set. When such data set is not found autolel will look for the data set corresponding
to the next year. If this data set is not found then {bf: autolel} will look for the data set corresponding to the year previous
to the circa-year specified. If the data set is again not available, the process will repeat for two years forward and two years backwards
and so on. {p_end}


{phang}
{opt range(numlist)} It is a list of two years (max.) for which the shared prosperity numbers or the Datt-Ravallion or Barros decompositions
will be calculated. Two years are necessary since two cross sections are required for such calculations. {bf: autolel} uses the circa criteria
to find the corresponding data sets. When circa years for the first and second period coincide, the calculation will not performed. {p_end}


{phang}
{opt byarea} This option will present to the user with computations for the urban/rural split as well as national numbers. This option is accepted
only by {bf: poverty} and {bf: inequality} calculations. {p_end}

{marker saving}{...}
{dlgtab:Saving and Update}

{phang}
{opt path(string)}  If option {bf: save} is specified, results will be saved in excel format in {bf: path}. If {bf: path} is not specified, results will be
stored in {it:current directory}. If results already exist in current directory, user should use {bf: replace} option, otherwise program will return error. {p_end}

{phang}
{opt replace} If {bf: path} is specified, this option will rewrite the existing output excel file. {p_end}

{phang}
{opt save} Stores results in excel format in {bf: path} or {it:current directory} if {bf: path} is not specified.{p_end}


{marker various}{...}
{dlgtab:Various}

{phang}
{opt lang:uage(string)} Autolel can produce both results in english, spanish or both [in progress...]  {p_end} 

{phang}
{opt noshow} Results are shown in the command window to the user by default. This option deactivates this feature; results 
won't be shown in the command window. {p_end}  

{phang}
{opt clear} Removes data and value labels from memory. {p_end}

{marker examples}{...}
{title:Examples}
{pstd}

{p 2 4}The examples below use Colombia and Bolivia, but the user can change to any convenient country as long as the data exists.{p_end}

{dlgtab: Basic use}

{pstd}
Calculating poverty numbers for Colombia 2014. 

{p 8 12}{stata "autolel pov, countries(col) years(2014)" :. autolel pov, countries(col) years(2014)}{p_end}

{pstd}
Calculating inequality numbers for Colombia and Bolivia for 2010 and 2014. 

{p 8 12}{stata "autolel ine, countries(col bol) years(2010 2014)" :. autolel ine, countries(col bol) years(2010 2014)}{p_end}

{pstd}
Calculating poverty, inequality and bottom 40 profiles for Colombia and Bolivia circa 2010 and 2014. 

{p 8 12}{stata "autolel pov ine b40, countries(col bol) circa(2010 2014)" :. autolel pov ine b40, countries(col bol) circa(2010 2014)}{p_end}

{pstd}
Calculating the Datt-Ravallion decomposition for Colombia and Bolivia using 2009 and 2014 circa years.

{p 8 12}{stata "autolel drd, countries(col bol) range(2009 2014)" :. autolel drd, countries(col bol) range(2009 2014)}{p_end}

{pstd}
Calculating the shared prosperity numbers and barros decomposition for Colombia and Bolivia using 2009 and 2014 circa years, and clearing data from memory.

{p 8 12}{stata "autolel shp bde, countries(col bol) range(2009 2014) clear" :. autolel shp bde, countries(col bol) range(2009 2014) clear}{p_end}

{marker plpppex}{...}
{dlgtab: Saving}

{pstd}
Calculating poverty and inequality numbers for Colombia and Bolivia for 2010 and 2014, and saving results in {it:current directory}. 

{p 8 12}{stata "autolel pov ine, countries(col bol) years(2010 2014) save" :. autolel pov ine, countries(col bol) years(2010 2014) save}{p_end}

{pstd}
Calculating poverty and inequality numbers for Colombia and Bolivia for 2010 and 2014, and saving results in C:\Users\usernam\Documents. 

{p 8 12}{stata "autolel pov ine, countries(col bol) years(2010 2014) path(C:\Users\usernam\Documents) save" :. autolel pov ine, countries(col bol) years(2010 2014) path("C:\Users\usernam\Documents") save} 


{pstd}
Calculating poverty and inequality numbers for Colombia and Bolivia for 2010 and 2014, replacing results saved in C:\Users\usernam\Documents. 

{p 8 12}{stata "autolel pov ine, countries(col bol) years(2010 2014) path(C:\Users\usernam\Documents) save replace" :. autolel pov ine, countries(col bol) years(2010 2014) path("C:\Users\usernam\Documents") save replace} 


{dlgtab: Updating the LAC Equity LAB}

{pstd}
If you are an authorized user to update the LAC Equity LAB, these examples are useful for you.

{pstd}
Let us assume that we are going to replace the poverty numbers for Colombia 2014 only. 

{p 8 12}{stata "autolel pov, countries(col) years(2014) update" :. autolel pov, countries(col) years(2014) update}{p_end}

{pstd}
Let us assume that we are going to replace the poverty, inequality and bottom 40 profiles for Colombia and Bolivia circa 2010 and 2014. 

{p 8 12}{stata "autolel pov ine b40, countries(col bol) circa(2010 2014) update" :. autolel pov ine b40, countries(col bol) circa(2010 2014) update}{p_end}

{pstd}
Let us assume that we are going to replace the the Datt-Ravallion decomposition for Colombia and Bolivia using 2009 and 2014 circa years.

{p 8 12}{stata "autolel drd, countries(col bol) range(2009 2014) update" :. autolel drd, countries(col bol) range(2009 2014) update}{p_end}

{pstd}
Let us assume we desire to do a full update of the poverty numbers. 

{p 8 12}{stata "autolel pov, update" :. autolel pov, update}{p_end}

{pstd}
Let us assume we desire to do a full update of the poverty and inequality numbers, as well of the Datt-Ravallion decomposition. 

{p 8 12}{stata "autolel pov ine drd, update" :. autolel pov ine drd, update}{p_end}

{dlgtab: Updating the CEDLAS LAC Equity LAB}

{pstd}
If you are an authorized user to update the LAC Equity LAB, these examples are useful for you.

{pstd}
Let us assume that we are going to replace the poverty numbers for Colombia 2014 only. 

{p 8 12}{stata "autolel pov, countries(col) years(2014) cedlas update" :. autolel pov, countries(col) years(2014) cedlas update}{p_end}

{pstd}
Let us assume that we are going to replace the poverty, inequality and bottom 40 profiles for Colombia and Bolivia circa 2010 and 2014. 

{p 8 12}{stata "autolel pov ine, countries(col bol) years(2010 2014) cedlas update" :. autolel pov ine, countries(col bol) years(2010 2014) cedlas update}{p_end}


{title:Author}
{p}
{p 4 4 4}R.Andres Castaneda, The World Bank{p_end}
{p 6 6 4}Email {browse "acastanedaa@worldbank.org":acastanedaa@worldbank.org}{p_end}

{p 4 4 4}Felipe Balcazar, The World Bank{p_end}
{p 6 6 4}Email {browse "cbalcazarsalazar@worldbank.org":cbalcazarsalazar@worldbank.org}{p_end}


{title:Related commands:}

{help command1} (if installed)
{help command2} (if installed)   {stata ssc install command2} (to install this command)
