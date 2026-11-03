# scripts/05_primary_analysis.R
# @plan_id G2B-1
# @plan_id G2B-2

# 設定読み込み
if (file.exists("scripts/_project_config.R")) {
  source("scripts/_project_config.R")
} else if (file.exists("_project_config.R")) {
  source("_project_config.R")
} else {
  source(file.path("projects", "hypertension_logistic_sim", "scripts", "_project_config.R"))
}

cat("=== Primary and Secondary Logistic Regression (G2B-1, G2B-2) ===\n")

rds_file <- file.path(proc_data_dir, "hypertension_cleaned.rds")
df <- readRDS(rds_file)

# ==============================================================================
# @plan_id G2B-1: 多変量ロジスティック回帰分析（Primary Analysis）
# ==============================================================================
cat("\n--- Running Multivariable Logistic Regression (Primary) ---\n")
model_multi <- glm(htn ~ age + sex + bmi + smoking + alcohol, data = df, family = binomial(link = "logit"))

# 回帰サマリーと係数
sm_multi <- summary(model_multi)
coefs_multi <- sm_multi$coefficients
or_multi <- exp(coefs_multi[, 1])
ci_multi <- exp(confint.default(model_multi))

primary_res <- data.frame(
  Variable = rownames(coefs_multi),
  Estimate = coefs_multi[, 1],
  SE = coefs_multi[, 2],
  z_value = coefs_multi[, 3],
  P_value = coefs_multi[, 4],
  OR = or_multi,
  CI_lower = ci_multi[, 1],
  CI_upper = ci_multi[, 2],
  stringsAsFactors = FALSE
)

# 表示用フォーマット
primary_res_formatted <- data.frame(
  Variable = primary_res$Variable,
  Adjusted_OR = sprintf("%.3f", primary_res$OR),
  `95% CI` = sprintf("[%.3f, %.3f]", primary_res$CI_lower, primary_res$CI_upper),
  P_value = sprintf("%.4f", primary_res$P_value),
  stringsAsFactors = FALSE,
  check.names = FALSE
)

out_primary <- file.path(tables_dir, "primary_logistic_regression.csv")
write.csv(primary_res, out_primary, row.names = FALSE)
cat(sprintf("Primary multivariable results saved to: %s\n", out_primary))
print(primary_res_formatted)

# ==============================================================================
# @plan_id G2B-2: 単変量ロジスティック回帰分析（Secondary Analysis）
# ==============================================================================
cat("\n--- Running Univariable Logistic Regression (Secondary) ---\n")
vars <- c("age", "sex", "bmi", "smoking", "alcohol")
unadj_list <- list()

for (v in vars) {
  f <- as.formula(paste("htn ~", v))
  m <- glm(f, data = df, family = binomial)
  sm <- summary(m)
  cfs <- sm$coefficients
  ci <- exp(confint.default(m))
  
  # 切片以外の係数を取得
  target_rows <- 2:nrow(cfs)
  for (r in target_rows) {
    unadj_list[[length(unadj_list) + 1]] <- data.frame(
      Variable = rownames(cfs)[r],
      Crude_OR = exp(cfs[r, 1]),
      CI_lower = ci[r, 1],
      CI_upper = ci[r, 2],
      P_value = cfs[r, 4],
      stringsAsFactors = FALSE
    )
  }
}
unadj_res <- do.call(rbind, unadj_list)
out_unadj <- file.path(tables_dir, "unadjusted_logistic_regression.csv")
write.csv(unadj_res, out_unadj, row.names = FALSE)
cat(sprintf("Unadjusted univariable results saved to: %s\n", out_unadj))

# 粗ORと調整ORの比較テーブル作成
comp_df <- data.frame(
  Variable = unadj_res$Variable,
  Crude_OR_CI = sprintf("%.3f [%.3f, %.3f] (P=%.4f)", unadj_res$Crude_OR, unadj_res$CI_lower, unadj_res$CI_upper, unadj_res$P_value),
  stringsAsFactors = FALSE
)
# primary_res と結合（切片除外）
primary_no_int <- subset(primary_res, Variable != "(Intercept)")
merged_comp <- merge(unadj_res[, c("Variable", "Crude_OR", "CI_lower", "CI_upper", "P_value")],
                     primary_no_int[, c("Variable", "OR", "CI_lower", "CI_upper", "P_value")],
                     by = "Variable", suffixes = c("_Crude", "_Adjusted"))

out_comp <- file.path(tables_dir, "comparison_unadjusted_adjusted.csv")
write.csv(merged_comp, out_comp, row.names = FALSE)
cat(sprintf("Comparison table saved to: %s\n", out_comp))

# ==============================================================================
# フォレストプロットの生成 (Forest Plot)
# ==============================================================================
forest_file <- file.path(figures_dir, "forest_plot_or.png")
png(forest_file, width = 800, height = 500, res = 120)

plot_vars <- subset(primary_res, Variable != "(Intercept)")
n_p <- nrow(plot_vars)
y_pos <- n_p:1
var_labels <- c("Age (per year)", "Sex (Male vs Female)", "BMI (per kg/m^2)", "Smoking (Current vs Non)", "Alcohol (Regular vs Occasional)")

par(mar = c(5, 12, 3, 2))
plot(plot_vars$OR, y_pos, pch = 16, col = "navy", cex = 1.4,
     xlim = c(0.2, 10), log = "x",
     yaxt = "n", xlab = "Adjusted Odds Ratio (log scale)", ylab = "",
     main = "Multivariable Adjusted Odds Ratios for Hypertension")
axis(2, at = y_pos, labels = var_labels, las = 2, cex.axis = 0.9)
abline(v = 1, lty = 2, col = "gray40", lwd = 1.2)

# エラーバー（95% CI）
for (i in 1:n_p) {
  arrows(plot_vars$CI_lower[i], y_pos[i], plot_vars$CI_upper[i], y_pos[i],
         length = 0.05, angle = 90, code = 3, col = "navy", lwd = 1.5)
}
dev.off()
cat(sprintf("Forest plot saved to: %s\n", forest_file))

cat("Primary and secondary analysis complete.\n")

