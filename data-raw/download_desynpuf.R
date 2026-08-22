# download_desynpuf.R
# Purpose: reproducibly download AND extract CMS DE-SynPUF Sample 1 files.
# Data: synthetic Medicare claims (2008-2010). No PHI. Safe to re-run.

options(timeout = 600)

base_url <- "https://www.cms.gov/research-statistics-data-and-systems/downloadable-public-use-files/synpufs/downloads/"

# Helper: download a zip (if missing) then unzip it (if csv missing) ---------
fetch_and_unzip <- function(zip_name) {
  zip_url  <- paste0(base_url, zip_name)
  zip_path <- file.path("data-raw", zip_name)
  if (!file.exists(zip_path)) {
    download.file(zip_url, zip_path, mode = "wb", method = "libcurl")
  }
  unzip(zip_path, exdir = "data-raw", overwrite = FALSE)
}

# Files needed for the study ------------------------------------------------
fetch_and_unzip("de1_0_2008_beneficiary_summary_file_sample_1.zip")
fetch_and_unzip("de1_0_2008_to_2010_inpatient_claims_sample_1.zip")
fetch_and_unzip("de1_0_2008_to_2010_outpatient_claims_sample_1.zip")

