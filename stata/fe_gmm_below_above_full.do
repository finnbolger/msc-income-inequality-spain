clear all
set more off

import delimited "/Users/finn/Desktop/TFG/panel_v4.csv", clear

* Keep all years including 2020 and 2021
collapse (mean) below60 above200 unemployment income_pc industrial_share ///
    pct_foreign pct_65 log_pop, by(city_id year)
xtset city_id year

* ── FIXED EFFECTS: Below 60% ─────────────────────────────────
xtreg below60 log_pop pct_65 pct_foreign i.year, fe vce(cluster city_id)
estimates store fe_b_m1

xtreg below60 unemployment income_pc industrial_share i.year, fe vce(cluster city_id)
estimates store fe_b_m2

xtreg below60 log_pop pct_65 pct_foreign unemployment income_pc industrial_share i.year, fe vce(cluster city_id)
estimates store fe_b_m3

esttab fe_b_m1 fe_b_m2 fe_b_m3 using ///
    "/Users/finn/Desktop/TFG/fe_below60_full.rtf", ///
    keep(log_pop pct_65 pct_foreign unemployment income_pc industrial_share) ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("Panel FE: Below 60% of Median (Full Sample)") ///
    mtitles("Demographics" "Economics" "All variables") ///
    stats(N, labels("Observations")) ///
    note("City and year FE. Clustered SE. All years included.") ///
    nogaps compress replace

* ── FIXED EFFECTS: Above 200% ────────────────────────────────
xtreg above200 log_pop pct_65 pct_foreign i.year, fe vce(cluster city_id)
estimates store fe_a_m1

xtreg above200 unemployment income_pc industrial_share i.year, fe vce(cluster city_id)
estimates store fe_a_m2

xtreg above200 log_pop pct_65 pct_foreign unemployment income_pc industrial_share i.year, fe vce(cluster city_id)
estimates store fe_a_m3

esttab fe_a_m1 fe_a_m2 fe_a_m3 using ///
    "/Users/finn/Desktop/TFG/fe_above200_full.rtf", ///
    keep(log_pop pct_65 pct_foreign unemployment income_pc industrial_share) ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("Panel FE: Above 200% of Median (Full Sample)") ///
    mtitles("Demographics" "Economics" "All variables") ///
    stats(N, labels("Observations")) ///
    note("City and year FE. Clustered SE. All years included.") ///
    nogaps compress replace

* ── GMM IV: Below 60% ────────────────────────────────────────
xtivreg below60 (log_pop pct_65 pct_foreign = ///
    L.log_pop L.pct_65 L.pct_foreign) i.year, ///
    fe vce(cluster city_id)
estimates store iv_b_m1

xtivreg below60 (unemployment income_pc industrial_share = ///
    L.unemployment L.income_pc L.industrial_share) i.year, ///
    fe vce(cluster city_id)
estimates store iv_b_m2

xtivreg below60 (log_pop pct_65 pct_foreign unemployment income_pc industrial_share = ///
    L.log_pop L.pct_65 L.pct_foreign L.unemployment L.income_pc L.industrial_share) ///
    i.year, fe vce(cluster city_id)
estimates store iv_b_m3

esttab iv_b_m1 iv_b_m2 iv_b_m3 using ///
    "/Users/finn/Desktop/TFG/iv_below60_full.rtf", ///
    keep(log_pop pct_65 pct_foreign unemployment income_pc industrial_share) ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("GMM IV: Below 60% of Median (Full Sample)") ///
    mtitles("Demographics" "Economics" "All variables") ///
    stats(N, labels("Observations")) ///
    note("Panel IV-FE. Lagged values as instruments. Clustered SE. All years included.") ///
    nogaps compress replace

* ── GMM IV: Above 200% ───────────────────────────────────────
xtivreg above200 (log_pop pct_65 pct_foreign = ///
    L.log_pop L.pct_65 L.pct_foreign) i.year, ///
    fe vce(cluster city_id)
estimates store iv_a_m1

xtivreg above200 (unemployment income_pc industrial_share = ///
    L.unemployment L.income_pc L.industrial_share) i.year, ///
    fe vce(cluster city_id)
estimates store iv_a_m2

xtivreg above200 (log_pop pct_65 pct_foreign unemployment income_pc industrial_share = ///
    L.log_pop L.pct_65 L.pct_foreign L.unemployment L.income_pc L.industrial_share) ///
    i.year, fe vce(cluster city_id)
estimates store iv_a_m3

esttab iv_a_m1 iv_a_m2 iv_a_m3 using ///
    "/Users/finn/Desktop/TFG/iv_above200_full.rtf", ///
    keep(log_pop pct_65 pct_foreign unemployment income_pc industrial_share) ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("GMM IV: Above 200% of Median (Full Sample)") ///
    mtitles("Demographics" "Economics" "All variables") ///
    stats(N, labels("Observations")) ///
    note("Panel IV-FE. Lagged values as instruments. Clustered SE. All years included.") ///
    nogaps compress replace

di "DONE - 4 tables saved: fe_below60_full, fe_above200_full, iv_below60_full, iv_above200_full"
