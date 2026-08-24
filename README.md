# Diabetes and Healthcare Utilization — a Claims-Based RWE Study in R

A reproducible, enterprise-workflow real-world-evidence (RWE) study estimating the
association between diabetes and 2009 healthcare utilization among Medicare
beneficiaries, using CMS DE-SynPUF **synthetic** claims data.

> **Note on data & scope.** DE-SynPUF is synthetic Medicare data. It mirrors the
> structure of real claims but has no inferential validity, so results are a
> **methods demonstration**, not clinical evidence. This is a solo project built to
> enterprise *patterns* (reproducibility, testing, CI) on synthetic data.

## Key result

After adjustment for age, sex, and comorbidities (negative binomial regression):

| Outcome | Crude RR | Adjusted RR (95% CI) |
|---|---|---|
| Inpatient admissions | 3.06 | **1.63 (1.57–1.70)** |
| Outpatient visits | 2.48 | **1.68 (1.65–1.71)** |

Diabetes was independently associated with ~63–68% higher utilization. Roughly half
the crude admission association was explained by confounding — visible in the
crude→adjusted shrinkage.

## Study design

- **Design:** retrospective comparative cohort. Baseline 2008, index 2009-01-01,
  follow-up 2009.
- **Population:** 80,988 beneficiaries — aged ≥ 65, alive at index, continuously
  enrolled (Part A & B) in 2008. (From 116,352 at baseline; see attrition in the report.)
- **Exposure:** diabetes at baseline (`SP_DIABETES`).
- **Outcomes:** counts of 2009 inpatient admissions (primary) and outpatient visits.
- **Analysis:** negative binomial regression (Poisson rejected after an overdispersion
  test), adjusted for age, sex, CHF, CKD, COPD, and ischemic heart disease.

The full write-up (attrition, Table 1, models, interpretation) is in
[`reports/diabetes_utilization_report.html`](reports/diabetes_utilization_report.html)
(open locally) and its source `.qmd`.

## Pipeline

```
data-raw/download_desynpuf.R   # reproducibly download + unzip DE-SynPUF files
R/01_prepare_cohort.R          # build cohort, inclusion/exclusion, attrition log
R/02_describe_cohort.R         # Table 1 by diabetes group
R/03_build_outcomes.R          # count 2009 claims per beneficiary, join to cohort
R/04_model_inpatient.R         # negative binomial model, inpatient admissions
R/05_model_outpatient.R        # negative binomial model, outpatient visits
reports/*.qmd                  # Quarto report
tests/testthat/                # data-quality tests
```

## Reproducibility & workflow

- **Environment** pinned with [`renv`](https://rstudio.github.io/renv/) (`renv.lock`).
- **Data never committed** — regenerated from `data-raw/download_desynpuf.R`.
- **Data-quality tests** (`testthat`) encode the protocol's checks (age ≥ 65,
  clean exposure, unique IDs, non-negative integer outcomes).
- **CI** (GitHub Actions) rebuilds the whole pipeline from scratch on a clean runner
  and runs the tests on every push/PR; `main` is protected and requires a green check.
- **Protocol** was committed and tagged (`protocol-v1.0`) **before** results — the RWE
  analog of pre-registration.

## Reproduce it

```r
# 1. Clone, open the RStudio project, then:
renv::restore()                       # rebuild the exact package environment
source("data-raw/download_desynpuf.R") # download + unzip data
source("R/01_prepare_cohort.R")        # build cohort
source("R/03_build_outcomes.R")        # build outcomes
source("R/04_model_inpatient.R")       # inpatient model
source("R/05_model_outpatient.R")      # outpatient model
testthat::test_dir("tests/testthat")   # run data-quality tests
# then render reports/diabetes_utilization_report.qmd
```

## Limitations

Synthetic data (no inferential validity); comorbidities may lie on the causal pathway
from diabetes (adjustment may underestimate the total effect); a fixed one-year window
ignores differential follow-up time.

## Tech

R · dplyr · MASS · AER · readr · testthat · renv · Quarto · GitHub Actions · git

