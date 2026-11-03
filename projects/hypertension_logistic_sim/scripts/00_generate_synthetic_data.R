# scripts/00_generate_synthetic_data.R
# @plan_id G0-2

# 設定読み込み
if (file.exists("scripts/_project_config.R")) {
  source("scripts/_project_config.R")
} else if (file.exists("_project_config.R")) {
  source("_project_config.R")
} else {
  source(file.path("projects", "hypertension_logistic_sim", "scripts", "_project_config.R"))
}

cat("=== Generating Synthetic Data (G0-2) ===\n")

# 再現性確保のための乱数シード設定
set.seed(20261103)
n <- 100

# 1. 背景因子（共変量）の生成
# 年齢: 40〜75歳、平均56歳、SD 9歳
age <- round(pmin(pmax(rnorm(n, mean = 56, sd = 9), 40), 75))

# 性別: 女性 48%, 男性 52%
sex <- sample(c("Female", "Male"), size = n, replace = TRUE, prob = c(0.48, 0.52))
male_dummy <- as.integer(sex == "Male")

# BMI: 18.5〜35.0 kg/m^2、平均 24.2、SD 3.2
bmi <- round(pmin(pmax(rnorm(n, mean = 24.2, sd = 3.2), 18.5), 35.0), 1)

# 現在喫煙: 男性 30%, 女性 15%
smoking <- rbinom(n, 1, prob = ifelse(male_dummy == 1, 0.30, 0.15))

# 飲酒習慣: Regular 45%, None/Occasional 55%
alcohol <- sample(c("None/Occasional", "Regular"), size = n, replace = TRUE, prob = c(0.55, 0.45))
regular_alc <- as.integer(alcohol == "Regular")

# 2. アウトカム（高血圧症）の生成（ロジットモデル）
logit_p <- -0.8 + 0.05 * (age - 55) + 0.6 * male_dummy + 0.18 * (bmi - 24) + 0.7 * smoking + 0.3 * regular_alc
prob <- 1 / (1 + exp(-logit_p))
htn <- rbinom(n, 1, prob)

# 3. 測定値（血圧実測値）の生成
sbp <- round(ifelse(htn == 1, rnorm(n, 146, 8), rnorm(n, 122, 7)))
dbp <- round(ifelse(htn == 1, rnorm(n, 93, 6), rnorm(n, 76, 5)))

# データフレーム構築
df_raw <- data.frame(
  patient_id = 1:n,
  age        = age,
  sex        = sex,
  bmi        = bmi,
  smoking    = smoking,
  alcohol    = alcohol,
  sbp        = sbp,
  dbp        = dbp,
  htn        = htn,
  stringsAsFactors = FALSE
)

# CSVファイルへ出力
out_file <- file.path(raw_data_dir, "hypertension_sim_raw.csv")
write.csv(df_raw, out_file, row.names = FALSE)

cat(sprintf("Generated synthetic dataset with %d rows and %d columns.\n", nrow(df_raw), ncol(df_raw)))
cat(sprintf("Hypertension cases: %d (%.1f%%)\n", sum(df_raw$htn), mean(df_raw$htn) * 100))
cat(sprintf("Raw data saved to: %s\n", out_file))
