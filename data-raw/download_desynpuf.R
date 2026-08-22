# download_desynpuf.R
# Purpose: reproducibly download AND extract CMS DE-SynPUF Sample 1 files.
# Data: synthetic Medicare claims (2008-2010). No PHI. Safe to re-run.

options(timeout = 300)

base_url <- "https://www.cms.gov/research-statistics-data-and-systems/downloadable-public-use-files/synpufs/downloads/"

# 2008 Beneficiary Summary File
bene_2008_url <- paste0(base_url, "de1_0_2008_beneficiary_summary_file_sample_1.zip")
bene_2008_zip <- file.path("data-raw", "de1_0_2008_beneficiary_summary_file_sample_1.zip")
bene_2008_csv <- file.path("data-raw", "DE1_0_2008_Beneficiary_Summary_File_Sample_1.csv")

# Download the ZIP (only if not already present)
if (!file.exists(bene_2008_zip)) {
  download.file(url = bene_2008_url, destfile = bene_2008_zip,
                mode = "wb", method = "libcurl")
}

# Extract the CSV (only if not already extracted)
if (!file.exists(bene_2008_csv)) {
  unzip(bene_2008_zip, exdir = "data-raw")
}

