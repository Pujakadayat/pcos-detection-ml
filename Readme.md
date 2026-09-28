# 🩺 PCOS Detection using Machine Learning
### Part 2 — Women's Reproductive Health AI Series 🇳🇵

> *Motivated by personal experience of late diagnosis of Uterine Fibroid in Nepal —
> where reproductive health awareness is critically low — this notebook is Part 2
> of a Women's Reproductive Health AI Series exploring data-driven early detection
> of gynecological conditions in low-resource settings.*

---

##  Overview

PCOS (Polycystic Ovary Syndrome) affects **1 in 10 women globally**, yet diagnosis
is frequently delayed by years. This project explores whether clinical and lifestyle
data can predict PCOS status, using a dataset of 541 patients collected across
10 hospitals in Kerala, India.

---

## 📂 Dataset

**Source:** [Polycystic Ovary Syndrome (PCOS) — Kaggle](https://www.kaggle.com/datasets/prasoonkottarathil/polycystic-ovary-syndrome-pcos), by Prasoon Kottarathil

| File | Records | Features |
|------|---------|---------|
| `PCOS_infertility.csv` | 541 | 3 hormonal (beta-HCG I/II, AMH) |
| `PCOS_data_without_infertility.xlsx` | 541 | 40+ clinical + lifestyle |

Both files describe the same 541 patients in the same row order — verified by
cross-checking `Patient File No.` and independently-recorded `PCOS (Y/N)` values.

---

## 🔍 Data Quality Issues Found & Fixed

| Issue | Column | Fix Applied |
|-------|--------|-------------|
| Column read as `object` due to stray `'a'` value | `AMH(ng/mL)` | `pd.to_numeric(errors='coerce')` + median imputation |
| Same issue in larger file | `II beta-HCG(mIU/mL)` | Same fix |
| Near-empty column (539/541 missing) | `Unnamed: 44` | Dropped as formatting artifact |
| 1 null in `Marraige Status (Yrs)` | `Marraige Status (Yrs)` | Median imputation |
| 1 null in `Fast food (Y/N)` | `Fast food (Y/N)` | Mode imputation |

Bad values were isolated with a custom numeric-check function before conversion,
so the fix was surgical rather than blanket.

---

## ⚖️ Class Balance

```
PCOS Negative:  364 patients  (67.3%)
PCOS Positive:  177 patients  (32.7%)
```

A model that always predicts "no PCOS" scores **67.3% accuracy by doing nothing** —
this is the baseline every model below is measured against. Given the moderate
(not extreme) imbalance, plain accuracy is usable but **recall on the PCOS class
is the more meaningful metric** for a diagnostic use case, where missing a positive
case carries real clinical cost.

---

## 🧪 Phase 1 — Hormone Features Only (AMH, beta-HCG I & II)

### AMH vs. PCOS
Mean AMH is **4.54 ng/mL** (no PCOS) vs. **7.84 ng/mL** (PCOS) — consistent with
PCOS biology, where excess small follicles produce more AMH. Literature cites
≥3.9 ng/mL as a supporting threshold. Testing that against this dataset:
- 65% of PCOS patients crossed the threshold
- 40% of non-PCOS patients also crossed it

A real but heavily overlapping signal. AMH alone is not diagnostic.

### beta-HCG vs. PCOS
No meaningful separation between groups — expected, as beta-HCG is a pregnancy
hormone with no established role in PCOS pathophysiology. Its inclusion here
tests that assumption empirically rather than assuming it.

### Phase 1 Model Results

| Model | Accuracy | Recall (PCOS) |
|-------|----------|---------------|
| Logistic Regression | 65.1% | 0.39 |
| Random Forest | 65.1% | 0.36 |

Both plateaued around 65% accuracy — barely above the do-nothing baseline, and
consistent across two different algorithms. **Conclusion: 3 hormone features alone
are insufficient for reliable PCOS classification.**

---

## 🔬 Phase 2 — Full Feature Set (23 Clinical & Lifestyle Features)

### Feature Selection by Effect Size

Rather than selecting features by assumption, all 43 numeric and binary columns
were ranked by **effect size** (group mean difference ÷ pooled standard deviation).
Top features aligned closely with the **Rotterdam criteria** — the actual clinical
standard for PCOS diagnosis (requires 2 of 3: irregular cycles, polycystic
ovaries/elevated follicle count, excess androgen symptoms):

| Feature | Effect Size |
|---------|-------------|
| Follicle No. (R) | 1.38 |
| Follicle No. (L) | 1.28 |
| Skin darkening (Y/N) | 1.01 |
| Hair growth (Y/N) | 0.99 |
| Weight gain (Y/N) | 0.94 |
| Cycle (R/I) | 0.86 |
| LH (mIU/mL) | 0.62 |
| AMH (ng/mL) | 0.56 |

15 features were selected spanning follicle counts, cycle regularity,
androgen-related symptoms, hormones, and weight-adjacent measures.

### Phase 2 Model Results

| Model | Accuracy | Recall (PCOS) | AUC |
|-------|----------|---------------|-----|
| Logistic Regression (3 features) | 65.1% | 0.39 | ~0.72 |
| Random Forest (3 features) | 65.1% | 0.36 | ~0.70 |
| Logistic Regression (15 features) | 90.8% | 0.89 | ~0.96 |
| Random Forest (23 features) | 92.7% | 0.83 | ~0.97 |

---

## 🔎 SHAP Explainability

SHAP (SHapley Additive exPlanations) values confirm follicle count and
androgen-related symptoms as the dominant predictors — consistent with both
the effect size ranking above and the Rotterdam criteria. Two independent
methods (effect size ranking and SHAP) pointing to the same features
strengthens confidence that these are real signals in the data rather
than modeling artifacts.

---

## 💡 Interpretation

This model does **not** discover new medical knowledge about PCOS. Its strongest
features (follicle count, cycle regularity, androgen-related symptoms) are proxies
for the Rotterdam criteria already used to diagnose the condition — so the result
is better described as **reconstructing a known diagnostic process from
patient-reported and clinical data**, not finding a novel pattern.

That agreement between two independently-built models, both pointing to the
same features that match established clinical criteria, supports this being a
genuine shared signal rather than a modeling artifact.

That is still a meaningful result: it demonstrates that a **lightweight screening
tool built from patient-reported and clinical-exam data (no lab bloodwork required)**
can approximate a Rotterdam-based diagnosis with strong recall — potentially
useful for **pre-screening or triage**, not as a replacement for clinical diagnosis.

---

## 🇳🇵 Nepal Context & Research Gap

In Nepal:
- Reproductive health literacy is critically low
- Gynaecologist access in rural areas is severely limited
- Cultural stigma delays women from seeking diagnosis
- **No ML-based early detection tool exists for PCOS or related gynecological
  conditions in the Nepali clinical context**

This project lays the methodological foundation for a Nepal-specific screening
framework — future work will incorporate Nepal DHS 2022 survey data and primary
data collection from Nepali women.

---

## 🛠️ Tech Stack

```
Python 3.11
pandas · numpy · scikit-learn · seaborn · matplotlib · shap
```

---

## 🔗 Women's Reproductive Health AI Series

| Part | Project | Link |
|------|---------|------|
| 1 | Cervical Cancer Risk Prediction | [Kaggle](#) · [GitHub](https://github.com/Pujakadayat/cervical-cancer-risk-classification) |
| 2 | PCOS Detection | ← This notebook |

---

## 👩‍💻 Author

**Puja Kadayat** — CS Graduate, Kathmandu University, Nepal
[pujakadayat.com.np](https://pujakadayat.com.np) ·
[GitHub](https://github.com/Pujakadayat) ·
[pujakadayat1@gmail.com](mailto:pujakadayat1@gmail.com)

---

*If you find this useful, please upvote on Kaggle — it helps surface
women's health AI research to a wider audience. 🙏*