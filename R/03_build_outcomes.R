# 03_build_outcomes.R
# Purpose: build 2009 healthcare-utilization outcomes and join to the cohort.
# Input:   data/cohort.rds, inpatient + outpatient claims CSVs.
# Output:  data/cohort_outcomes.rds (one row per beneficiary + outcome counts).

library(readr)
library(dplyr)

# Read claims with all columns as character to avoid type-guessing on sparse
# code columns; we only need DESYNPUF_ID and the date, converted below.
read_claims <- function(path) {
  read_csv(path, col_types = cols(.default = col_character()))
}

# --- Load cohort and raw claims --------------------------------------------
cohort <- readRDS("data/cohort.rds")
inpatient  <- read_claims("data-raw/DE1_0_2008_to_2010_Inpatient_Claims_Sample_1.csv")
outpatient <- read_claims("data-raw/DE1_0_2008_to_2010_Outpatient_Claims_Sample_1.csv")

# --- Count 2009 inpatient admissions per beneficiary -----------------------
inpatient_counts <- inpatient |>
  filter(as.integer(CLM_ADMSN_DT) %/% 10000 == 2009) |>
  group_by(DESYNPUF_ID) |>
  summarise(n_inpatient = n(), .groups = "drop")

# --- Count 2009 outpatient visits per beneficiary --------------------------
outpatient_counts <- outpatient |>
  filter(as.integer(CLM_FROM_DT) %/% 10000 == 2009) |>
  group_by(DESYNPUF_ID) |>
  summarise(n_outpatient = n(), .groups = "drop")

# --- Join both to cohort; non-matches = 0 (not NA) -------------------------
cohort_outcomes <- cohort |>
  left_join(inpatient_counts,  by = "DESYNPUF_ID") |>
  left_join(outpatient_counts, by = "DESYNPUF_ID") |>
  mutate(
    n_inpatient  = coalesce(n_inpatient, 0),
    n_outpatient = coalesce(n_outpatient, 0)
  )

# --- Save analysis-ready dataset -------------------------------------------
saveRDS(cohort_outcomes, "data/cohort_outcomes.rds")
message("Saved cohort_outcomes.rds: ", nrow(cohort_outcomes), " rows | ",
        sum(cohort_outcomes$n_inpatient),  " inpatient, ",
        sum(cohort_outcomes$n_outpatient), " outpatient (2009)")

