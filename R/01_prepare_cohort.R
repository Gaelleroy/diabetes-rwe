# 01_prepare_cohort.R
# Purpose: build the analytic cohort from the 2008 Beneficiary Summary File.
# Stage: data preparation (exposure recode; more derivations to follow).

library(readr)
library(dplyr)

# --- Load raw data -----------------------------------------------------------
bene_2008 <- read_csv(
  "data-raw/DE1_0_2008_Beneficiary_Summary_File_Sample_1.csv",
  show_col_types = FALSE
)

# --- Exposure: recode diabetes flag (1 = yes, 2 = no) to logical -------------
bene_2008 <- bene_2008 %>%
  mutate(has_diabetes = SP_DIABETES == 1)