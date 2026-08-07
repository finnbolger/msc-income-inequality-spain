import delimited "/Users/finn/Desktop/TFG/panel_v2.csv", clear
drop if year == 2020 | year == 2021
collapse (mean) gini unemployment income_pc industrial_share ///
    pct_foreign pct_65 log_pop, by(city_id year)
xtset city_id year

xtabond2 gini L.gini log_pop pct_65 pct_foreign ///
    unemployment income_pc industrial_share i.year, ///
    gmm(L.gini, lag(2 4)) ///
    iv(log_pop pct_65 pct_foreign ///
       unemployment income_pc industrial_share i.year) ///
    robust twostep small
