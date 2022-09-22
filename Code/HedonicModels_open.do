*******************************************************************************************************
* Created: 		May, 2021
* By: 			Asli Mutlu
* For: 			Hedonic Price Analysis - Limburg Provience
* Last edited: 	June, 2022
********************************************************************************************************
	
********************************************************************************************************
*************** System parameters **********************************************************************
********************************************************************************************************
cap log close
clear all
set more off
// You need to specify an existing folder in which you can write!
// E.g., your own drive
sysdir set PLUS "/Users/Admin/Documents/Stata" 
sysdir set PERSONAL "/Users/Admin/Documents/Stata" 
//ssc install outreg2, replace				// Install a package
//ssc install coefplot, replace
//ssc install asdoc, replace
//net install asdoc, from (http://fintechprofessor.com) replace
//ssc install estout, replace
//ssc install ivreg2
//ssc install ranktest
//ssc install weakivtest
//ssc install avar
//ssc install reghdfe
// ssc install ftools
//ssc install sppack, replace

set matsize 5000
cd "/Users/Admin/Desktop/Hedonic"
log using "/Users/Admin/Desktop/Hedonic/Output", replace



* ================================================= *
*													*
*					   DATA 		    	    	*
*													*
* ================================================= *

use "Limburg_transactions.dta", clear
di"$S_DATE $S_TIME "

* ================================================= *
*													*
*					REGRESSIONS		    	    	*
*													*
* ================================================= *

* ================== VARIABLES ==================== *

/// The independent variables below are the control variables for housing characteristics
/// such as parcel size, garden, number of rooms.

global housing "perceel sq_perceel tuin sq_tuin woon sq_woon nkamers sq_kamer lift zolder onbi onbu monument monumentaal zwembad parking tom i.tuinafw i.nverdiep cons_1600_1905 cons_1906_30 cons_1930_44 cons_1945_59 cons_1960_69 cons_1970_79 cons_1980_89 cons_1990_99 cons_2000_20"

/// The independent variables below are the control variables for location characteristics
/// such as distance to river and main roads.

global distances "River250m River500m River1000m River1500m River2000m Roads250m Roads500m"


* ================== MODEL 1 ==================== *

/// Model 1 estimates the effect of dynamic flood risk on the flood-prone property values in the Limburg Provience. The variable Floodprone = 1 if the property is in the flood-prone area, otherwise 0. The variable Years is a categorical variable which is a set of year groups. Each year group consist of four years. SpatialFE is spatial fixed effects that controls for spatial heterogeneity across municipalities. YearFE is time fixed effects that controls for temporaneous changes in the housing market such as macroeconomic changes and inflation. Throught, we cluster standard errors at the 6 digit postoce level (PC6). 

reghdfe ln_price i.Floodprone##i.Years $housing $distances, a(SpatialFE YearFE) vce (cluster PC6)


* ================== MODEL 2 ==================== *

/// Model 2 estimates the effect of gray solutions and nature-based solutions for flood management in North Limburg and South Limburg, respectively.

***** Model 2 - North Limburg - Dike-based traditional flood management *****

reghdfe ln_price i.PostGray##(River250m River500m River1000m River1500m River2000m) $housing Roads250m Roads500m if NorthLimburg==1 & Year >=2000, a(SpatialFE YearFE) vce(cluster PC6)

***** Model 2 - South Limburg - Nature-based solutions for flood management *****

reghdfe ln_price i.PostNbS##(River250m River500m River1000m River1500m River2000m) $housing Roads250m Roads500m if SouthLimburg==1 & Year >=2000, a(SpatialFE YearFE) vce(cluster PC6)

log close

