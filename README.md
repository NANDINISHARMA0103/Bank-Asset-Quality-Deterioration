# Bank Asset Quality Deterioration — Graph Documentation

This README catalogues every graph produced in this analysis: what it shows,
how it was built, and what it reveals about asset-quality deterioration
across 47 Indian public- and private-sector commercial banks (2005–2025).

---

## Basic Graphs

### 1. Histogram — Distribution of GNPA Ratio
**File:** `Rplot.png`
**Code:** `hist(df$gnpa_ratio, main = "Distribution of GNPA Ratio", ...)`

![Distribution of GNPA Ratio](Output/Rplot.png)

Shows the frequency distribution of GNPA ratio across all bank-year
observations.

**Key finding:** Right-skewed distribution — most observations fall in the
0–5% GNPA band, with a long thin tail extending toward 30–40%, indicating a
small number of severely stressed banks pull the average upward.

---

### 2. Boxplot — Credit Growth by Bank Category
**File:** `Rplot01.png`
**Code:** `boxplot(df$credit_growth ~ df$category, ...)`

![Credit Growth by Bank Category](Output/Rplot01.png)

Compares the spread of credit growth between Public and Private sector banks.

**Key finding:** Similar medians across both categories, but Private banks
show more extreme high-end outliers (beyond 100%) than Public banks (capped
around ~90%).

---

### 3. Barplot — Average ROA by Bank Category
**File:** `Rplot02.png`
**Code:** `barplot(avg_roa$return_on_assets, names.arg = avg_roa$category, ...)`

![Average ROA by Bank Category](Output/Rplot02.png)

Compares average Return on Assets between the two ownership categories.

**Key finding:** Private sector banks show visibly higher average ROA than
Public sector banks, plausibly linked to Public banks' higher NPA burden.

---

## Advanced Graphs

### 4. Correlation Plot — Bank Health & Macro Variables
**File:** `correlation_plot.png`
**Code:** `ggcorrplot(r, type = "lower", lab = TRUE, ...)`

![Correlation: Bank Health & Macro Variables](Output/correlation_plot.png)

A lower-triangle heatmap showing pairwise correlations between GNPA Ratio,
Credit Growth, ROA, CAR, Net Interest Income, Repo Rate, and Real GDP Growth.

**Key finding:** GNPA Ratio is strongly negatively correlated with ROA
(r = -0.78) and moderately negatively correlated with Credit Growth
(r = -0.56). Correlations with macro variables are weak, suggesting
deterioration is driven more by bank-level factors than the broader economy.

---

### 5. Faceted Density Plot — Credit Growth by GNPA Risk Tier
**File:** `Rplot03.png`
**Code:** `geom_density(alpha = 0.9, color = NA) + facet_wrap(~ gnpa_tier, scales = "free_y")`

![Credit Growth Distribution by GNPA Risk Tier](Output/Rplot03.png)

Four density curves (Low / Moderate / High / Severe GNPA risk) showing how
credit growth is distributed within each risk tier.

**Key finding:** Low and Moderate tiers show narrow, high peaks; the Severe
tier is much wider and flatter, indicating more erratic, unpredictable
credit growth among the most NPA-stressed banks.

---

### 6. Animated Line Chart — GNPA Trend by Category (2005–2025)
**File:** `gnpa_trend_by_category.gif`
**Code:** `geom_line() + geom_point() + transition_reveal(year) + shadow_mark(...)`

![GNPA Trend by Category](Output/gnpa_trend_by_category.gif)

An animated trend line showing average GNPA ratio for Public vs Private
sector banks, drawn progressively year by year with a fading trail.

**Key finding:** Both categories start near 6% GNPA in 2005, converge low
through 2008–2013, then diverge sharply — Public banks peak at ~18.5% (2018),
Private banks peak at ~8.5% (2020). Both recover to ~2.5–3% by 2025.

---

### 7. Animated Faceted Scatter — Credit Growth vs GNPA by Category
**File:** `animated_facet_scatter_bordered.gif`
**Code:** `geom_point() + facet_wrap(~ category) + transition_time(year)`

![Credit Growth vs GNPA Ratio by Category](Output/animated_facet_scatter_bordered.gif)

Two side-by-side animated panels (Public / Private) plotting Credit Growth
against GNPA Ratio, evolving year by year.

**Key finding:** During the mid-2010s stress period, Public banks show a
cluster of low credit growth paired with high GNPA (retreating from
lending), while Private banks maintain more normal credit growth even as
individual banks' GNPA rises.

---

## Statistical Diagnostic Plots

### 8. Normal Q-Q Plot — delta_gnpa_ratio
**File:** `Rplot04.png`
**Code:** `qqnorm(df$delta_gnpa_ratio); qqline(...)`

![Normal Q-Q Plot](Output/Rplot04.png)

Tests whether year-on-year GNPA change follows a normal distribution.

**Key finding:** Points deviate from the reference line at both tails
(heavier tails than normal) — confirmed by Shapiro-Wilk (W = 0.775,
p < 2.2e-16) — justifying the use of non-parametric tests throughout the
rest of the analysis.

---

## Predictive Model Plots

### 9. Decision Tree — Predicting GNPA Deterioration
**File:** *not yet exported*
**Code:** `rpart.plot(tree_model, main = "Decision Tree — Predicting GNPA Deterioration", extra = 104, box.palette = "GnBu")`

This plot only renders in the RStudio Plots pane — it was never saved to a
file. To fix: after running the `rpart.plot(...)` line, click **Export →
Save as Image** in the Plots pane, save as `Rplot07.png`, then add it here.

A classification tree predicting whether a bank will experience GNPA
deterioration, using Capital Adequacy Ratio, Credit Growth, Repo Rate, Real
GDP Growth, and ROA.

**Key finding:** The first and most important split is **Capital Adequacy
Ratio ≥ 13** — banks above this threshold have only a 19% deterioration
rate (58% of the sample), while banks below it fork further on Credit
Growth and Repo Rate, reaching deterioration rates as high as 89% in the
highest-risk leaf. Overall test accuracy: 79.6%, sensitivity 42.1%,
specificity 95.5%.

---

### 10. ROC Curve — Logistic Regression
**File:** `Rplot05.png`
**Code:** `roc_log <- roc(test_data$deterioration_flag, log_probs); plot(roc_log, main = "ROC Curve — Logistic Regression", col = "maroon")`

![ROC Curve — Logistic Regression](Output/Rplot05.png)

Plots the trade-off between sensitivity and specificity for the logistic
regression model across all classification thresholds.

**Key finding:** The curve bows well above the diagonal reference line,
confirming genuine predictive power (AUC = 0.765) — the model performs
substantially better than random guessing at distinguishing deteriorating
from non-deteriorating banks.

---

### 11. ROC Curve Comparison — Logistic Regression vs Random Forest
**File:** `Rplot06.png`
**Code:** `plot(roc_log, col = "#457B9D", main = "ROC Curve Comparison — Logistic vs Random Forest"); lines(roc_rf, col = "#9E2A2B")`

![ROC Curve Comparison](Output/Rplot06.png)

Overlays both models' ROC curves on one chart for direct visual comparison.

**Key finding:** The Random Forest curve (red) sits consistently above the
Logistic Regression curve (blue) across most of the specificity range,
confirming Random Forest's higher AUC (0.813 vs 0.765) — it captures
predictive relationships, likely non-linear ones, that the logistic model
misses.

---

### 12. Random Forest — Variable Importance Plot
**File:** *not yet exported*
**Code:** `varImpPlot(rf_model, main = "Random Forest — Variable Importance")`

Same issue as the Decision Tree plot above — it renders but was never saved.
Run the `varImpPlot(...)` line, export as `Rplot08.png`, and add it here.

Ranks predictors by their contribution to the Random Forest's predictive
accuracy (Mean Decrease in Accuracy / Gini).

**Key finding:** Identifies which financial indicators the ensemble model
relies on most heavily — cross-check this against the Decision Tree's split
order and the Logistic Regression's significant coefficients to see which
variables are consistently important across all three methods.

---

## Summary Table — All Models Compared

| Model | Accuracy | Sensitivity | Specificity | AUC |
|---|---|---|---|---|
| Decision Tree | 79.58% | 42.11% | 95.52% | — |
| Logistic Regression | 73.30% | 31.58% | 91.05% | 0.765 |
| Random Forest | 78.53% | 40.35% | 94.78% | 0.813 |

**Consistent pattern across all three:** high specificity, low sensitivity —
a direct consequence of class imbalance (only ~29.8% of bank-years are
deterioration cases). Random Forest achieved the best overall discriminatory
power.

---

## Notes on File Formats

- **Static plots** (`.png`): viewable directly in any image viewer or embedded
  in a report/Rmd via `![](filename.png)`.
- **Animated plots** (`.gif`): will only play in an HTML-rendered document
  (e.g., knitted R Markdown with `output: html_document`) or a GIF-compatible
  viewer. They will **not** animate in a printed PDF or Word document — use a
  key static frame instead if submitting in those formats.
- Colors are **deliberately distinct per graph** (not one repeated palette) —
  purple histogram, lavender boxplot, dark plum barplot, viridis-family
  facet density, green correlation heatmap, maroon single ROC, blue/red ROC
  comparison, and separate palettes for each animated chart.
- Two plots (Decision Tree, Random Forest Variable Importance) still need to
  be exported from RStudio's Plots pane before this README is complete.
