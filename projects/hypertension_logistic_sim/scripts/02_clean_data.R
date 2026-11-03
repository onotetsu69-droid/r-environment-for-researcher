# scripts/02_clean_data.R
# @plan_id G0-4

# 設定読み込み
if (file.exists("scripts/_project_config.R")) {
  source("scripts/_project_config.R")
} else if (file.exists("_project_config.R")) {
  source("_project_config.R")
} else {
  source(file.path("projects", "hypertension_logistic_sim", "scripts", "_project_config.R"))
}

cat("=== Data Cleaning and Preprocessing (G0-4) ===\n")

raw_file <- file.path(raw_data_dir, "hypertension_sim_raw.csv")
df <- read.csv(raw_file, stringsAsFactors = FALSE)

# 1. 因子型（factor）への変換と基準水準（Reference level）の固定
df$sex <- factor(df$sex, levels = c("Female", "Male"))
df$smoking_f <- factor(df$smoking, levels = c(0, 1), labels = c("Non-smoker", "Current smoker"))
df$alcohol_f <- factor(df$alcohol, levels = c("None/Occasional", "Regular"))
df$htn_f <- factor(df$htn, levels = c(0, 1), labels = c("Normal", "Hypertension"))

# 2. 範囲・妥当性チェック
stopifnot(all(df$age >= 40 & df$age <= 75))
stopifnot(all(df$bmi >= 18.5 & df$bmi <= 35.0))
stopifnot(all(df$htn %in% c(0, 1)))

# 3. 処理済みデータの保存
rds_file <- file.path(proc_data_dir, "hypertension_cleaned.rds")
csv_file <- file.path(proc_data_dir, "hypertension_cleaned.csv")

saveRDS(df, rds_file)
write.csv(df, csv_file, row.names = FALSE)

cat(sprintf("Cleaned data saved to:\n  - RDS: %s\n  - CSV: %s\n", rds_file, csv_file))
cat("Data cleaning and factor leveling complete.\n")

