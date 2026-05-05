# FGaR — Replication Package

This repository contains the replication files for the paper "Which Factors Drive Downside Risk in the U.S. Economy?" by Christian Brownlees, Carlo Pavanello, and André B.M. Souza which is [available on SSRN](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=6548438).
This repository replicates the tables from 3 to 9 in the paper. Scripts are written in MATLAB and organised into numbered folders that define the execution order. All generated tables are written to `paper/tables/`.

---

## Authors 
 [Christian Brownlees](http://www.econ.upf.edu/~cbrownlees/), [Carlo Pavanello](www.linkedin.com/in/carlo-pavanello-6938a31b0), and [Andre B.M. Souza](http://www.andrebmsouza.com)

---

## Software Requirements
[MATLAB](https://www.mathworks.com/) The code has been tested with the MATLAB releases R2025a and R2025b

---

## Repository Structure

```
FGaR-replication/
├── code/
│   ├── 00_utils/        Helper functions shared across all scripts
│   ├── 01_setup/        Data preparation (FRED-MD, factors, targets)
│   ├── 02_BM/           Benchmark quantile models (HIST, QAR, AR(1)-GARCH(1,1))
│   ├── 02_QR/           Quantile regression models
│   ├── 02_LS/           Location-scale regression models
│   └── 03_analysis/     Evaluation and table generation
│       ├── 00_IS/       In-sample statistics and Table 3–4
│       ├── 00_MCS/      Model confidence set and Table 5
│       ├── 01_OOS_MAIN/ OOS statistics and Tables 6–7
│       ├── 02_OOS_CAT/  FRED-MD category summary and Table 8
│       └── 02_OOS_PR/   Policy-relevant variable summary and Table 9
├── data/
│   ├── inputs/          Raw input data (FRED-MD, external factors)
│   └── outputs/         Intermediate .mat files produced by the scripts
└── paper/
    ├── figures/         Generated .pdf figure files (Figures 1–2)
    └── tables/          Generated .tex table files (Tables 3–9)
```

---

## Execution Order

Each subfolder within `code/` is numbered to indicate the order in which it must be run. Scripts within a folder follow the same numbering logic. Scripts that share a number, or carry no number, may be run in any order within that folder step. On a standard personal laptop these are the execution times.

| Step | Folder | Scripts | Output | Time |
|---|---|---|---|---|
| 1 | `code/01_setup/` | `O0_Prepare_FREDMD.m` | `data/outputs/fred_md.mat` | |
| 2 | `code/01_setup/` | `O1_Prepare_Factors.m`, `O1_Prepare_Targets.m` | `observable_factors.mat`, `prediction_targets.mat` | |
| 3 | `code/01_setup/` | `O2_Prepare_Statistical_Factors.m` | `statistical_factors.mat` | ~10min |
| 4 | `code/01_setup/` | `O3_Prepare_Factor_Combinations.m` | `factors_singletons.mat`, `factors_pairs.mat`, `factors_triplets.mat`, `factors_is.mat` | |
| 5 | `code/02_BM/` | `BM_IS.m`, `BM_OOS.m` | `quantiles/BM_IS.mat`, `quantiles/BM_OOS.mat` | ~30min |
| 6 | `code/02_QR/` | `QR_IS.m` | `quantiles/QR_IS.mat`, `QR_IS_TL.mat`, `QR_IS_significance.mat`, `QR_IS_b_fac.mat`, `QR_IS_b_ar1.mat` | ~2h10min |
| 7 | `code/02_QR/` | `QR_OOS.m` | `quantiles/QR_OOS_{singletons,pairs,triplets}.mat` | ~3h25min |
| 8 | `code/02_LS/` | `LS_IS.m` | `quantiles/L_IS.mat`, `quantiles/S_IS.mat`, `quantiles/LS_IS.mat`| ~3min |
| 9 | `code/02_LS/` | `LS_OOS.m` | `quantiles/LS_OOS_{singletons,pairs,triplets}.mat` | 1h30min+4h45min+13h5min |
| 10 | `code/03_analysis/00_IS/` | `O0_Evaluate_IS_1_fac.m` | `stats_is_1_fac.mat` | |
| 11 | `code/03_analysis/00_IS/` | `O1_CreateISTable_factors_screening.m`, `O1_CreateISTable_models_screening.m` | Tables 3–4 | |
| 12 | `code/03_analysis/00_MCS/` | `O0_Evaluate_Forecast_OOS_MCS.m`, `O1_MCS.m`, `O2_Evalute_MCS.m`, `O3_CreateMCSTable.m` | Table 5 | ~20min |
| 13 | `code/03_analysis/01_OOS_MAIN/` | `O0_Evaluate_Forecast_OOS_1_fac.m`, `O0_Evaluate_Forecast_OOS_mix_fac.m` | `stats_1_fac.mat`, `stats_mix.mat` | |
| 14 | `code/03_analysis/01_OOS_MAIN/` | `O1_CreateOOSTable_1_fac.m`, `O1_CreateOOSTable_multi_fac.m` | Tables 6–7 | |
| 15 | `code/03_analysis/02_OOS_CAT/` | `CreateOOSTable_CAT_summary.m` | Table 8 | |
| 16 | `code/03_analysis/02_OOS_PR/` | `CreateOOSTable_PR_summary.m` | Table 9 | |

Steps 7 and 9 each loop over singletons, pairs, and triplets in a single run; no manual repetition is needed.

---

## Input Data

Raw input files are in `data/inputs/`. The inputs are static files checked into the repository:

[FRED-MD](https://www.stlouisfed.org/research/economists/mccracken/fred-databases) from St. Louis Fed FRED Database

[National Financial Condition Index (NFCI)](https://www.chicagofed.org/nfci) from Chicago Fed
[Excess Bond Premium (EBP)](https://www.federalreserve.gov/econres/notes/feds-notes/updating-the-recession-risk-and-the-excess-bond-premium-20161006.html) from corresponding Fed note
[Financial Uncertainty (FUNC)](https://www.sydneyludvigson.com/macro-and-financial-uncertainty-indexes) from Sydney Ludvigson website
[CBOE Volatility Index (VIX)](https://www.stlouisfed.org/research/economists/mccracken/fred-databases) from St. Louis Fed FRED Database  
[Composite Indicator of Systemic Stress (CISS)](https://data.ecb.europa.eu/data/datasets/CISS/CISS.D.US.Z0Z.4F.EC.SS_CIN.IDX) from ECB datasets

[Macroeconomic Uncertainty (MUNC)](https://www.sydneyludvigson.com/macro-and-financial-uncertainty-indexes) from Sydney Ludvigson website  
U.S. National Home Price Index (HPI) [quarterly](https://fred.stlouisfed.org/series/USSTHPI) [monthly](https://fred.stlouisfed.org/series/CSUSHPINSA) from St. Louis Fed FRED Database
[Credit-to-GDP Gap (CTG)](https://data.bis.org/topics/CREDIT_GAPS/data?selected_ts=BIS%2CWS_CREDIT_GAP%2C1.0%255EQ.US.P.A.A%2BB&filter=FREQ%3DQ%255ETC_LENDERS%3DA%255ETIMESPAN%3D1949-01-01_2023-09-30%255EBORROWERS_CTY_TXT%3DUnited%2520States%255ETC_BORROWERS%3DP%255ECG_DTYPE%3DA%257CC%257CB) from BIS Database

[World Uncertainty Index for the US (WUI)](https://worlduncertaintyindex.com/data/) from worlduncertaintyindex.com
[Geopolitical Risk Index (GPR)](https://www.matteoiacoviello.com/gpr.htm) from Matteo Iacoviello website
[Economic Policy Uncertainty Index (EPU)](https://www.policyuncertainty.com/us_monthly.html) from policyuncertainty.com
[Firm-Level Risk (RISK)](https://www.firmlevelrisk.com/download) from firmlevelrisk.com
[Firm-Level Political Risk (PRISK)](https://www.firmlevelrisk.com/download) from firmlevelrisk.com
[Firm-Level Non Political Risk (NPRISK)](https://www.firmlevelrisk.com/download) from firmlevelrisk.com

---

## Additional Resources

### ["Vulnerable Growth" Replication Files (Adrian et al, 2019)](https://www.aeaweb.org/articles?id=10.1257/aer.20161923)

 - rq.m: Function to compute quantile regression.

### ["Quantile Factor Models" Replication Files (Chen et al., 2021)](https://onlinelibrary.wiley.com/doi/full/10.3982/ECTA15746?casa_token=Z-1MR5L7BD4AAAAA%3A2gcUaRK_8KL2pebggjS3U8fJ1mu8t9pOzIfbiQfCdkyRAmkUVD4fh2-NRhDYElz63bSBK7dpAF7QfCtw)

 - IQR.m: Function to estimate the quantile factors and factor loadings using the IQR algorithm.
 - rq_fnm.m: Function to compute quantile regression (identical to rq.m).

 ### [Backtesting Global Growth-at-Risk Replication Files (Brownlees and Souza, 2021)](https://github.com/ctbrownlees/gar-replication/tree/master)

 - dq_hits.m: Function to obtain the p-value of a "direct" DQ test based on 4 lags of the hits series.
 - dq_unc.m: Function to returns the p-value of a "direct" DQ test based on a constant.

### [FRED-Databases Matlab Code (McCracken and Ng, 2016)](https://www.stlouisfed.org/research/economists/mccracken/fred-databases)

 - prepare_missing.m: Function to transform the raw data into stationary form. 
 - remove_outliers.m: Function to remove outliers from the data. A data point x is considered an outlier if |x-median|>10*interquartile_range.

### [MFE Toolbox](https://github.com/bashtage/mfe-toolbox)

 - covnw.m: Function to estimate HAC covariance matrices.
 - olsnw.m: Function to perform inference on ols parameters with HAC.
 - normloglik.m: Log Likelihood for the standard normal.
 - block_bootstrap.m: Function to implement a circular block bootstrap for bootstrapping stationary, dependent series.

 The following files are modified versions of those in the MFE Toolbox.

 - covnw_dq.m: Function to estimate HAC covariance matrices for binary hit variables.
 - olsnw_dq.m: Function to perform robust inference on binary hit variables.

### [MCS](https://github.com/rubetron/MCS)

 - estMCS.m: Function to estimate the Model Confidence Set procedure of Hansen,Lunde and Nason (2011).
 - make_blocks.m: Function to create a matrix of circularly shifted index blocks of length n across l rows.
 - make_index.m: Function to generate B bootstrap index samples of length n by drawing random starting points from a block index matrix.
 - make_stats.m: Function to compute the sample mean and bootstrap means using the resampling indices in "boot_index.m".
 - t_range.m: Function to compute the range test statistic, bootstrap p-value, and candidate model with the largest standardized pairwise mean difference.

---

## Abbreviations

| Abbreviation | Meaning |
|---|---|
| **BM** | Benchmarks (HIST, AR-QR, AR-GARCH) |
| **QR** | Quantile regression |
| **LS / LSR** | Location-scale regression |
| **IS** | In-sample |
| **OOS** | Out-of-sample |
| **MCS** | Model confidence set |
| **CAT** | FRED-MD categories |
| **PR** | Policy-relevant variables |
| **TLG** | Tick-loss gain (relative to HIST benchmark) |
| **DQU / DQC** | Dynamic quantile test, unconditional / conditional |