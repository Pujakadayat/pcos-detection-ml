# PCOS Detection — Exploratory Analysis & Classification

Exploring whether clinical and lifestyle data can predict PCOS (Polycystic Ovary Syndrome) status, using a dataset of 541 patients collected across 10 hospitals in Kerala, India.

## Dataset

- Source: [Polycystic Ovary Syndrome (PCOS)](https://www.kaggle.com/datasets/prasoonkottarathil/polycystic-ovary-syndrome-pcos) — Kaggle, by Prasoon Kottarathil
- 541 patients, 2 files covering the same population:
  - `PCOS_infertility.csv` — 5 hormone-related fields (beta-HCG I/II, AMH)
  - `PCOS_data_without_infertility.xlsx` — 44 fields (BMI, cycle data, follicle counts, symptoms, hormones, vitals)
- Verified both files describe the same 541 patients in the same row order, by cross-checking `Patient File No.` and independently-recorded `PCOS (Y/N)` values.

## Data Quality Issues Found

- `AMH(ng/mL)` was read as text (`object`) in both files due to a single invalid value (a stray `'a'` in one row) forcing pandas to treat the whole column as strings.
- `II beta-HCG(mIU/mL)` had the same issue in the larger file.
- One near-empty column (`Unnamed: 44`, 539/541 missing) was dropped as a formatting artifact.
- Fix: isolated each bad value with a custom numeric-check function, converted the column with `pd.to_numeric(errors='coerce')`, and imputed the resulting single `NaN` with the column mean.

## Class Balance

`PCOS (Y/N)`: 364 negative (67.3%) vs. 177 positive (32.7%). A model that always predicts "no PCOS" scores 67.3% accuracy by doing nothing — this is the baseline every model below is measured against. Given the moderate (not extreme) imbalance, plain accuracy is usable but recall on the PCOS class is the more meaningful metric for a diagnostic use case.

## Phase 1 — Hormone Features Only (AMH, beta-HCG I & II)

**AMH vs. PCOS:** mean AMH is 4.54 ng/mL (no PCOS) vs. 7.84 ng/mL (PCOS) — consistent with PCOS biology (excess small follicles produce more AMH) and with literature citing elevated AMH (≥3.9 ng/mL threshold) as supporting evidence for PCOS, though not diagnostic alone. Testing that threshold against this dataset: 65% of PCOS patients and 40% of non-PCOS patients crossed it — a real but heavily overlapping signal (std nearly as large as the mean in both groups).

**beta-HCG vs. PCOS:** no clear separation between groups — expected, since beta-HCG is fundamentally a pregnancy marker, not a PCOS marker.

**Models (Logistic Regression, Random Forest):** both plateaued around 65% accuracy and 0.36–0.39 recall on the PCOS class — barely above the do-nothing baseline, and consistent across two different algorithms. Conclusion: 3 hormone features alone are insufficient for reliable PCOS classification.

## Phase 2 — Full Feature Set

Ranked all 43 numeric/binary columns by effect size (group mean difference ÷ pooled std) rather than selecting features by assumption. Top features aligned closely with the **Rotterdam criteria** (the actual clinical standard for PCOS diagnosis — 2 of 3 required: irregular cycles, polycystic ovaries/follicle count, excess androgen symptoms):

| Feature | Effect size |
|---|---|
| Follicle No. (R) | 1.38 |
| Follicle No. (L) | 1.28 |
| Skin darkening (Y/N) | 1.01 |
| hair growth (Y/N) | 0.99 |
| Weight gain (Y/N) | 0.94 |
| Cycle (R/I) | 0.86 |
| AMH (ng/mL) | 0.56 |

Selected 15 features spanning follicle counts, cycle regularity, androgen-related symptoms, AMH, and weight/BMI-adjacent measures.

**Models:**

| Model | Accuracy | Recall (PCOS) |
|---|---|---|
| Logistic Regression (hormones only) | 65.1% | 0.39 |
| Random Forest (hormones only) | 65.1% | 0.36 |
| Logistic Regression (15 features) | 90.8% | 0.89 |
| Random Forest (15 features) | 92.7% | 0.83 |

## Interpretation

This model does not discover new medical knowledge about PCOS. Its strongest features (follicle count, cycle regularity, androgen-related symptoms) are proxies for the Rotterdam criteria already used to diagnose the condition — so the result is better described as **reconstructing a known diagnostic process from patient-reported and clinical data**, not finding a novel pattern. That agreement between two independent, differently-built models (rather than one model's result spiking alone) supports this being a real, shared signal in the features rather than a modeling artifact.

That's still a meaningful result: it demonstrates that a lightweight screening tool built from patient-reported and clinical-exam data (no lab bloodwork required) can approximate a Rotterdam-based diagnosis with strong recall — potentially useful for pre-screening or triage, not as a replacement for clinical diagnosis.



