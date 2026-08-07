# Determinants of Income Inequality Across Spanish Cities

MSc Economics thesis project, University of Valencia. Panel-data analysis of what drives income inequality across Spanish municipalities combining a Python data pipeline with Stata econometrics (fixed effects, instrumental variables, and dynamic panel GMM).

## Motivation

Income inequality varies sharply between Spanish cities, but it's not obvious how much of that variation is explained by city size, demographics (age structure, foreign-born share), or economic structure (unemployment, income levels, industrial employment share). This project builds a city-year panel to test these relationships and to check whether the findings hold up once reverse causality and omitted-variable bias are addressed.

## Data

- **Atlas de Distribución de Renta de los Hogares** (INE) — municipal Gini index, P80/P20 ratio, share of population below 60% of median income, share above 200% of median income
- **Urban Audit** (INE) — municipal demographics (population, age structure, % foreign nationals), labour market (unemployment rate), income (net income per capita), and economic structure (industrial employment share)
- Panel of Spanish cities, multiple years (2020–2023 range depending on specification)
- Note: raw INE source files are not included in this repo (large, publicly re-downloadable). `python/inequality_analysis.py` documents exactly which INE tables are required and how they're merged.

## Method

**Python** (`python/inequality_analysis.py`): loads and merges the raw INE tables, renames variables, computes descriptives, and runs a baseline heteroskedasticity-robust OLS with a VIF multicollinearity check — the exploratory stage before moving to Stata for the full panel econometrics.

**Stata** (`stata/`), in increasing order of rigor:
1. **Cross-sectional OLS** (`crosssection_constants_v5.do`) — single-year (2022) regressions of each inequality measure on demographic and economic controls.
2. **Panel fixed effects** (`fe_gini_p80p20_full.do`, `fe_gmm_below_above_full.do`) — city and year fixed effects, clustered standard errors, to control for time-invariant city characteristics.
3. **Panel IV/2SLS** (`gmm_iv_full.do`, `gmm_iv_firststage.do`) — predictors instrumented with their own lagged values to address reverse causality (e.g., inequality could itself affect local unemployment or income).
4. **Dynamic panel GMM** (`ARandHansenFull.do`, Arellano-Bond via `xtabond2`) — includes a lagged dependent variable to capture persistence in inequality, with AR(1)/AR(2) and Hansen J diagnostics to test instrument validity.
5. **Diagnostics** (`vif_check.do`, `F-tests_full.do`, `Fstats_v5.do`) — multicollinearity (VIF) and weak-instrument (first-stage F-stat) checks that justify the modelling choices above.

**Outcome variables:** Gini index, P80/P20 ratio, share below 60% of median income, share above 200% of median income.
**Predictors:** log population, % population 65+, % foreign nationals, unemployment rate, income per capita, industrial employment share — plus city and year fixed effects.

**Notebooks** (`notebooks/`): `giniandp80p20.ipynb` extracts and cleans the Gini/P80-P20 series from the raw INE files; `Map_of_Spain.ipynb` builds a choropleth map of municipal-level inequality from INE boundary shapefiles.

## Tools

Python (pandas, numpy, statsmodels, matplotlib), Stata (`xtreg`, `xtivreg`, `xtabond2`, `esttab`)

## Repo structure

```
python/
  inequality_analysis.py     data merge, descriptives, baseline OLS + VIF, figures
notebooks/
  giniandp80p20.ipynb        extracts Gini / P80-P20 series from raw INE files
  Map_of_Spain.ipynb         choropleth map of inequality across Spanish municipalities
stata/
  crosssection_constants_v5.do   single-year (2022) OLS, all four outcome measures
  all_regressions_v5.do          full pipeline: cross-section, panel FE, panel IV, descriptives
  fe_gini_p80p20_full.do         panel FE, full sample, Gini and P80/P20
  fe_gmm_below_above_full.do     panel FE + IV, full sample, below-60% and above-200% shares
  gmm_iv_full.do                 panel IV/2SLS with lagged instruments, full sample
  gmm_iv_firststage.do           first-stage regression for the IV specification
  ARandHansenFull.do             dynamic panel GMM (Arellano-Bond), full sample
  AB-GMM diagnostics.do          dynamic panel GMM, restricted sample (excl. 2020-21)
  F-tests_full.do                weak-instrument F-test, full sample
  Fstats_v5.do                   weak-instrument F-test, alternate panel version
  vif_check.do                   multicollinearity check
README.md
```

## How to reproduce

1. Download the relevant INE Urban Audit and Atlas de Distribución de Renta tables (URLs and required filenames are listed at the top of `python/inequality_analysis.py`).
2. Run `python/inequality_analysis.py` to build the merged cross-sectional dataset and baseline OLS results.
3. Build the city-year panel (`panel_v2.csv` / `panel_v4.csv` / `panel_v5.csv` — versioned as the panel was extended across iterations) and update the file paths at the top of each `.do` file.
4. Run the Stata scripts in `stata/` — `all_regressions_v5.do` is the most complete single script (cross-section → FE → IV, plus descriptives).

## What I'd explore next

Extending the panel with more recent INE releases as they're published, and testing whether the inequality-persistence coefficient from the Arellano-Bond specification is stable across alternative instrument lag structures.
