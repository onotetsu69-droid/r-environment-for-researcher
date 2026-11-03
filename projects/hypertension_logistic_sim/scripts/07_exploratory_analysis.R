# scripts/07_exploratory_analysis.R
# @plan_id G2D-1

# 設定読み込み
if (file.exists("scripts/_project_config.R")) {
  source("scripts/_project_config.R")
} else if (file.exists("_project_config.R")) {
  source("_project_config.R")
} else {
  source(file.path("projects", "hypertension_logistic_sim", "scripts", "_project_config.R"))
}

cat("=== Exploratory Subgroup Analysis by Sex (G2D-1) ===\n")

rds_file <- file.path(proc_data_dir, "hypertension_cleaned.rds")
df <- readRDS(rds_file)

# 性別（Male / Female）別の層別モデル
sub_results <- list()

for (s in c("Female", "Male")) {
  sub_df <- subset(df, sex == s)
  n_sub <- nrow(sub_df)
  n_events <- sum(sub_df$htn == 1)
  
  # 年齢・BMI・喫煙・飲酒
  # イベント数が十分かチェック
  if (n_events >= 5 && (n_sub - n_events) >= 5) {
    m_sub <- glm(htn ~ age + bmi + smoking + alcohol, data = sub_df, family = binomial)
    sm_sub <- summary(m_sub)
    cfs <- sm_sub$coefficients
    ci <- exp(confint.default(m_sub))
    
    for (r in 2:nrow(cfs)) {
      sub_results[[length(sub_results) + 1]] <- data.frame(
        Subgroup = s,
        N = n_sub,
        Events = n_events,
        Variable = rownames(cfs)[r],
        OR = exp(cfs[r, 1]),
        CI_lower = ci[r, 1],
        CI_upper = ci[r, 2],
        P_value = cfs[r, 4],
        stringsAsFactors = FALSE
      )
    }
  }
}

sub_res_df <- do.call(rbind, sub_results)
sub_file <- file.path(tables_dir, "subgroup_by_sex.csv")
write.csv(sub_res_df, sub_file, row.names = FALSE)

cat(sprintf("Subgroup analysis saved to: %s\n", sub_file))
print(sub_res_df[, c("Subgroup", "N", "Events", "Variable", "OR", "P_value")])

cat("Exploratory analysis complete.\n")

