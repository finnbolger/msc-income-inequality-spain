clear all
set more off

import delimited "/Users/finn/Desktop/TFG/panel_v4.csv", clear
keep if year == 2022
collapse (mean) above200 unemployment income_pc industrial_share ///
    pct_foreign pct_65 log_pop, by(city_id)

reg above200 log_pop pct_65 pct_foreign unemployment income_pc industrial_share
vif
