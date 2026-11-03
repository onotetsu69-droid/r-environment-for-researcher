# scripts/_project_config.R
# パス定義のみ、パッケージ読込・インストールなし（副作用なし）

# プロジェクトルートの動的解決
get_project_root <- function() {
  # 1. カレントディレクトリが projects/hypertension_logistic_sim の場合
  if (file.exists("analysis_plan.md") && file.exists("scripts/_project_config.R")) {
    return(normalizePath(".", winslash = "/"))
  }
  # 2. リポジトリ直下の場合
  if (dir.exists("projects/hypertension_logistic_sim")) {
    return(normalizePath("projects/hypertension_logistic_sim", winslash = "/"))
  }
  # 3. scripts フォルダ内にいる場合
  if (file.exists("../analysis_plan.md")) {
    return(normalizePath("..", winslash = "/"))
  }
  # フォールバック
  return(normalizePath(".", winslash = "/"))
}

project_root <- get_project_root()
data_dir     <- file.path(project_root, "data")
raw_data_dir <- file.path(data_dir, "raw")
proc_data_dir<- file.path(data_dir, "processed")
docs_dir     <- file.path(project_root, "docs")
scripts_dir  <- file.path(project_root, "scripts")
output_dir   <- file.path(project_root, "output")
tables_dir   <- file.path(output_dir, "tables")
figures_dir  <- file.path(output_dir, "figures")
verify_dir   <- file.path(output_dir, "verification")

