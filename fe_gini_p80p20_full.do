clear all
set more off

import delimited "/Users/finn/Desktop/TFG/panel_v4.csv", clear

* NOTE: This time we keep 2020 and 2021
collapse (mean) gini p80p20 unemployment income_pc industrial_share ///
    pct_foreign pct_65 log_pop, by(city_id year)
xtset city_id year

* Gini FE
xtreg gini log_pop pct_65 pct_foreign i.year, fe vce(cluster city_id)
estimates store fe_gini_m1

xtreg gini unemployment income_pc industrial_share i.year, fe vce(cluster city_id)
estimates store fe_gini_m2

xtreg gini log_pop pct_65 pct_foreign unemployment income_pc industrial_share i.year, fe vce(cluster city_id)
estimates store fe_gini_m3

* P80/P20 FE
xtreg p80p20 log_pop pct_65 pct_foreign i.year, fe vce(cluster city_id)
estimates store fe_p_m1

xtreg p80p20 unemployment income_pc industrial_share i.year, fe vce(cluster city_id)
estimates store fe_p_m2

xtreg p80p20 log_pop pct_65 pct_foreign unemployment income_pc industrial_share i.year, fe vce(cluster city_id)
estimates store fe_p_m3

esttab fe_gini_m1 fe_gini_m2 fe_gini_m3 fe_p_m1 fe_p_m2 fe_p_m3 using ///
    "/Users/finn/Desktop/TFG/fe_gini_p80p20_full.rtf", ///
    keep(log_pop pct_65 pct_foreign unemployment income_pc industrial_share) ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("Panel Fixed Effects: Gini and P80/P20 (Full Sample)") ///
    mtitles("G-M1" "G-M2" "G-M3" "P-M1" "P-M2" "P-M3") ///
    stats(N, labels("Observations")) ///
    note("City and year FE. Clustered SE at city level. All years included.") ///
    nogaps compress replace

di "Done - fe_gini_p80p20_full.rtf saved"
