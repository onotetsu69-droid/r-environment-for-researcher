# scripts/06_sensitivity_analysis.R
# @plan_id G2C-1

# 設定読み込み
if (file.exists("scripts/_project_config.R")) {
  source("scripts/_project_config.R")
} else if (file.exists("_project_config.R")) {
  source("_project_config.R")
} else {
  source(file.path("projects", "hypertension_logistic_sim", "scripts", "_project_config.R"))
}

cat("=== Sensitivity Analysis & Collinearity Check (G2C-1) ===\n")

rds_file <- file.path(proc_data_dir, "hypertension_cleaned.rds")
df <- readRDS(rds_file)

# 1. 多重共線性（VIF）の計算（base R 実装）
# 線形近似に基づく各説明変数の R^2 から VIF を算出
calc_vif <- function(data, vars) {
  vifs <- numeric(length(vars))
  names(vifs) <- vars
  for (i in seq_along(vars)) {
    y_var <- vars[i]
    x_vars <- vars[-i]
    formula_str <- paste(y_var, "~", paste(x_vars, collapse = " + "))
    fit <- lm(as.formula(formula_str), data = data)
    r2 <- summary(fit)$r.squared
    vifs[i] <- 1 / (1 - r2)
  }
  return(vifs)
}

num_vars <- c("age", "bmi", "smoking")
# カテゴリ変数ダミーを含めたVIF計算用データ
df_vif <- df
df_vif$male_dummy <- as.integer(df$sex == "Male")
df_vif$alc_dummy <- as.integer(df$alcohol == "Regular")
vif_vars <- c("age", "male_dummy", "bmi", "smoking", "alc_dummy")

vif_vals <- calc_vif(df_vif, vif_vars)
vif_df <- data.frame(
  Variable = c("Age", "Male Sex", "BMI", "Smoking", "Regular Alcohol"),
  VIF = vif_vals,
  Max_VIF_Threshold = 5.0,
  Pass = vif_vals < 5.0,
  stringsAsFactors = FALSE
)

vif_file <- file.path(tables_dir, "vif_multicollinearity.csv")
write.csv(vif_df, vif_file, row.names = FALSE)
cat("Multicollinearity VIF check:\n")
print(vif_df)

# 2. 感度分析 1: 飲酒習慣を除外したモデル
m_sens1 <- glm(htn ~ age + sex + bmi + smoking, data = df, family = binomial)
ci_sens1 <- exp(confint.default(m_sens1))
coef_sens1 <- summary(m_sens1)$coefficients

sens1_df <- data.frame(
  Model = "Without Alcohol",
  Variable = rownames(coef_sens1),
  OR = exp(coef_sens1[, 1]),
  CI_lower = ci_sens1[, 1],
  CI_upper = ci_sens1[, 2],
  P_value = coef_sens1[, 4],
  stringsAsFactors = FALSE
)

# 3. 感度分析 2: BMIの非線形性（BMI^2）を投入したモデル
df$bmi_sq <- (df$bmi - mean(df$bmi))^2
m_sens2 <- glm(htn ~ age + sex + bmi + bmi_sq + smoking + alcohol, data = df, family = binomial)
ci_sens2 <- exp(confint.default(m_sens2))
coef_sens2 <- summary(m_sens2)$coefficients

sens2_df <- data.frame(
  Model = "With BMI Quadratic Term",
  Variable = rownames(coef_sens2),
  OR = exp(coef_sens2[, 1]),
  CI_lower = ci_sens2[, 1],
  CI_upper = ci_sens2[, 2],
  P_value = coef_sens2[, 4],
  stringsAsFactors = FALSE
)

sens_all <- rbind(sens1_df, sens2_df)
sens_file <- file.path(tables_dir, "sensitivity_analysis.csv")
write.csv(sens_all, sens_file, row.names = FALSE)

cat(sprintf("Sensitivity analysis results saved to: %s\n", sens_file))
cat("Sensitivity analysis complete.\n")

