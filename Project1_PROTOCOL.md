# Study Protocol & Statistical Analysis Plan (SAP)

**Study title:** Healthcare Utilization Among Medicare Beneficiaries With vs. Without Diabetes
**Data source:** CMS DE-SynPUF (2008–2010 synthetic Medicare claims), Sample 1
**Version:** 0.1 (draft) — *to be tagged `protocol-v1.0` before any results are computed*
**Author:** Gael Songwa

> **Integrity note.** This protocol is committed and tagged **before** outcomes are
> analyzed. Any change after results exist is a new version with a documented reason.
> This is the RWE analog of pre-registration and is the study's credibility anchor.

> **Data note.** DE-SynPUF is **synthetic**. It faithfully mimics the *structure* of
> Medicare claims but has **no inferential validity** — results are for methods
> demonstration and learning, not clinical conclusions.

---

## 1. Objective

Among Medicare beneficiaries, do those **with diabetes** at baseline have higher
**healthcare utilization** during a one-year follow-up than those **without diabetes**,
before and after adjustment for age, sex, and other chronic conditions?

**Primary hypothesis:** beneficiaries with diabetes have a higher rate of inpatient
admissions during follow-up than those without.

---

## 2. Design

Retrospective **comparative cohort** study using synthetic administrative claims.
Two groups (diabetes vs. no diabetes) defined at baseline, compared on utilization
measured over a fixed follow-up window.

---

## 3. Data sources (DE-SynPUF Sample 1 files)

| File | Role in study |
|---|---|
| Beneficiary Summary File 2008 | Baseline: exposure (diabetes), covariates, enrollment |
| Beneficiary Summary File 2009 | Follow-up enrollment / death check |
| Inpatient Claims 2008–2010 | Outcome: inpatient admissions (follow-up year) |
| Outpatient Claims 2008–2010 | Outcome: outpatient visits (follow-up year) |
| (Optional) PDE 2008–2010 | Sensitivity: antidiabetic drug fills |

All files link on **`DESYNPUF_ID`** (one beneficiary key).

**Time frame.** Baseline year = **2008**. Follow-up year = **2009**.
Index date = **2009-01-01** (start of follow-up).

---

## 4. Study population

**Inclusion**
- Present in the 2008 Beneficiary Summary File (baseline observation).
- Continuously enrolled through baseline year 2008 (Part A & B; enrollment months = 12).
- Alive at index date (no death recorded in 2008).
- Age ≥ 65 at index date.

**Exclusion**
- Death during baseline year 2008.
- Missing/implausible birth date or sex.

Each criterion becomes **one `filter()` step** in the cohort-build code.

---

## 5. Exposure

**Diabetes at baseline** = `SP_DIABETES` chronic-condition flag in the **2008**
Beneficiary Summary File.
- In DE-SynPUF this flag is coded **1 = yes, 2 = no** — recode to a clean logical
  `has_diabetes` (TRUE/FALSE) as an explicit, tested step.

---

## 6. Outcomes (measured during follow-up year 2009)

1. **Primary — inpatient admissions:** count of inpatient claims per beneficiary in 2009.
2. **Secondary — outpatient visits:** count of outpatient claims per beneficiary in 2009.
3. **Secondary — total reimbursement:** sum of Medicare reimbursement across 2009 claims.

Beneficiaries with **no** claims in a category have a count of **0** (not missing) —
an explicit left-join-then-replace-NA step.

---

## 7. Covariates (baseline, from 2008 Beneficiary Summary File)

- **Age** at index (derived from `BENE_BIRTH_DT`).
- **Sex** (`BENE_SEX_IDENT_CD`).
- **Other chronic-condition flags** (`SP_*`): CHF, CKD, COPD, ischemic heart disease,
  etc. — each recoded to a clean logical and, optionally, summed into a comorbidity count.

---

## 8. Statistical analysis plan

**Descriptive**
- **Table 1:** baseline characteristics by exposure group (age, sex, comorbidities),
  with appropriate summaries and standardized differences.

**Primary analysis**
- Inpatient admission **counts** → **Poisson regression**; if overdispersed (variance ≫ mean),
  switch to **negative binomial** (`MASS::glm.nb`). Report **adjusted rate ratios (aRR)**
  with 95% CIs, adjusting for age, sex, and comorbidities.

**Secondary analyses**
- Outpatient visit counts → same count-model approach.
- Total reimbursement → linear model on a suitable scale (consider log or a GLM with
  Gamma family given cost skew); report adjusted differences/ratios.

**Sensitivity analyses (pre-specified)**
- S1: negative binomial vs. Poisson comparison for the primary outcome.
- S2: restrict to beneficiaries with continuous follow-up enrollment in 2009.
- S3 (optional): require an antidiabetic drug fill (PDE) to confirm the diabetes flag.

**Missing data.** Report completeness for every analysis variable. Exclusions are
counted and shown in an attrition (flow) summary; no imputation in the primary analysis.

---

## 9. Data-quality checks (become `testthat` tests)

- Every included beneficiary is **age ≥ 65** at index.
- `has_diabetes` is strictly TRUE/FALSE (no un-recoded `1/2`, no NA).
- No **negative** utilization counts or reimbursement values.
- Each `DESYNPUF_ID` appears **once** in the final analytic (one-row-per-patient) dataset.
- Cohort size is within an expected range (sanity bound on N).
- Follow-up counts of 0 are real zeros, not NAs introduced by joins.

---

## 10. Deliverables

- Reproducible `targets` pipeline producing the analytic dataset, models, and figures.
- Quarto report rendering entirely from the pipeline (no hand-entered numbers).
- Attrition summary, Table 1, model results with aRRs/CIs, and outcome figures.

---

## 11. Deviations log

Any change to this protocol after `protocol-v1.0` is recorded here with date and reason.

| Date | Section | Change | Reason |
|---|---|---|---|
| — | — | — | — |
