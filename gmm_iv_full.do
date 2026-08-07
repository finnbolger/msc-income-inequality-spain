clear all
set more off

import delimited "/Users/finn/Desktop/TFG/panel_v4.csv", clear

* Keep all years including 2020 and 2021
collapse (mean) gini p80p20 unemployment income_pc industrial_share ///
    pct_foreign pct_65 log_pop, by(city_id year)
xtset city_id year

* Gini GMM IV
xtivreg gini (log_pop pct_65 pct_foreign = ///
    L.log_pop L.pct_65 L.pct_foreign) i.year, ///
    fe vce(cluster city_id)
estimates store iv_gini_m1

xtivreg gini (unemployment income_pc industrial_share = ///
    L.unemployment L.income_pc L.industrial_share) i.year, ///
    fe vce(cluster city_id)
estimates store iv_gini_m2

xtivreg gini (log_pop pct_65 pct_foreign unemployment income_pc industrial_share = ///
    L.log_pop L.pct_65 L.pct_foreign L.unemployment L.income_pc L.industrial_share) ///
    i.year, fe vce(cluster city_id)
estimates store iv_gini_m3

* P80/P20 GMM IV 
xtivreg p80p20 (log_pop pct_65 pct_foreign = ///
    L.log_pop L.pct_65 L.pct_foreign) i.year, ///
    fe vce(cluster city_id)
estimates store iv_p_m1

xtivreg p80p20 (unemployment income_pc industrial_share = ///
    L.unemployment L.income_pc L.industrial_share) i.year, ///
    fe vce(cluster city_id)
estimates store iv_p_m2

xtivreg p80p20 (log_pop pct_65 pct_foreign unemployment ///
    income_pc industrial_share = L.log_pop L.pct_65 ///
    L.pct_foreign L.unemployment L.income_pc ///
    L.industrial_share) i.year, fe vce(cluster city_id)
estimates store iv_p_m3

esttab iv_gini_m1 iv_gini_m2 iv_gini_m3 iv_p_m1 iv_p_m2 iv_p_m3 using ///
    "/Users/finn/Desktop/TFG/iv_gini_p80p20_full.rtf", ///
    keep(log_pop pct_65 pct_foreign unemployment income_pc industrial_share) ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("GMM IV: Gini and P80/P20 (Full Sample)") ///
    mtitles("G-M1" "G-M2" "G-M3" "P-M1" "P-M2" "P-M3") ///
    stats(N, labels("Observations")) ///
    note("Panel IV-FE. Lagged values as instruments. Clustered SE. All years included.") ///
    nogaps compress replace

di "Done - iv_gini_p80p20_full.rtf saved"
