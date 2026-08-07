import delimited "/Users/finn/Desktop/TFG/panel_v5.csv", clear
xtset city_id year

xtivreg gini (log_pop pct_65 pct_foreign unemployment ///
    income_pc industrial_share = L.log_pop L.pct_65 ///
    L.pct_foreign L.unemployment L.income_pc ///
    L.industrial_share) i.year, fe vce(cluster city_id) first
