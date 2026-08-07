import delimited "/Users/finn/Desktop/TFG/panel_v4.csv", clear

* Keep ALL years including 2020 and 2021
collapse (mean) gini unemployment income_pc industrial_share ///
    pct_foreign pct_65 log_pop, by(city_id year)
xtset city_id year

xtivreg gini (log_pop pct_65 pct_foreign unemployment income_pc industrial_share = ///
    L.log_pop L.pct_65 L.pct_foreign L.unemployment L.income_pc L.industrial_share) ///
    i.year, fe vce(cluster city_id) first
