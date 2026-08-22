# 05_model_outpatient.R
# Purpose: model 2009 outpatient visits ~ diabetes, crude and adjusted.
# Rechecks overdispersion for this outcome, then fits negative binomial.
# Input:   data/cohort_outcomes.rds
# Output:  data/model_outpatient.rds (fitted adjusted model + tidy results)

library(dplyr)
library(MASS)      # glm.nb  (note: MASS::select masks dplyr::select)
library(AER)       # dispersiontest

co <- readRDS("data/cohort_outcomes.rds")

# --- Recode covariates to intuitive form -----------------------------------
co <- co |>
  mutate(
    female = BENE_SEX_IDENT_CD == 2,
    chf    = SP_CHF      == 1,
    ckd    = SP_CHRNKIDN == 1,
    copd   = SP_COPD     == 1,
    ihd    = SP_ISCHMCHT == 1
  )

# --- Check overdispersion for the outpatient outcome -----------------------
m_pois <- glm(n_outpatient ~ has_diabetes, data = co, family = poisson)
disp <- dispersiontest(m_pois)
message("Overdispersion test: dispersion = ", round(disp$estimate, 3),
        ", p = ", format.pval(disp$p.value))

# --- Crude model -----------------------------------------------------------
m_crude <- glm.nb(n_outpatient ~ has_diabetes, data = co)

# --- Adjusted model --------------------------------------------------------
m_adj <- glm.nb(
  n_outpatient ~ has_diabetes + age_at_index + female +
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

# --- Save ------------------------------------------------------------------
saveRDS(list(model = m_adj, rr_table = rr_table), "data/model_outpatient.rds")

