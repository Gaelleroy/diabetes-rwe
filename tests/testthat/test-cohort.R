# test-cohort.R
# Data-quality tests for the analytic cohort (encodes protocol Section 9).

library(testthat)

# Locate the cohort file relative to the project root, regardless of where
# the tests are launched from.
cohort_path <- file.path(rprojroot::find_root(rprojroot::has_file("DESCRIPTION") | rprojroot::is_rstudio_project), "data", "cohort.rds")

cohort <- readRDS(cohort_path)

test_that("every beneficiary is age 65 or older at index", {
  expect_true(all(cohort$age_at_index >= 65))
})

test_that("has_diabetes is a clean logical with no missing values", {
  expect_type(cohort$has_diabetes, "logical")
  expect_false(any(is.na(cohort$has_diabetes)))
})

test_that("each beneficiary appears exactly once (unique IDs)", {
  expect_equal(nrow(cohort), length(unique(cohort$DESYNPUF_ID)))
})

test_that("sex is coded 1 or 2 with no missing values", {
  expect_true(all(cohort$BENE_SEX_IDENT_CD %in% c(1, 2)))
})

test_that("cohort size is within a sane expected range", {
  expect_gt(nrow(cohort), 50000)
  expect_lt(nrow(cohort), 116352)
})

