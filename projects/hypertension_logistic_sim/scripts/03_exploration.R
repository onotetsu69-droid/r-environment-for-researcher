# scripts/03_exploration.R
# @plan_id G1-1
# @plan_id G1-2

# 設定読み込み
if (file.exists("scripts/_project_config.R")) {
  source("scripts/_project_config.R")
} else if (file.exists("_project_config.R")) {
  source("_project_config.R")
} else {
  source(file.path("projects", "hypertension_logistic_sim", "scripts", "_project_config.R"))
}

cat("=== Exploratory Data Analysis (G1-1, G1-2) ===\n")

rds_file <- file.path(proc_data_dir, "hypertension_cleaned.rds")
df <- readRDS(rds_file)

# @plan_id G1-1
# 図1: 主要連続変数の分布確認
fig1_path <- file.path(figures_dir, "fig1_distributions.png")
png(fig1_path, width = 900, height = 700, res = 120)
par(mfrow = c(2, 2), mar = c(4, 4, 2.5, 1))
hist(df$age, col = "skyblue", main = "Age Distribution", xlab = "Age (years)", breaks = 12)
hist(df$bmi, col = "lightgreen", main = "BMI Distribution", xlab = "BMI (kg/m^2)", breaks = 12)
hist(df$sbp, col = "salmon", main = "SBP Distribution", xlab = "SBP (mmHg)", breaks = 12)
hist(df$dbp, col = "orchid", main = "DBP Distribution", xlab = "DBP (mmHg)", breaks = 12)
dev.off()
cat(sprintf("Generated distribution plot: %s\n", fig1_path))

# @plan_id G1-2
# 図2: 高血圧有無別の比較プロット（箱ひげ図）
fig2_path <- file.path(figures_dir, "fig2_boxplots_by_htn.png")
png(fig2_path, width = 800, height = 450, res = 120)
par(mfrow = c(1, 2), mar = c(4, 4, 2.5, 1))
boxplot(age ~ htn_f, data = df, col = c("lightcyan", "lightpink"),
        main = "Age by HTN Status", xlab = "HTN Status", ylab = "Age (years)")
boxplot(bmi ~ htn_f, data = df, col = c("lightcyan", "lightpink"),
        main = "BMI by HTN Status", xlab = "HTN Status", ylab = "BMI (kg/m^2)")
dev.off()
cat(sprintf("Generated boxplots by HTN status: %s\n", fig2_path))

cat("Exploratory analysis complete.\n")

