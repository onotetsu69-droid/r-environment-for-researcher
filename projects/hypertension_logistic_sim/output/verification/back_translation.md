# Back-Translation Report (逆翻訳レポート): hypertension_logistic_sim

本ドキュメントは、実装スクリプトの各処理内容を自然言語へ再翻訳した検証レポートである。医学研究者がコードを直接一行ずつ読まなくとも、統計的意図が正確に実装されているかを確認できるように設計されている。

---

## 1. 環境設定とデータ生成 (`00_setup.R`, `00_generate_synthetic_data.R`)

### `G0-1`: 実行環境とパス解決の確認
- プロジェクトのルートディレクトリを動的に解決し、`data/`, `output/tables/`, `output/figures/`, `output/verification/` の存在を確認・自動作成する。
- 実行時の R バージョンおよびプラットフォーム情報をコンソールに記録する。

### `G0-2`: 模擬データの生成（N=100）
- 再現性のために乱数シード `20261103` を固定。
- 年齢（40〜75歳、平均56歳）、性別（女性48%、男性52%）、BMI（18.5〜35.0、平均24.2）、喫煙、飲酒をシミュレーション。
- 高血圧症の確率を多変量ロジットモデルに基づいて決定し、43件の高血圧イベント（有病率43%）を生成。
- 実測血圧（SBP, DBP）を高血圧群・正常群それぞれの正規分布から生成し、CSVファイル `data/raw/hypertension_sim_raw.csv` に保存。

---

## 2. データインポートとクリーニング (`01_data_import.R`, `02_clean_data.R`)

### `G0-3`: データインポートと完全性確認
- 生データを読み込み、行数が100件、列数が9列であることをアサーション検証（不一致時は停止）。
- 欠測値（NA）の合計が0件であることを確認。
- 高血圧イベント数が43件であることを検証。

### `G0-4`: データ型の確定とファクター参照水準の明示化
- カテゴリ変数を `factor` 型へ変換。
  - `sex`: 基準 = "Female"（女性）, 比較 = "Male"（男性）
  - `smoking_f`: 基準 = "Non-smoker"（非喫煙）, 比較 = "Current smoker"（喫煙）
  - `alcohol_f`: 基準 = "None/Occasional", 比較 = "Regular"
  - `htn_f`: 基準 = "Normal", 比較 = "Hypertension"
- 年齢およびBMIが妥当な臨床範囲内にあることをアサーション検証し、`data/processed/` に保存。

---

## 3. 探索的データ解析 (`03_exploration.R`)

### `G1-1`: 変数の分布と要約可視化
- 年齢、BMI、収縮期血圧、拡張期血圧の各ヒストグラムを描画し、外れ値や歪みの有無を確認。`output/figures/fig1_distributions.png` に出力。

### `G1-2`: 高血圧有無別の変数比較プロット
- 正常群と高血圧群における年齢およびBMIの分布を箱ひげ図で並列比較。`output/figures/fig2_boxplots_by_htn.png` に出力。

---

## 4. 記述統計と Table 1 (`04_descriptive_analysis.R`)

### `G2A-1`: Table 1（患者背景表）
- 全体（N=100）、正常群（N=57）、高血圧群（N=43）の3列で要約統計量を算出。
- 連続変数（年齢、BMI、SBP、DBP）は平均値（標準偏差 SD）を記載し、両側 Student t検定のP値を付与。
- カテゴリ変数（性別、喫煙、飲酒）は人数および割合 $n$ (%) を記載し、カイ二乗検定のP値を付与。
- 結果を `output/tables/table1_baseline.csv` に保存。

---

## 5. ロジスティック回帰分析 (`05_primary_analysis.R`)

### `G2B-1`: 多変量ロジスティック回帰（Primary Analysis）
- 目的変数：`htn`（高血圧症 0/1）
- 説明変数：`age`（年齢）, `sex`（性別）, `bmi`（BMI）, `smoking`（喫煙）, `alcohol`（飲酒）
- 二項分布・ロジットリンク（`family = binomial(link = "logit")`）による最尤推定を実施。
- 回帰係数から指数変換（`exp()`）により調整オッズ比（Adjusted OR）およびプロファイル・ロバスト95%信頼区間を算出。
- 結果を `output/tables/primary_logistic_regression.csv` に出力し、グラフィカルなフォレストプロットを `output/figures/forest_plot_or.png` に生成。

### `G2B-2`: 単変量ロジスティック回帰（Secondary Analysis）
- 各説明変数を単独で投入したモデルを推定し、粗オッズ比（Crude OR）を算出。
- 粗オッズ比と調整オッズ比の対比テーブル `output/tables/comparison_unadjusted_adjusted.csv` を作成。

---

## 6. 感度分析と仮定検証 (`06_sensitivity_analysis.R`, `07_exploratory_analysis.R`)

### `G2C-1`: 多重共線性（VIF）および感度分析
- 全説明変数間の多重共線性を分散拡大係数（VIF）により診断し、すべてが閾値 5.0 未満（最大約 1.1）であることを確認。
- 飲酒習慣を除外した縮小モデル、および BMI の二乗項（非線形性）を投入したモデルにおける主要オッズ比の安定性を比較検証。

### `G2D-1`: 性別による層別探索的分析
- 男性群（N=52）と女性群（N=48）に分割し、それぞれのサブグループ内で多変量ロジスティック回帰を実行。
- オッズ比の方向性・大きさを比較し、結果を `output/tables/subgroup_by_sex.csv` に保存。

