# scripts/00_setup.R
# @plan_id G0-1

# 設定読み込み
if (file.exists("scripts/_project_config.R")) {
  source("scripts/_project_config.R")
} else if (file.exists("_project_config.R")) {
  source("_project_config.R")
} else {
  source(file.path("projects", "hypertension_logistic_sim", "scripts", "_project_config.R"))
}

cat("=== Environment Setup (G0-1) ===\n")
cat(sprintf("Project Root: %s\n", project_root))
cat(sprintf("R Version: %s\n", R.version.string))
cat(sprintf("Platform: %s\n", R.version$platform))

# 必要なディレクトリの作成担保
dirs_to_ensure <- c(raw_data_dir, proc_data_dir, tables_dir, figures_dir, verify_dir)
for (d in dirs_to_ensure) {
  if (!dir.exists(d)) {
    dir.create(d, recursive = TRUE, showWarnings = FALSE)
  }
}
cat("Directory structure verified.\n")
cat("Setup complete.\n")

