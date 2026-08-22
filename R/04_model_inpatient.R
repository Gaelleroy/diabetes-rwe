# 04_model_inpatient.R
# Purpose: model 2009 inpatient admissions ~ diabetes, crude and adjusted.
# Chooses negative binomial over Poisson based on an overdispersion test.
# Input:   data/cohort_outcomes.rds
# Output:  data/model_inpatient.rds (fitted adjusted model + tidy results)

library(dplyr)
library(MASS)      # glm.nb  (note: MASS::select masks dplyr::select)
library(AER)       # dispersiontest

co <- readRDS("data/cohort_outcomes.rds")

# --- Recode covariates to intuitive form -----------------------------------
# SP_* flags are 1 = yes, 2 = no. Recode to logical so RR > 1 = more admissions.
co <- co |>
  mutate(
    female = BENE_SEX_IDENT_CD == 2,
    chf    = SP_CHF      == 1,
    ckd    = SP_CHRNKIDN == 1,
    copd   = SP_COPD     == 1,
    ihd    = SP_ISCHMCHT == 1
  )

# --- Check overdispersion (justifies NB over Poisson) ----------------------
m_pois <- glm(n_inpatient ~ has_diabetes, data = co, family = poisson)
disp <- dispersiontest(m_pois)
message("Overdispersion test: dispersion = ", round(disp$estimate, 3),
        ", p = ", format.pval(disp$p.value))
# dispersion > 1 with small p -> Poisson inadequate -> use negative binomial

# --- Crude model (diabetes only) -------------------------------------------
m_crude <- glm.nb(n_inpatient ~ has_diabetes, data = co)

# --- Adjusted model (diabetes + confounders) -------------------------------
m_adj <- glm.nb(
  n_inpatient ~ has_diabetes + age_at_index + female +
    chf + ckd + copd + ihd,
  data = co
)

# --- Rate ratios with 95% confidence intervals -----------------------------
rr_table <- cbind(
  RR      = exp(coef(m_adj)),
  CI_low  = exp(confint.default(m_adj))[, 1],
  CI_high = exp(confint.default(m_adj))[, 2]
)

# --- Report ----------------------------------------------------------------
message("Crude diabetes RR:    ", round(exp(coef(m_crude))[["has_diabetesTRUE"]], 3))
message("Adjusted diabetes RR: ", round(exp(coef(m_adj))[["has_diabetesTRUE"]], 3))
message("")
message("Adjusted rate ratios (95% CI):")
print(round(rr_table, 3))

# --- Save fitted model + results -------------------------------------------
saveRDS(list(model = m_adj, rr_table = rr_table), "data/model_inpatient.rds")

