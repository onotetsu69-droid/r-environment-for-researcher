# Implementation Analysis Plan: 高血圧症リスク因子評価シミュレーション研究

本計画書は、承認された SAP (`docs/statistical_analysis_plan.md`) を実行可能な Gate ベースの実装タスクに変換した契約書である。すべてのコード実装は対応する `@plan_id` を明記して追跡される。

---

## Gate 概要一覧

| Gate ID | 名称 | 主な成果物 | 承認ステータス |
|---|---|---|---|
| `G0-1` | 実行環境とパス解決の確認 | `scripts/_project_config.R`, `scripts/00_setup.R` | ✅ Approved |
| `G0-2` | 模擬データの生成（N=100） | `scripts/00_generate_synthetic_data.R`, `data/raw/` | ✅ Approved |
| `G0-3` | データのインポートと完全性確認 | `scripts/01_data_import.R` | ✅ Approved |
| `G0-4` | データ型の整形と参照水準固定 | `scripts/02_clean_data.R`, `data/processed/` | ✅ Approved |
| `G1-1` | 変数の分布と要約可視化 | `scripts/03_exploration.R`, `output/figures/` | ✅ Approved |
| `G1-2` | 共変量間の相関・関連確認 | `scripts/03_exploration.R` | ✅ Approved |
| `G2A-1` | Table 1（高血圧有無別患者背景表） | `scripts/04_descriptive_analysis.R`, `output/tables/` | ✅ Approved |
| `G2B-1` | 多変量ロジスティック回帰（Primary） | `scripts/05_primary_analysis.R`, `output/tables/` | ✅ Approved |
| `G2B-2` | 単変量ロジスティック回帰（Secondary） | `scripts/05_primary_analysis.R` | ✅ Approved |
| `G2C-1` | 多重共線性（VIF）および感度分析 | `scripts/06_sensitivity_analysis.R` | ✅ Approved |
| `G2D-1` | 性別による層別探索的分析 | `scripts/07_exploratory_analysis.R` | ✅ Approved |

---

## Phase 0: Data Preparation

### Gate 0A: Environment Setup
- **`G0-1`**: 環境確認とポータブルパス設定
  - **Owner**: AI / Researcher
  - **Inputs**: R runtime
  - **Outputs**: `_project_config.R`, `00_setup.R`
  - **Fallback**: パスエラー時は `here::here()` およびプロジェクト相対パスへフォールバック
- **`G0-2`**: 100例の臨床模擬データ生成
  - **Owner**: AI
  - **Inputs**: `seed = 20261103`, 臨床パラメータ設定
  - **Outputs**: `data/raw/hypertension_sim_raw.csv`
  - **Fallback**: シード不整合時は乱数再シミュレーション

### Gate 0B: Data Cleaning Plan
- **`G0-3`**: 生データのインポートと整合性確認
  - **Owner**: AI
  - **Inputs**: `data/raw/hypertension_sim_raw.csv`
  - **Outputs**: レコード数（N=100）、列数（9列）、欠測率（0%）の検証
  - **Fallback**: レコード数不一致時は生成スクリプト再実行
- **`G0-4`**: データ型の確定とファクター参照水準の明示化
  - **Owner**: AI
  - **Inputs**: インポート済みデータ
  - **Outputs**: `data/processed/hypertension_cleaned.rds`, `hypertension_cleaned.csv`
  - **Fallback**: 不正な値の検出時はデータクリーニングルールを再設定

---

## Phase 1: Data Exploration

### Gate 1: Exploration
- **`G1-1`**: 主要連続変数の分布確認（年齢・BMI・SBP・DBP）
  - **Owner**: AI
  - **Inputs**: クリーニング済みデータ
  - **Outputs**: ヒストグラム・密度プロット
- **`G1-2`**: 高血圧の有無別の変数比較プロット
  - **Owner**: AI
  - **Inputs**: クリーニング済みデータ
  - **Outputs**: 箱ひげ図（Boxplot）

---

## Phase 2: Data Analyses

### Gate 2A: Descriptive Statistics Plan
- **`G2A-1`**: Table 1（全体および高血圧有無別の背景特性表）
  - **Owner**: AI
  - **Inputs**: クリーニング済みデータ
  - **Outputs**: `output/tables/table1_baseline.csv`
  - **仕様**: 連続変数は平均値±SD、カテゴリ変数は $n$ (%)、群間比較 $P$ 値を併記。

### Gate 2B: Main Analysis Plan
- **`G2B-1`**: 多変量ロジスティック回帰モデル（Primary Analysis）
  - **Owner**: AI
  - **Inputs**: クリーニング済みデータ
  - **モデル式**: `htn ~ age + sex + bmi + smoking + alcohol`
  - **Outputs**: `output/tables/primary_logistic_regression.csv`, 回帰係数・調整OR・95%CI・P値
- **`G2B-2`**: 単変量ロジスティック回帰モデル（Secondary Analysis）
  - **Owner**: AI
  - **Inputs**: クリーニング済みデータ
  - **Outputs**: `output/tables/unadjusted_logistic_regression.csv`, 粗ORと調整ORの比較表

#### Assumption Checks Agreement
| ID | Model | Check | Required / Recommended | Trigger | Fail Action |
|---|---|---|---|---|---|
| `G2B-1` | logistic_regression | sample_events | Required | イベント数 < 10 または 非イベント数 < 10 | モデルの共変量数を削減 |
| `G2B-1` | logistic_regression | complete_convergence | Required | 回帰係数 SE > 10 (完全分離の疑い) | ペナルティ付き回帰（Firth法等）へ移行 |
| `G2C-1` | logistic_regression | vif_multicollinearity | Recommended | VIF > 5 | 相関の高い変数を特定しモデル修正 |

### Gate 2C: Sensitivity Analysis Plan
- **`G2C-1`**: 共変量変更および非線形性検討
  - **Owner**: AI
  - **Inputs**: クリーニング済みデータ
  - **Outputs**: `output/tables/sensitivity_analysis.csv`
  - **内容**: 飲酒を除外したモデルおよびBMI二乗項を投入したモデルのOR比較。

### Gate 2D: Exploratory Analysis Plan
- **`G2D-1`**: 性別（男性・女性）による層別オッズ比の比較
  - **Owner**: AI
  - **Inputs**: クリーニング済みデータ
  - **Outputs**: `output/tables/subgroup_by_sex.csv`

