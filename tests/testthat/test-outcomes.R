# test-outcomes.R
# Data-quality tests for the outcome dataset (protocol Section 9).

library(testthat)

root <- rprojroot::find_root(rprojroot::is_rstudio_project)
co <- readRDS(file.path(root, "data", "cohort_outcomes.rds"))

test_that("outcome dataset keeps all cohort members (no rows lost in joins)", {
  cohort <- readRDS(file.path(root, "data", "cohort.rds"))
  expect_equal(nrow(co), nrow(cohort))
})

test_that("outcome counts have no missing values (non-matches filled as 0)", {
  expect_false(any(is.na(co$n_inpatient)))
  expect_false(any(is.na(co$n_outpatient)))
})

test_that("outcome counts are non-negative integers", {
  expect_true(all(co$n_inpatient  >= 0))
  expect_true(all(co$n_outpatient >= 0))
  expect_true(all(co$n_inpatient  == floor(co$n_inpatient)))
  expect_true(all(co$n_outpatient == floor(co$n_outpatient)))
})

test_that("each beneficiary still appears exactly once", {
  expect_equal(nrow(co), length(unique(co$DESYNPUF_ID)))
})

