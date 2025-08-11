# Electricity Consumption Forecast (15‑min, Jan–Feb 2010)

Time‑series forecasting of electricity consumption (kW) using classic methods (ES/ETS, SARIMA),
machine learning (XGBoost, Random Forest, SVM, linear baselines), and deep learning (Torch LSTM/GRU/CNN).
Forecast target: **2010‑02‑21** (96 steps @ 15‑min). Temperature (°C) is available for the forecast day.

## TL;DR (current leaderboard on validation: last 2 days)
| Model                                   | Covariates | RMSE   | MAE   | Notes |
|-----------------------------------------|------------|--------|-------|------|
| **XGBoost (y‑lags + temp‑lags)**        | kW + temp  | **10.26** | **8.76** | Overall best (with temp) |
| SARIMA (1,1,1)(0,1,1)[96] + Box‑Cox     | kW only    | 12.07 | 9.78  | Best no‑temp classical   |
| ARIMAX (temp lags 0,1,96)               | kW + temp  | 12.87 | 10.80 | With temp (dynamic reg.) |
| LSTM (torch)                            | kW + temp  | 31.27 | 19.74 | Needs richer features    |
| GRU  (torch)                            | kW + temp  | 30.27 | 20.98 | Needs richer features    |
| CNN1D (torch)                           | kW + temp  | 62.39 | 48.77 | Needs richer features    |

*Interpretation:* With known temperature for 2010‑02‑21, **XGBoost with lagged features** is the most accurate so far.
Deep models (as implemented) are not yet competitive; they likely need longer context and calendar/Fourier features.

## Data
- Training file: **2010‑01‑01 01:15** → **2010‑02‑20 23:45** (every 15 min).
- Forecast covariate: **temperature for 2010‑02‑21** (96 rows).
- Place the Excel file in `data/` and update the `data_path` at the top of the Rmd, e.g.:
  ```r
  data_path <- "2023-11-Elec-train.xlsx"  # or your actual file name
  ```

## Repro steps
1. **Install R packages** (first time only):
   ```r
   source("install_packages.R")
   ```

2. **(Torch only)** If prompted: `torch::install_torch()` once in the R console.

3. **Open and Knit** `Electricity_Consumption_Forecast.Rmd` to HTML.  
   The Rmd performs:
   - ingest & cleaning (snap to 15‑min grid, Excel serial timestamp fix)
   - outlier outage repair (Feb 18 zeros)
   - ES/ETS, SARIMA, and ML (XGBoost/RF/SVM/LM/MLM) with a 2‑day validation split
   - with‑temperature models (ARIMAX; ML with covariates)
   - Torch deep models (LSTM/GRU/CNN) for 96‑step day‑ahead using known temp path
   - final comparisons and exports

4. **Outputs**
   - `forecast_2010-02-21_best.csv` — best no‑temp forecast (96 rows)
   - `Forecasts_A_noTemp_vs_withTemp.xlsx` — two columns (no‑temp vs with‑temp)
   - `outputs/metrics_*.csv`, `outputs/forecast_with_temp_*_2010-02-21.csv` — Torch model metrics & forecasts

## Key implementation notes
- Frequency: **96** (15‑min). Weekly seasonality at **672** is strong.
- Cleaning: mixed timestamps (Excel serial + strings) unified to POSIXct; deduped; snapped to grid.
- Outage repair: Feb‑18 block of 11 zeros replaced with median of same slot over previous 7 days (no leakage).
- Validation: last **2 days** (**192** points). Winner picked by **MASE/RMSE**.
- With temp: dynamic regression (ARIMAX) and ML use temperature lags **0,1,96** as features.

## How to create the GitHub repo
- **Using the website**
  1. Create a new repo on GitHub, e.g. `electricity-forecast-2010`.
  2. Download this folder (or the zip) and put your Rmd + data file as described.
  3. In a terminal (from this folder):
     ```bash
     git init
     git add .
     git commit -m "Initial commit: electricity forecast project"
     git branch -M main
     git remote add origin https://github.com/Sourena-Mohit/Electricity-Consumption-Forecast.git
     git push -u origin main
     ```


## Improving the deep models (if you want to iterate)
- Add **calendar/Fourier features** for daily (m=96) and weekly (m=672) cycles into the sequence.
- Increase **lookback** (≥ 672) or combine shorter lookback with Fourier/categorical time‑of‑week features.
- Train longer with LR scheduler; try direct **multi‑horizon (96‑output)** heads to reduce error compounding.

## License
MIT

