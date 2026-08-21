# download_desynpuf.R
# Purpose: reproducibly download CMS DE-SynPUF Sample 1 files into data-raw/.
# Data: synthetic Medicare claims (2008-2010). No PHI. Safe to re-run.

# CMS server is slow and redirects; raise timeout and use a robust downloader
options(timeout = 300)

base_url <- "https://www.cms.gov/research-statistics-data-and-systems/downloadable-public-use-files/synpufs/downloads/"

# 2008 Beneficiary Summary File — baseline: exposure (diabetes) + covariates
bene_2008_url <- paste0(base_url, "de1_0_2008_beneficiary_summary_file_sample_1.zip")
bene_2008_zip <- file.path("data-raw", "de1_0_2008_beneficiary_summary_file_sample_1.zip")

if (!file.exists(bene_2008_zip)) {
  download.file(url = bene_2008_url, destfile = bene_2008_zip,
                mode = "wb", method = "libcurl")
}

