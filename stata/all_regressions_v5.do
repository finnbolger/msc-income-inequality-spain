clear all
set more off

import delimited "/Users/finn/Desktop/TFG/panel_v5.csv", clear

* Declare panel
xtset city_id year

label variable gini "Gini Index"
label variable p80p20 "P80/P20 Ratio"
label variable below60 "Below 60% of Median"
label variable above200 "Above 200% of Median"
label variable unemployment "Unemployment rate (%)"
label variable income_pc "Net income per capita (€)"
label variable industrial_share "Employment in industry (%)"
label variable pct_foreign "Foreign nationals (%)"
label variable pct_65 "Population aged 65+ (%)"
label variable log_pop "Log resident population"

* ============================================================
* TABLE 1: CROSS-SECTION 2022 ONLY
* ============================================================
preserve
keep if year == 2022
collapse (mean) gini p80p20 below60 above200 unemployment income_pc ///
    industrial_share pct_foreign pct_65 log_pop, by(city_id)

* Gini
reg gini log_pop pct_65 pct_foreign, robust
estimates store cs_g_m1
reg gini unemployment income_pc industrial_share, robust
estimates store cs_g_m2
reg gini log_pop pct_65 pct_foreign unemployment income_pc industrial_share, robust
estimates store cs_g_m3

* P80/P20
reg p80p20 log_pop pct_65 pct_foreign, robust
estimates store cs_p_m1
reg p80p20 unemployment income_pc industrial_share, robust
estimates store cs_p_m2
reg p80p20 log_pop pct_65 pct_foreign unemployment income_pc industrial_share, robust
estimates store cs_p_m3

* Below 60%
reg below60 log_pop pct_65 pct_foreign, robust
estimates store cs_b_m1
reg below60 unemployment income_pc industrial_share, robust
estimates store cs_b_m2
reg below60 log_pop pct_65 pct_foreign unemployment income_pc industrial_share, robust
estimates store cs_b_m3

* Above 200%
reg above200 log_pop pct_65 pct_foreign, robust
estimates store cs_a_m1
reg above200 unemployment income_pc industrial_share, robust
estimates store cs_a_m2
reg above200 log_pop pct_65 pct_foreign unemployment income_pc industrial_share, robust
estimates store cs_a_m3

* Export cross-section tables
esttab cs_g_m1 cs_g_m2 cs_g_m3 using ///
    "/Users/finn/Desktop/TFG/gini_2022_v5.rtf", ///
    keep(log_pop pct_65 pct_foreign unemployment income_pc industrial_share) ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("Cross-Section OLS: Gini Index (2022)") ///
    mtitles("Demographics" "Economics" "All variables") ///
    stats(N r2, labels("Observations" "R-squared")) ///
    note("Robust SE. 2022 cross-section.") nogaps compress replace

esttab cs_p_m1 cs_p_m2 cs_p_m3 using ///
    "/Users/finn/Desktop/TFG/p80p20_2022_v5.rtf", ///
    keep(log_pop pct_65 pct_foreign unemployment income_pc industrial_share) ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("Cross-Section OLS: P80/P20 (2022)") ///
    mtitles("Demographics" "Economics" "All variables") ///
    stats(N r2, labels("Observations" "R-squared")) ///
    note("Robust SE. 2022 cross-section.") nogaps compress replace

esttab cs_b_m1 cs_b_m2 cs_b_m3 using ///
    "/Users/finn/Desktop/TFG/below60_2022_v5.rtf", ///
    keep(log_pop pct_65 pct_foreign unemployment income_pc industrial_share) ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("Cross-Section OLS: Below 60% of Median (2022)") ///
    mtitles("Demographics" "Economics" "All variables") ///
    stats(N r2, labels("Observations" "R-squared")) ///
    note("Robust SE. 2022 cross-section.") nogaps compress replace

esttab cs_a_m1 cs_a_m2 cs_a_m3 using ///
    "/Users/finn/Desktop/TFG/above200_2022_v5.rtf", ///
    keep(log_pop pct_65 pct_foreign unemployment income_pc industrial_share) ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("Cross-Section OLS: Above 200% of Median (2022)") ///
    mtitles("Demographics" "Economics" "All variables") ///
    stats(N r2, labels("Observations" "R-squared")) ///
    note("Robust SE. 2022 cross-section.") nogaps compress replace

restore

* ============================================================
* TABLE 2: PANEL FIXED EFFECTS
* ============================================================

* Gini FE
xtreg gini log_pop pct_65 pct_foreign i.year, fe vce(cluster city_id)
estimates store fe_g_m1
xtreg gini unemployment income_pc industrial_share i.year, fe vce(cluster city_id)
estimates store fe_g_m2
xtreg gini log_pop pct_65 pct_foreign unemployment income_pc industrial_share i.year, fe vce(cluster city_id)
estimates store fe_g_m3

* P80/P20 FE
xtreg p80p20 log_pop pct_65 pct_foreign i.year, fe vce(cluster city_id)
estimates store fe_p_m1
xtreg p80p20 unemployment income_pc industrial_share i.year, fe vce(cluster city_id)
estimates store fe_p_m2
xtreg p80p20 log_pop pct_65 pct_foreign unemployment income_pc industrial_share i.year, fe vce(cluster city_id)
estimates store fe_p_m3

* Below 60% FE
xtreg below60 log_pop pct_65 pct_foreign i.year, fe vce(cluster city_id)
estimates store fe_b_m1
xtreg below60 unemployment income_pc industrial_share i.year, fe vce(cluster city_id)
estimates store fe_b_m2
xtreg below60 log_pop pct_65 pct_foreign unemployment income_pc industrial_share i.year, fe vce(cluster city_id)
estimates store fe_b_m3

* Above 200% FE
xtreg above200 log_pop pct_65 pct_foreign i.year, fe vce(cluster city_id)
estimates store fe_a_m1
xtreg above200 unemployment income_pc industrial_share i.year, fe vce(cluster city_id)
estimates store fe_a_m2
xtreg above200 log_pop pct_65 pct_foreign unemployment income_pc industrial_share i.year, fe vce(cluster city_id)
estimates store fe_a_m3

* Export FE tables
esttab fe_g_m1 fe_g_m2 fe_g_m3 fe_p_m1 fe_p_m2 fe_p_m3 using ///
    "/Users/finn/Desktop/TFG/fe_gini_p80p20_v5.rtf", ///
    keep(log_pop pct_65 pct_foreign unemployment income_pc industrial_share) ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("Panel FE: Gini and P80/P20") ///
    mtitles("G-M1" "G-M2" "G-M3" "P-M1" "P-M2" "P-M3") ///
    stats(N r2_within, labels("Observations" "R2 within")) ///
    note("City and year FE. Clustered SE. All years.") nogaps compress replace

esttab fe_b_m1 fe_b_m2 fe_b_m3 fe_a_m1 fe_a_m2 fe_a_m3 using ///
    "/Users/finn/Desktop/TFG/fe_below_above_v5.rtf", ///
    keep(log_pop pct_65 pct_foreign unemployment income_pc industrial_share) ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("Panel FE: Below 60% and Above 200%") ///
    mtitles("B-M1" "B-M2" "B-M3" "A-M1" "A-M2" "A-M3") ///
    stats(N r2_within, labels("Observations" "R2 within")) ///
    note("City and year FE. Clustered SE. All years.") nogaps compress replace

* ============================================================
* TABLE 3: GMM IV
* ============================================================

* Gini GMM IV
xtivreg gini (log_pop pct_65 pct_foreign = ///
    L.log_pop L.pct_65 L.pct_foreign) i.year, fe vce(cluster city_id)
estimates store iv_g_m1

xtivreg gini (unemployment income_pc industrial_share = ///
    L.unemployment L.income_pc L.industrial_share) i.year, fe vce(cluster city_id)
estimates store iv_g_m2

xtivreg gini (log_pop pct_65 pct_foreign unemployment ///
    income_pc industrial_share = L.log_pop L.pct_65 ///
    L.pct_foreign L.unemployment L.income_pc ///
    L.industrial_share) i.year, fe vce(cluster city_id)
estimates store iv_g_m3

* P80/P20 GMM IV
xtivreg p80p20 (log_pop pct_65 pct_foreign = ///
    L.log_pop L.pct_65 L.pct_foreign) i.year, fe vce(cluster city_id)
estimates store iv_p_m1

xtivreg p80p20 (unemployment income_pc industrial_share = ///
    L.unemployment L.income_pc L.industrial_share) i.year, fe vce(cluster city_id)
estimates store iv_p_m2

xtivreg p80p20 (log_pop pct_65 pct_foreign unemployment ///
    income_pc industrial_share = L.log_pop L.pct_65 ///
    L.pct_foreign L.unemployment L.income_pc ///
    L.industrial_share) i.year, fe vce(cluster city_id)
estimates store iv_p_m3

* Below 60% GMM IV
xtivreg below60 (log_pop pct_65 pct_foreign = ///
    L.log_pop L.pct_65 L.pct_foreign) i.year, fe vce(cluster city_id)
estimates store iv_b_m1

xtivreg below60 (unemployment income_pc industrial_share = ///
    L.unemployment L.income_pc L.industrial_share) i.year, fe vce(cluster city_id)
estimates store iv_b_m2

xtivreg below60 (log_pop pct_65 pct_foreign unemployment ///
    income_pc industrial_share = L.log_pop L.pct_65 ///
    L.pct_foreign L.unemployment L.income_pc ///
    L.industrial_share) i.year, fe vce(cluster city_id)
estimates store iv_b_m3

* Above 200% GMM IV
xtivreg above200 (log_pop pct_65 pct_foreign = ///
    L.log_pop L.pct_65 L.pct_foreign) i.year, fe vce(cluster city_id)
estimates store iv_a_m1

xtivreg above200 (unemployment income_pc industrial_share = ///
    L.unemployment L.income_pc L.industrial_share) i.year, fe vce(cluster city_id)
estimates store iv_a_m2

xtivreg above200 (log_pop pct_65 pct_foreign unemployment ///
    income_pc industrial_share = L.log_pop L.pct_65 ///
    L.pct_foreign L.unemployment L.income_pc ///
    L.industrial_share) i.year, fe vce(cluster city_id)
estimates store iv_a_m3

* Export GMM IV tables
esttab iv_g_m1 iv_g_m2 iv_g_m3 iv_p_m1 iv_p_m2 iv_p_m3 using ///
    "/Users/finn/Desktop/TFG/iv_gini_p80p20_v5.rtf", ///
    keep(log_pop pct_65 pct_foreign unemployment income_pc industrial_share) ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("GMM IV: Gini and P80/P20") ///
    mtitles("G-M1" "G-M2" "G-M3" "P-M1" "P-M2" "P-M3") ///
    stats(N, labels("Observations")) ///
    note("Panel IV-FE. Lagged values as instruments. Clustered SE.") ///
    nogaps compress replace

esttab iv_b_m1 iv_b_m2 iv_b_m3 iv_a_m1 iv_a_m2 iv_a_m3 using ///
    "/Users/finn/Desktop/TFG/iv_below_above_v5.rtf", ///
    keep(log_pop pct_65 pct_foreign unemployment income_pc industrial_share) ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("GMM IV: Below 60% and Above 200%") ///
    mtitles("B-M1" "B-M2" "B-M3" "A-M1" "A-M2" "A-M3") ///
    stats(N, labels("Observations")) ///
    note("Panel IV-FE. Lagged values as instruments. Clustered SE.") ///
    nogaps compress replace

* ============================================================
* DESCRIPTIVE STATISTICS
* ============================================================
preserve
keep if year == 2022
collapse (mean) gini p80p20 below60 above200 unemployment income_pc ///
    industrial_share pct_foreign pct_65 log_pop, by(city_id)

estpost summarize gini p80p20 below60 above200 unemployment ///
    income_pc industrial_share pct_foreign pct_65 log_pop

esttab using "/Users/finn/Desktop/TFG/descriptive_stats_v5.rtf", ///
    cells("mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") ///
    title("Descriptive Statistics (2022)") replace

restore

di "ALL DONE - check TFG folder for v5 tables"
