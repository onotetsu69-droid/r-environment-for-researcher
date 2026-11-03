# scripts/01_data_import.R
# @plan_id G0-3

# 設定読み込み
if (file.exists("scripts/_project_config.R")) {
  source("scripts/_project_config.R")
} else if (file.exists("_project_config.R")) {
  source("_project_config.R")
} else {
  source(file.path("projects", "hypertension_logistic_sim", "scripts", "_project_config.R"))
}

cat("=== Data Import and Verification (G0-3) ===\n")

raw_file <- file.path(raw_data_dir, "hypertension_sim_raw.csv")
if (!file.exists(raw_file)) {
  stop(sprintf("Raw data file not found: %s. Run 00_generate_synthetic_data.R first.", raw_file))
}

# インポート（base R / readr のフォールバック対応）
if (requireNamespace("readr", quietly = TRUE)) {
  df <- as.data.frame(readr::read_csv(raw_file, show_col_types = FALSE))
} else {
  df <- read.csv(raw_file, stringsAsFactors = FALSE)
}

# 検証
n_rows <- nrow(df)
n_cols <- ncol(df)
n_missing <- sum(is.na(df))
n_events <- sum(df$htn == 1)

cat(sprintf("Imported rows: %d (Expected: 100)\n", n_rows))
cat(sprintf("Imported columns: %d (Expected: 9)\n", n_cols))
cat(sprintf("Missing values: %d (Expected: 0)\n", n_missing))
cat(sprintf("Outcome events (htn=1): %d\n", n_events))

if (n_rows != 100) stop(sprintf("Row count mismatch: %d != 100", n_rows))
if (n_cols != 9) stop(sprintf("Column count mismatch: %d != 9", n_cols))
if (n_missing > 0) stop(sprintf("Unexpected missing values found: %d", n_missing))

cat("Data integrity check PASSED.\n")

