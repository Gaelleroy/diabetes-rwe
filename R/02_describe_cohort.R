# 02_describe_cohort.R
# Purpose: baseline characteristics (Table 1) of the analytic cohort,
#          summarised by diabetes exposure group.
# Input:   data/cohort.rds (produced by 01_prepare_cohort.R)
# Note:    age is right-skewed (verified via histogram + Q-Q plot),
#          so it is summarised as median [IQR], not mean (SD).

library(dplyr)

# --- Load the analytic cohort (pipeline hand-off from script 01) ------------
cohort <- readRDS("data/cohort.rds")

# --- Table 1: baseline characteristics by diabetes group -------------------
table1 <- cohort |>
  group_by(has_diabetes) |>
  summarise(
    n           = n(),
    age_median  = median(age_at_index),
    age_q1      = quantile(age_at_index, 0.25),
    age_q3      = quantile(age_at_index, 0.75),
    pct_female  = mean(BENE_SEX_IDENT_CD == 2) * 100,
    pct_chf     = mean(SP_CHF == 1) * 100,
    pct_ckd     = mean(SP_CHRNKIDN == 1) * 100,
    pct_copd    = mean(SP_COPD == 1) * 100,
    pct_ihd     = mean(SP_ISCHMCHT == 1) * 100,
    .groups = "drop"
  )

print(table1)

