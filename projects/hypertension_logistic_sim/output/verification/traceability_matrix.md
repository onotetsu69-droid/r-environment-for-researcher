# Traceability Matrix: hypertension_logistic_sim

本ドキュメントは、実装計画書 (`analysis_plan.md`) の各 Gate ID と、実装スクリプト内のコード行範囲のマッピングを示すトレーサビリティ表である。

| Plan ID | Plan Description | Script | Line Range | Status |
|---|---|---|---|---|
| `G0-1` | 実行環境とパス解決の確認 | `00_setup.R` | L1-L25 | ✅ Implemented |
| `G0-2` | 模擬データの生成（N=100） | `00_generate_synthetic_data.R` | L1-L62 | ✅ Implemented |
| `G0-3` | データのインポートと完全性確認 | `01_data_import.R` | L1-L41 | ✅ Implemented |
| `G0-4` | データ型の整形と参照水準固定 | `02_clean_data.R` | L1-L35 | ✅ Implemented |
| `G1-1` | 変数の分布と要約可視化 | `03_exploration.R` | L19-L30 | ✅ Implemented |
| `G1-2` | 高血圧有無別の変数比較プロット | `03_exploration.R` | L31-L41 | ✅ Implemented |
| `G2A-1` | Table 1（高血圧有無別患者背景表） | `04_descriptive_analysis.R` | L1-L116 | ✅ Implemented |
| `G2B-1` | 多変量ロジスティック回帰（Primary） | `05_primary_analysis.R` | L20-L58 | ✅ Implemented |
| `G2B-2` | 単変量ロジスティック回帰（Secondary） | `05_primary_analysis.R` | L59-L98 | ✅ Implemented |
| `G2C-1` | 多重共線性（VIF）および感度分析 | `06_sensitivity_analysis.R` | L1-L90 | ✅ Implemented |
| `G2D-1` | 性別による層別探索的分析 | `07_exploratory_analysis.R` | L1-L56 | ✅ Implemented |

---
- **Total Planned Items**: 11
- **Implemented Items**: 11 (100%)
- **Unimplemented Items**: 0

