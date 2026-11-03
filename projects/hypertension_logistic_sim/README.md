# 高血圧症リスク因子評価シミュレーション研究 (hypertension_logistic_sim)

40〜75歳の成人100例を対象とした模擬臨床データを用い、生活習慣および背景因子（年齢、性別、BMI、喫煙、飲酒）が高血圧症に及ぼす影響を多変量ロジスティック回帰分析で評価するプロジェクトです。

## ディレクトリ構成

- `docs/`
  - `statistical_analysis_plan.md`: 統計解析計画書 (SAP)
  - `data_dictionary.csv`: 変数定義書 (Data Dictionary)
- `analysis_plan.md`: Gateベースの実装計画書 (G<gate>-<seq> ID体系)
- `verification_config.yml`: Stage B QA検証用設定ファイル
- `data/`
  - `raw/`: 模擬生成された原データ (`hypertension_sim_raw.csv`)
  - `processed/`: 型変換・クリーニング後データ (`hypertension_cleaned.rds`, `hypertension_cleaned.csv`)
- `scripts/`
  - `_project_config.R`: パス解決設定
  - `00_setup.R`: 環境確認
  - `00_generate_synthetic_data.R`: シミュレーションデータ生成
  - `01_data_import.R`: データインポート・整合性確認
  - `02_clean_data.R`: データクリーニング・前処理
  - `03_exploration.R`: 探索的データ可視化
  - `04_descriptive_analysis.R`: Table 1（患者背景表）作成
  - `05_primary_analysis.R`: 主解析（多変量ロジスティック回帰分析）
  - `06_sensitivity_analysis.R`: 感度分析（多重共線性・変数除外）
  - `07_exploratory_analysis.R`: 探索的層別分析（サブグループ解析）
  - `run_all.R`: 一括パイプライン実行およびQA入力出力
  - `99_verify_data.R`: Stage B 検証（QAレポート・検証レポート生成）
- `output/`
  - `figures/`: 生成された図（探索図、フォレストプロット等）
  - `tables/`: 出力テーブル（Table 1、回帰分析結果等）
  - `verification/`: 検証アーティファクト（逆翻訳・トレーサビリティ・QAレポート）
  - `analysis_report.md`: 包括的解析レポート

## 実行方法

PowerShell または R コンソールから一括実行できます：

```powershell
Rscript --vanilla projects/hypertension_logistic_sim/scripts/run_all.R
```

