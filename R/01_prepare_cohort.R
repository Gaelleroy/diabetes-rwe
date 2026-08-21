# 01_prepare_cohort.R
# Purpose: build the analytic cohort from the 2008 Beneficiary Summary File.
# Stage: data preparation + inclusion/exclusion with attrition tracking.

library(readr)
library(dplyr)

# --- Load raw data (Criterion 1: present in 2008 baseline file) -------------
bene_2008 <- read_csv(
  "data-raw/DE1_0_2008_Beneficiary_Summary_File_Sample_1.csv",
  show_col_types = FALSE
)

# --- Derive analytic variables ---------------------------------------------
bene_2008 <- bene_2008 |>
  mutate(
    has_diabetes = SP_DIABETES == 1,              # exposure (1=yes, 2=no)
    birth_year   = BENE_BIRTH_DT %/% 10000,       # year from YYYYMMDD
    age_at_index = 2009 - birth_year              # age at index 2009-01-01
  )

# --- Cohort inclusion/exclusion (with attrition tracking) ------------------
# Baseline population = everyone present in the 2008 Summary File (Criterion 1)
n_baseline <- nrow(bene_2008)

# Exclusion: missing/implausible birth date or sex (data quality)
cohort <- bene_2008 |>
  filter(!is.na(BENE_BIRTH_DT),
         BENE_SEX_IDENT_CD %in% c(1, 2))
n_after_dq <- nrow(cohort)

# Inclusion: age >= 65 at index
cohort <- cohort |>
  filter(age_at_index >= 65)
n_after_age <- nrow(cohort)

# Inclusion: alive at index (no death recorded during baseline 2008)
cohort <- cohort |>
  filter(is.na(BENE_DEATH_DT))
n_after_alive <- nrow(cohort)

# Inclusion: continuously enrolled all of 2008 (Part A AND Part B = 12 mo)
cohort <- cohort |>
  filter(BENE_HI_CVRAGE_TOT_MONS == 12 & BENE_SMI_CVRAGE_TOT_MONS == 12)
n_after_enroll <- nrow(cohort)

# --- Attrition log ---------------------------------------------------------
message("Attrition:")
message("  Baseline population:  ", n_baseline)
message("  After DQ (dob/sex):   ", n_after_dq,     " (removed ", n_baseline - n_after_dq, ")")
message("  After age >= 65:      ", n_after_age,    " (removed ", n_after_dq - n_after_age, ")")
message("  After alive at idx:   ", n_after_alive,  " (removed ", n_after_age - n_after_alive, ")")
message("  After cont. enroll:   ", n_after_enroll, " (removed ", n_after_alive - n_after_enroll, ")")

