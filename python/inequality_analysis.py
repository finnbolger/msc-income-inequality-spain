"""
Spain Municipal Income Inequality — Analysis Script
=====================================================
Thesis: Determinants of the Gini Index across Spanish cities
Data:   INE Urban Audit + Atlas de Distribución de Renta de los Hogares

Outputs (saved to output/ folder):
  1. output/data_clean.csv          — merged analytical dataset
  2. output/descriptive_stats.csv   — summary statistics table
  3. output/regression_results.txt  — OLS regression output
  4. output/fig_gini_distribution.png  — histogram of Gini across cities
  5. output/fig_gini_vs_income.png     — scatter: Gini vs median income
  6. output/fig_gini_vs_education.png  — scatter: Gini vs university share
  7. output/fig_gini_vs_unemployment.png — scatter: Gini vs unemployment
  8. output/fig_coefplot.png           — regression coefficient plot

Requirements:
    pip install pandas numpy matplotlib statsmodels scikit-learn openpyxl
"""

import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import warnings
warnings.filterwarnings("ignore")

try:
    import statsmodels.api as sm
    from statsmodels.stats.outliers_influence import variance_inflation_factor
    HAS_STATSMODELS = True
except ImportError:
    print("statsmodels not found — install with: pip install statsmodels")
    print("Running without regression output.\n")
    HAS_STATSMODELS = False

os.makedirs("output", exist_ok=True)

# ══════════════════════════════════════════════════════════════════════════════
# 1. LOAD AND MERGE DATA
# ══════════════════════════════════════════════════════════════════════════════

YEAR = 2022   # Change to 2021 or 2023 for robustness checks

def to_num(s):
    """Convert Spanish-formatted numbers (comma decimal) to float."""
    return pd.to_numeric(s.astype(str).str.replace(',', '.'), errors='coerce')

print(f"Loading data for year {YEAR}...")

# ── Gini (Atlas de Distribución de Renta) ─────────────────────────────────────
gini_raw = pd.read_csv('GINI_file.csv', sep='\t', encoding='utf-8-sig')
gini_df = gini_raw[
    gini_raw['Municipalities'].str.match(r'^\d{5} ', na=False) &
    gini_raw['Districts'].isna() &
    gini_raw['Sections'].isna() &
    (gini_raw['Average income indicators'] == 'Gini Index') &
    (gini_raw['Periodo'] == YEAR)
].copy()
gini_df['gini'] = to_num(gini_df['Total'])
gini_df['city'] = gini_df['Municipalities'].str[6:].str.strip()
gini_df['cod_ine'] = gini_df['Municipalities'].str[:5]
gini_df = gini_df[['city', 'cod_ine', 'gini']].dropna(subset=['gini'])
print(f"  Gini: {len(gini_df)} municipalities with valid data")

# ── Urban Audit files ──────────────────────────────────────────────────────────
def load_ua(fname, sex_filter=None):
    df = pd.read_csv(fname, sep='\t', encoding='utf-8-sig')
    df = df[(df['Periodo'] == YEAR) & df['Municipios'].notna()]
    if sex_filter and 'Sexo' in df.columns:
        df = df[df['Sexo'] == sex_filter]
    wide = df.pivot_table(
        index='Municipios', columns='Indicadores', values='Total', aggfunc='first'
    )
    wide.columns = [c.strip() for c in wide.columns]
    for c in wide.columns:
        wide[c] = to_num(wide[c])
    return wide

eco_w = load_ua('AspectosEconomicos.csv')
edu_w = load_ua('Formacion_Educacion.csv')
soc_w = load_ua('Aspectos_Sociales.csv')
dem_w = load_ua('DEMografic.csv', sex_filter='Total')

# ── Merge all ──────────────────────────────────────────────────────────────────
df = gini_df.copy()
for wide in [eco_w, edu_w, soc_w, dem_w]:
    df = df.merge(wide, left_on='city', right_index=True, how='inner')

print(f"  Merged dataset: {len(df)} cities × {len(df.columns)} columns")

# ══════════════════════════════════════════════════════════════════════════════
# 2. RENAME VARIABLES (short names for readability)
# ══════════════════════════════════════════════════════════════════════════════

rename = {
    'Tasa de desempleo (Porcentaje)':
        'unemployment_rate',
    'Renta neta media anual por habitante (Euros)':
        'income_per_capita',
    'Proporción de población entre 25-64 años con máximo nivel de educación ISCED 5, 6, 7 ó 8 (Porcentaje)':
        'pct_university',
    'Proporción de población entre 25-64 años con máximo nivel educación ISCED 0, 1 ó 2 (Porcentaje)':
        'pct_low_education',
    'Proporción de población entre 25-64 años con máximo nivel de educación ISCED 3 ó 4 (Porcentaje)':
        'pct_medium_education',
    'Proporción de extranjeros sobre la población total (Porcentaje)':
        'pct_foreign',
    'Proporción de población >=65 años (Porcentaje)':
        'pct_elderly',
    'Proporción de población de  0-14 años (Porcentaje)':
        'pct_youth',
    'Población residente (Personas)':
        'population',
    'Edad mediana de la población (años)':
        'median_age',
    'Proporción de empleo en servicios (NACE Rev.2 G-U) (Porcentaje)':
        'pct_services',
    'Proporción de empleo en industria (NACE Rev.2 B-E) (Porcentaje)':
        'pct_industry',
    'Tasa de actividad (Porcentaje)':
        'activity_rate',
    'Proporción de hogares de una persona sobre el total de hogares (Porcentaje)':
        'pct_single_households',
    'Alquiler mensual medio (Euros)':
        'mean_rent',
}

df = df.rename(columns=rename)
df['log_income'] = np.log(df['income_per_capita'])
df['log_population'] = np.log(df['population'])

# Save clean dataset
df.to_csv('output/data_clean.csv', index=False)
print("  Saved: output/data_clean.csv")

# ══════════════════════════════════════════════════════════════════════════════
# 3. DESCRIPTIVE STATISTICS
# ══════════════════════════════════════════════════════════════════════════════

key_vars = [
    'gini', 'income_per_capita', 'unemployment_rate', 'pct_university',
    'pct_low_education', 'pct_foreign', 'pct_elderly', 'population',
    'pct_services', 'pct_single_households', 'mean_rent'
]

labels = {
    'gini': 'Gini Index',
    'income_per_capita': 'Income per capita (€)',
    'unemployment_rate': 'Unemployment rate (%)',
    'pct_university': 'University educated, 25–64 (%)',
    'pct_low_education': 'Low education, 25–64 (%)',
    'pct_foreign': 'Foreign nationals (%)',
    'pct_elderly': 'Population ≥65 (%)',
    'population': 'Population',
    'pct_services': 'Employment in services (%)',
    'pct_single_households': 'Single-person households (%)',
    'mean_rent': 'Mean monthly rent (€)',
}

desc = df[key_vars].describe().T[['count','mean','std','min','max']]
desc.index = [labels.get(i, i) for i in desc.index]
desc = desc.round(2)
desc.to_csv('output/descriptive_stats.csv')
print("  Saved: output/descriptive_stats.csv")
print("\nDescriptive Statistics:")
print(desc.to_string())

# ══════════════════════════════════════════════════════════════════════════════
# 4. OLS REGRESSION
# ══════════════════════════════════════════════════════════════════════════════

# Regressor selection — based on Glaeser (2009) and Ayala et al. (2024)
# DV: Gini index
# IVs: income (log), education, labour market, demographics, housing

regressors = [
    'log_income',          # Income level (Glaeser: richer cities more unequal)
    'log_population',      # City size (agglomeration effect)
    'pct_university',      # High education share (skill heterogeneity)
    'pct_low_education',   # Low education share
    'unemployment_rate',   # Labour market slack
    'pct_foreign',         # Immigration (demographic mix)
    'pct_elderly',         # Age structure
    'pct_services',        # Service-sector dominance (polarisation)
    'pct_single_households', # Household structure
]

reg_labels = {
    'log_income': 'Log income per capita',
    'log_population': 'Log population',
    'pct_university': 'University educated (%)',
    'pct_low_education': 'Low education (%)',
    'unemployment_rate': 'Unemployment rate (%)',
    'pct_foreign': 'Foreign nationals (%)',
    'pct_elderly': 'Population ≥65 (%)',
    'pct_services': 'Employment in services (%)',
    'pct_single_households': 'Single-person households (%)',
}

reg_data = df[['city', 'gini'] + regressors].dropna()
print(f"\nRegression sample: {len(reg_data)} cities (after dropping missing)")

if HAS_STATSMODELS:
    y = reg_data['gini']
    X = sm.add_constant(reg_data[regressors])

    model = sm.OLS(y, X).fit(cov_type='HC3')  # Heteroskedasticity-robust SEs

    # Save results
    with open('output/regression_results.txt', 'w') as f:
        f.write("=" * 70 + "\n")
        f.write("OLS Regression: Determinants of the Gini Index\n")
        f.write(f"Spanish Cities (Urban Audit), Year: {YEAR}\n")
        f.write(f"N = {len(reg_data)} cities\n")
        f.write("Standard errors: HC3 (heteroskedasticity-robust)\n")
        f.write("=" * 70 + "\n\n")
        f.write(model.summary().as_text())
        f.write("\n\nNote: *p<0.10, **p<0.05, ***p<0.01\n")
        f.write("\nVariable definitions:\n")
        for k, v in reg_labels.items():
            f.write(f"  {k:30s} = {v}\n")

    print("  Saved: output/regression_results.txt")
    print(f"\n  R² = {model.rsquared:.3f}  |  Adj. R² = {model.rsquared_adj:.3f}")
    print(f"  F-stat p-value = {model.f_pvalue:.4f}")
    print("\n  Key coefficients:")
    for var in regressors:
        coef = model.params[var]
        pval = model.pvalues[var]
        stars = '***' if pval < 0.01 else '**' if pval < 0.05 else '*' if pval < 0.10 else ''
        print(f"    {reg_labels[var]:35s}  β={coef:7.3f}  p={pval:.3f} {stars}")

    # VIF check
    print("\n  Variance Inflation Factors (VIF):")
    X_vif = reg_data[regressors].dropna()
    for i, var in enumerate(regressors):
        vif = variance_inflation_factor(X_vif.values, i)
        flag = " ⚠ HIGH" if vif > 10 else ""
        print(f"    {reg_labels[var]:35s}  VIF={vif:.2f}{flag}")

else:
    # Fallback: manual OLS via numpy
    reg_data2 = reg_data.dropna()
    y = reg_data2['gini'].values
    X_raw = reg_data2[regressors].values
    X = np.column_stack([np.ones(len(X_raw)), X_raw])
    beta = np.linalg.lstsq(X, y, rcond=None)[0]
    y_hat = X @ beta
    ss_res = np.sum((y - y_hat)**2)
    ss_tot = np.sum((y - y.mean())**2)
    r2 = 1 - ss_res / ss_tot
    print(f"  OLS (numpy fallback) R² = {r2:.3f}")
    print("  Install statsmodels for full output: pip install statsmodels")
    model = None

# ══════════════════════════════════════════════════════════════════════════════
# 5. FIGURES
# ══════════════════════════════════════════════════════════════════════════════

STYLE = {
    'axes.spines.top': False,
    'axes.spines.right': False,
    'axes.grid': True,
    'grid.alpha': 0.3,
    'font.family': 'sans-serif',
}
plt.rcParams.update(STYLE)
COLOR = '#c0392b'   # INE-red
GRAY  = '#7f8c8d'

# ── Figure 1: Gini distribution ───────────────────────────────────────────────
fig, ax = plt.subplots(figsize=(9, 5))
ax.hist(df['gini'].dropna(), bins=20, color=COLOR, edgecolor='white', alpha=0.85)
ax.axvline(df['gini'].mean(), color='black', lw=1.5, ls='--',
           label=f"Mean = {df['gini'].mean():.1f}")
ax.axvline(df['gini'].median(), color=GRAY, lw=1.5, ls=':',
           label=f"Median = {df['gini'].median():.1f}")
ax.set_xlabel("Gini Index", fontsize=12)
ax.set_ylabel("Number of cities", fontsize=12)
ax.set_title(f"Distribution of Gini Index across Spanish Cities ({YEAR})", fontsize=13)
ax.legend(fontsize=11)
fig.text(0.99, 0.01, f'Source: INE Atlas de Distribución de Renta de los Hogares',
         ha='right', fontsize=8, color=GRAY)
plt.tight_layout()
plt.savefig('output/fig_gini_distribution.png', dpi=150, bbox_inches='tight')
plt.close()
print("  Saved: output/fig_gini_distribution.png")

# ── Figure 2–4: Scatter plots ─────────────────────────────────────────────────
scatters = [
    ('income_per_capita', 'Income per capita (€)',
     'fig_gini_vs_income.png', False),
    ('pct_university', 'Population with university education (%)',
     'fig_gini_vs_education.png', False),
    ('unemployment_rate', 'Unemployment rate (%)',
     'fig_gini_vs_unemployment.png', False),
]

for xvar, xlabel, fname, logx in scatters:
    plot_df = df[['city', 'gini', xvar]].dropna()
    fig, ax = plt.subplots(figsize=(9, 6))
    ax.scatter(plot_df[xvar], plot_df['gini'],
               color=COLOR, alpha=0.65, s=45, edgecolors='white', linewidth=0.4)

    # Add city labels for top/bottom outliers
    top5 = plot_df.nlargest(5, 'gini')
    bot5 = plot_df.nsmallest(5, 'gini')
    for _, row in pd.concat([top5, bot5]).iterrows():
        ax.annotate(row['city'], (row[xvar], row['gini']),
                    fontsize=7, color='#2c3e50',
                    xytext=(4, 2), textcoords='offset points')

    # OLS trend line
    x_vals = plot_df[xvar].values
    y_vals = plot_df['gini'].values
    m, b = np.polyfit(x_vals, y_vals, 1)
    x_line = np.linspace(x_vals.min(), x_vals.max(), 100)
    ax.plot(x_line, m * x_line + b, color='black', lw=1.5, ls='--', alpha=0.6)

    # Correlation
    corr = plot_df[['gini', xvar]].corr().iloc[0, 1]
    ax.text(0.97, 0.05, f'r = {corr:.2f}', transform=ax.transAxes,
            ha='right', fontsize=11, color='black',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='white', alpha=0.7))

    ax.set_xlabel(xlabel, fontsize=12)
    ax.set_ylabel("Gini Index", fontsize=12)
    ax.set_title(f"Gini Index vs {xlabel}\nSpanish Cities ({YEAR})", fontsize=13)
    fig.text(0.99, 0.01, 'Source: INE Urban Audit & Atlas de Distribución de Renta',
             ha='right', fontsize=8, color=GRAY)
    plt.tight_layout()
    plt.savefig(f'output/{fname}', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Saved: output/{fname}")

# ── Figure 5: Coefficient plot ────────────────────────────────────────────────
if HAS_STATSMODELS and model is not None:
    coefs = model.params[regressors]
    cis   = model.conf_int().loc[regressors]
    pvals = model.pvalues[regressors]

    # Sort by coefficient magnitude
    order = coefs.abs().sort_values(ascending=True).index
    coefs = coefs[order]
    cis   = cis.loc[order]
    pvals = pvals[order]
    ylabels = [reg_labels.get(i, i) for i in order]

    colors = [COLOR if p < 0.05 else GRAY for p in pvals]
    err_lo = coefs.values - cis[0].values
    err_hi = cis[1].values - coefs.values

    fig, ax = plt.subplots(figsize=(9, 6))
    y_pos = range(len(coefs))
    ax.barh(y_pos, coefs.values, xerr=[err_lo, err_hi],
            color=colors, alpha=0.8, capsize=4, ecolor='#555',
            error_kw={'linewidth': 1.2})
    ax.axvline(0, color='black', lw=1)
    ax.set_yticks(y_pos)
    ax.set_yticklabels(ylabels, fontsize=10)
    ax.set_xlabel("Coefficient (95% CI)", fontsize=12)
    ax.set_title(f"OLS Regression Coefficients — Determinants of Gini Index\n"
                 f"Spanish Cities ({YEAR}), N={len(reg_data)}  |  R²={model.rsquared:.2f}",
                 fontsize=12)

    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor=COLOR, alpha=0.8, label='Significant (p<0.05)'),
        Patch(facecolor=GRAY, alpha=0.8, label='Not significant'),
    ]
    ax.legend(handles=legend_elements, loc='lower right', fontsize=10)
    fig.text(0.99, 0.01, 'Source: INE Urban Audit & Atlas de Distribución de Renta',
             ha='right', fontsize=8, color=GRAY)
    plt.tight_layout()
    plt.savefig('output/fig_coefplot.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: output/fig_coefplot.png")

print("\n✓ All done. Check the output/ folder.")
print("\nFiles produced:")
for f in sorted(os.listdir('output')):
    size = os.path.getsize(f'output/{f}')
    print(f"  output/{f}  ({size/1024:.0f} KB)")
