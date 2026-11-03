# scripts/04_descriptive_analysis.R
# @plan_id G2A-1

# 設定読み込み
if (file.exists("scripts/_project_config.R")) {
  source("scripts/_project_config.R")
} else if (file.exists("_project_config.R")) {
  source("_project_config.R")
} else {
  source(file.path("projects", "hypertension_logistic_sim", "scripts", "_project_config.R"))
}

cat("=== Descriptive Statistics & Table 1 (G2A-1) ===\n")

rds_file <- file.path(proc_data_dir, "hypertension_cleaned.rds")
df <- readRDS(rds_file)

# Table 1 作成関数
create_table1 <- function(data) {
  g0 <- subset(data, htn == 0)
  g1 <- subset(data, htn == 1)
  
  rows <- list()
  
  # Total N
  rows[[length(rows) + 1]] <- data.frame(
    Variable = "Total N",
    Overall = as.character(nrow(data)),
    Normal = as.character(nrow(g0)),
    Hypertension = as.character(nrow(g1)),
    P_value = "-"
  )
  
  # Age (mean ± sd)
  p_age <- t.test(age ~ htn, data = data)$p.value
  rows[[length(rows) + 1]] <- data.frame(
    Variable = "Age (years), mean (SD)",
    Overall = sprintf("%.1f (%.1f)", mean(data$age), sd(data$age)),
    Normal = sprintf("%.1f (%.1f)", mean(g0$age), sd(g0$age)),
    Hypertension = sprintf("%.1f (%.1f)", mean(g1$age), sd(g1$age)),
    P_value = sprintf("%.3f", p_age)
  )
  
  # Sex (Male, n (%))
  t_sex <- table(data$sex, data$htn)
  p_sex <- chisq.test(t_sex)$p.value
  rows[[length(rows) + 1]] <- data.frame(
    Variable = "Sex (Male), n (%)",
    Overall = sprintf("%d (%.1f%%)", sum(data$sex == "Male"), mean(data$sex == "Male") * 100),
    Normal = sprintf("%d (%.1f%%)", sum(g0$sex == "Male"), mean(g0$sex == "Male") * 100),
    Hypertension = sprintf("%d (%.1f%%)", sum(g1$sex == "Male"), mean(g1$sex == "Male") * 100),
    P_value = sprintf("%.3f", p_sex)
  )
  
  # BMI (mean ± sd)
  p_bmi <- t.test(bmi ~ htn, data = data)$p.value
  rows[[length(rows) + 1]] <- data.frame(
    Variable = "BMI (kg/m^2), mean (SD)",
    Overall = sprintf("%.1f (%.1f)", mean(data$bmi), sd(data$bmi)),
    Normal = sprintf("%.1f (%.1f)", mean(g0$bmi), sd(g0$bmi)),
    Hypertension = sprintf("%.1f (%.1f)", mean(g1$bmi), sd(g1$bmi)),
    P_value = sprintf("%.3f", p_bmi)
  )
  
  # Smoking (Current, n (%))
  t_smoke <- table(data$smoking, data$htn)
  p_smoke <- chisq.test(t_smoke)$p.value
  rows[[length(rows) + 1]] <- data.frame(
    Variable = "Current Smoker, n (%)",
    Overall = sprintf("%d (%.1f%%)", sum(data$smoking == 1), mean(data$smoking == 1) * 100),
    Normal = sprintf("%d (%.1f%%)", sum(g0$smoking == 1), mean(g0$smoking == 1) * 100),
    Hypertension = sprintf("%d (%.1f%%)", sum(g1$smoking == 1), mean(g1$smoking == 1) * 100),
    P_value = sprintf("%.3f", p_smoke)
  )
  
  # Alcohol (Regular, n (%))
  t_alc <- table(data$alcohol, data$htn)
  p_alc <- chisq.test(t_alc)$p.value
  rows[[length(rows) + 1]] <- data.frame(
    Variable = "Regular Drinker, n (%)",
    Overall = sprintf("%d (%.1f%%)", sum(data$alcohol == "Regular"), mean(data$alcohol == "Regular") * 100),
    Normal = sprintf("%d (%.1f%%)", sum(g0$alcohol == "Regular"), mean(g0$alcohol == "Regular") * 100),
    Hypertension = sprintf("%d (%.1f%%)", sum(g1$alcohol == "Regular"), mean(g1$alcohol == "Regular") * 100),
    P_value = sprintf("%.3f", p_alc)
  )
  
  # SBP (mean ± sd)
  p_sbp <- t.test(sbp ~ htn, data = data)$p.value
  rows[[length(rows) + 1]] <- data.frame(
    Variable = "Systolic BP (mmHg), mean (SD)",
    Overall = sprintf("%.1f (%.1f)", mean(data$sbp), sd(data$sbp)),
    Normal = sprintf("%.1f (%.1f)", mean(g0$sbp), sd(g0$sbp)),
    Hypertension = sprintf("%.1f (%.1f)", mean(g1$sbp), sd(g1$sbp)),
    P_value = sprintf("%.3e", p_sbp)
  )
  
  # DBP (mean ± sd)
  p_dbp <- t.test(dbp ~ htn, data = data)$p.value
  rows[[length(rows) + 1]] <- data.frame(
    Variable = "Diastolic BP (mmHg), mean (SD)",
    Overall = sprintf("%.1f (%.1f)", mean(data$dbp), sd(data$dbp)),
    Normal = sprintf("%.1f (%.1f)", mean(g0$dbp), sd(g0$dbp)),
    Hypertension = sprintf("%.1f (%.1f)", mean(g1$dbp), sd(g1$dbp)),
    P_value = sprintf("%.3e", p_dbp)
  )
  
  do.call(rbind, rows)
}

t1 <- create_table1(df)
t1_file <- file.path(tables_dir, "table1_baseline.csv")
write.csv(t1, t1_file, row.names = FALSE)

cat(sprintf("Table 1 saved to: %s\n", t1_file))
print(t1)
cat("Descriptive analysis complete.\n")

