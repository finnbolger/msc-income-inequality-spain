clear all
set more off

import delimited "/Users/finn/Desktop/TFG/panel_v5.csv", clear
xtset city_id year

preserve
keep if year == 2022
collapse (mean) gini p80p20 below60 above200 unemployment income_pc ///
    industrial_share pct_foreign pct_65 log_pop, by(city_id)

* ── GINI ─────────────────────────────────────────────────────
reg gini log_pop pct_65 pct_foreign, robust
estimates store cs_g_m1
reg gini unemployment income_pc industrial_share, robust
estimates store cs_g_m2
reg gini log_pop pct_65 pct_foreign unemployment income_pc industrial_share, robust
estimates store cs_g_m3

esttab cs_g_m1 cs_g_m2 cs_g_m3 using ///
    "/Users/finn/Desktop/TFG/gini_2022_v5.rtf", ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("Cross-Section OLS: Gini Index (2022)") ///
    mtitles("Demographics" "Economics" "All variables") ///
    stats(N r2, labels("Observations" "R-squared")) ///
    note("Robust SE. 2022 cross-section.") nogaps compress replace

* ── P80/P20 ──────────────────────────────────────────────────
reg p80p20 log_pop pct_65 pct_foreign, robust
estimates store cs_p_m1
reg p80p20 unemployment income_pc industrial_share, robust
estimates store cs_p_m2
reg p80p20 log_pop pct_65 pct_foreign unemployment income_pc industrial_share, robust
estimates store cs_p_m3

esttab cs_p_m1 cs_p_m2 cs_p_m3 using ///
    "/Users/finn/Desktop/TFG/p80p20_2022_v5.rtf", ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("Cross-Section OLS: P80/P20 (2022)") ///
    mtitles("Demographics" "Economics" "All variables") ///
    stats(N r2, labels("Observations" "R-squared")) ///
    note("Robust SE. 2022 cross-section.") nogaps compress replace

* ── BELOW 60% ────────────────────────────────────────────────
reg below60 log_pop pct_65 pct_foreign, robust
estimates store cs_b_m1
reg below60 unemployment income_pc industrial_share, robust
estimates store cs_b_m2
reg below60 log_pop pct_65 pct_foreign unemployment income_pc industrial_share, robust
estimates store cs_b_m3

esttab cs_b_m1 cs_b_m2 cs_b_m3 using ///
    "/Users/finn/Desktop/TFG/below60_2022_v5.rtf", ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("Cross-Section OLS: Below 60% of Median (2022)") ///
    mtitles("Demographics" "Economics" "All variables") ///
    stats(N r2, labels("Observations" "R-squared")) ///
    note("Robust SE. 2022 cross-section.") nogaps compress replace

* ── ABOVE 200% ───────────────────────────────────────────────
reg above200 log_pop pct_65 pct_foreign, robust
estimates store cs_a_m1
reg above200 unemployment income_pc industrial_share, robust
estimates store cs_a_m2
reg above200 log_pop pct_65 pct_foreign unemployment income_pc industrial_share, robust
estimates store cs_a_m3

esttab cs_a_m1 cs_a_m2 cs_a_m3 using ///
    "/Users/finn/Desktop/TFG/above200_2022_v5.rtf", ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("Cross-Section OLS: Above 200% of Median (2022)") ///
    mtitles("Demographics" "Economics" "All variables") ///
    stats(N r2, labels("Observations" "R-squared")) ///
    note("Robust SE. 2022 cross-section.") nogaps compress replace

restore

di "DONE - all 4 cross-section tables updated with constants"
