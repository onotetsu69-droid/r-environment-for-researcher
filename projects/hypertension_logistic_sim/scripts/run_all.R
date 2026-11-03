# scripts/run_all.R
# 全パイプラインの実行と検証アーティファクトの生成

if (file.exists("scripts/_project_config.R")) {
  source("scripts/_project_config.R")
} else if (file.exists("_project_config.R")) {
  source("_project_config.R")
} else {
  source(file.path("projects", "hypertension_logistic_sim", "scripts", "_project_config.R"))
}

cat("=================================================================\n")
cat("Starting Full Execution Pipeline for hypertension_logistic_sim\n")
cat("=================================================================\n")

scripts_to_run <- c(
  "00_setup.R",
  "00_generate_synthetic_data.R",
  "01_data_import.R",
  "02_clean_data.R",
  "03_exploration.R",
  "04_descriptive_analysis.R",
  "05_primary_analysis.R",
  "06_sensitivity_analysis.R",
  "07_exploratory_analysis.R"
)

for (s in scripts_to_run) {
  script_path <- file.path(scripts_dir, s)
  cat(sprintf("\n>>> Executing %s ...\n", s))
  source(script_path)
}

cat("\n=================================================================\n")
cat("All analysis scripts completed successfully.\n")
cat("Generating qa_inputs.json for Stage B Verification ...\n")
cat("=================================================================\n")

# 実測値の読み込み
raw_df <- read.csv(file.path(raw_data_dir, "hypertension_sim_raw.csv"))
primary_res <- read.csv(file.path(tables_dir, "primary_logistic_regression.csv"))
vif_res <- read.csv(file.path(tables_dir, "vif_multicollinearity.csv"))

n_total <- nrow(raw_df)
n_events <- sum(raw_df$htn == 1)
n_nonevents <- n_total - n_events

age_or <- primary_res$OR[primary_res$Variable == "age"]
male_or <- primary_res$OR[primary_res$Variable == "sexMale"]
smoking_or <- primary_res$OR[primary_res$Variable == "smoking"]
max_se <- max(primary_res$SE[primary_res$Variable != "(Intercept)"])
max_vif <- max(vif_res$VIF)

# jsonlite があれば使用、なければ base R で整形
qa_data <- list(
  key_results = list(
    list(id = "G0-3", metric = "n_total", value = n_total),
    list(id = "G0-3", metric = "n_events", value = n_events),
    list(id = "G2B-1", metric = "age_or", value = round(age_or, 3)),
    list(id = "G2B-1", metric = "smoking_or", value = round(smoking_or, 3)),
    list(id = "G2B-1", metric = "male_or", value = round(male_or, 3))
  ),
  assumption_checks = list(
    list(
      id = "G2B-1",
      model = "logistic_regression",
      check = "sample_events",
      required = TRUE,
      result = sprintf("events = %d, non-events = %d (both >= 10)", n_events, n_nonevents),
      status = if (n_events >= 10 && n_nonevents >= 10) "pass" else "fail"
    ),
    list(
      id = "G2B-1",
      model = "logistic_regression",
      check = "complete_convergence",
      required = TRUE,
      result = sprintf("max SE = %.2f < 10 (no complete separation)", max_se),
      status = if (max_se < 10) "pass" else "fail"
    ),
    list(
      id = "G2C-1",
      model = "logistic_regression",
      check = "vif_multicollinearity",
      required = FALSE,
      result = sprintf("max VIF = %.2f < 5.0", max_vif),
      status = if (max_vif < 5.0) "pass" else "fail"
    )
  )
)

qa_json_file <- file.path(verify_dir, "qa_inputs.json")

# 手動JSONシリアライザ（外部依存なし）
format_json <- function(obj) {
  kr_json <- sapply(obj$key_results, function(x) {
    sprintf('    {"id": "%s", "metric": "%s", "value": %s}', x$id, x$metric, as.character(x$value))
  })
  
  ac_json <- sapply(obj$assumption_checks, function(x) {
    sprintf('    {"id": "%s", "model": "%s", "check": "%s", "required": %s, "result": "%s", "status": "%s"}',
            x$id, x$model, x$check, tolower(as.character(x$required)), x$result, x$status)
  })
  
  paste0(
    "{\n",
    '  "key_results": [\n', paste(kr_json, collapse = ",\n"), "\n  ],\n",
    '  "assumption_checks": [\n', paste(ac_json, collapse = ",\n"), "\n  ]\n",
    "}\n"
  )
}

writeLines(format_json(qa_data), qa_json_file)
cat(sprintf("qa_inputs.json successfully written to: %s\n", qa_json_file))

# Stage B: 99_verify_data.R の呼び出し
cat("\n>>> Running Stage B Verification: 99_verify_data.R ...\n")
source(file.path(scripts_dir, "99_verify_data.R"))

cat("\n=================================================================\n")
cat("Pipeline and Verification Run Completed!\n")
cat("=================================================================\n")

