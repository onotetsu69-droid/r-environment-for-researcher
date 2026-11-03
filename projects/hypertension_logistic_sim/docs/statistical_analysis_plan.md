# Statistical Analysis Plan (SAP): 高血圧症の関連要因評価に関するシミュレーション研究

## 1. Document Control
- **Project Name**: `hypertension_logistic_sim`
- **Version**: 1.0.0
- **Date**: 2026-11-03
- **Author**: Antigravity Assistant & Investigator
- **Status**: Approved (Simulation & Demonstration Protocol)

## 2. Background
高血圧症（Hypertension）は脳心血管疾患の主要な危険因子であり、その予防および早期管理は公衆衛生・臨床医学上の最重要課題である。高血圧の発症には加齢、性差、過体重（肥満）、喫煙、飲酒などの生活習慣・背景因子が複雑に関与している。本研究は、100例の模擬臨床データを用いて、これら複数のリスク因子が高血圧症の保有に与える関連の大きさを多変量ロジスティック回帰分析によって評価するための解析計画書である。

## 3. Objectives and Hypotheses
- **主目的**: 40〜75歳の対象者100例において、年齢、性別、BMI、現在喫煙習慣、飲酒習慣が高血圧症（有病）に与えるオッズ比（OR）および95%信頼区間（CI）を多変量ロジスティック回帰分析により推定する。
- **副次目的**: 単変量モデルと多変量モデルでの効果推定値の変化を比較し、交絡の調整状況を確認する。
- **仮説**: 高齢、男性、高BMI、喫煙習慣は、相互に調整した後も独立して高血圧症のオッズ上昇と関連する。

## 4. Study Design and Data Source
- **研究デザイン**: 仮想横断研究（Simulated Cross-Sectional Study）
- **データソース**: 臨床疫学的知見（JSH2019ガイドライン等の疫学パラメータ）に基づき生成されたシミュレーションデータ（N = 100）
- **再現性シード**: `seed = 20261103`

## 5. Study Population
- **対象集団**: 地域または人間ドックを受診した40歳から75歳の成人男女100名。
- **適格基準**: 
  - 40歳以上75歳以下
  - 主要な変数（年齢、性別、BMI、喫煙、飲酒、血圧測定値）に欠測がない完全データ
- **除外基準**: 明らかな測定異常値（例：BMI < 10 または > 50、年齢 < 0）

## 6. Variables
- **主要アウトカム（従属変数）**:
  - `htn` (高血圧症): 二値変数（0 = 正常血圧, 1 = 高血圧）。基準：収縮期血圧（SBP）$\ge 140\text{ mmHg}$ または 拡張期血圧（DBP）$\ge 90\text{ mmHg}$。
- **主要説明変数・調整共変量**:
  - `age`: 年齢（歳、連続変数）
  - `sex`: 性別（二値カテゴリ: 基準 = "Female", 比較 = "Male"）
  - `bmi`: BMI（$\text{kg/m}^2$、連続変数）
  - `smoking`: 現在喫煙（二値カテゴリ: 基準 = 0 [非喫煙], 比較 = 1 [喫煙]）
  - `alcohol`: 飲酒習慣（二値カテゴリ: 基準 = "None/Occasional", 比較 = "Regular"）
- **参考測定値**:
  - `sbp`: 収縮期血圧（mmHg、連続値）
  - `dbp`: 拡張期血圧（mmHg、連続値）

## 7. Data Processing Plan
- **インポートと検証**: CSVファイルからの読込後、行数（N=100）、列数、変数型を検証。
- **データ型変換**: カテゴリ変数を明示的に `factor` 型へ変換し、参照カテゴリ（Reference level）を事前固定する。
- **欠測値処理**: 完全ケース分析（設計上欠測なし、万一欠測がある場合は除外前に件数を明示）。

## 8. Statistical Principles
- **効果指標と区間推定**: 全ての効果指標はオッズ比（Odds Ratio, OR）およびプロファイル尤度またはロバスト標準誤差に基づく95%信頼区間（95% CI）を主たる結果として報告する。
- **有意性判定**: 単なる「$P < 0.05$」による二分法（有意/非有意）の結論を避け、実測 $P$ 値（例: $P = 0.024$）と臨床的意義・推定値の幅（95% CI）を総合的に考察する。
- **連続変数の扱い**: 原則として年齢やBMIを二値化（例：65歳以上/未満、BMI 25以上/未満）せず、情報損失を防ぐため連続変数のままモデルへ投入する。

## 9. Descriptive and Exploratory Analyses
- **Table 1（背景特性表）**: 全体および高血圧症の有無別（`htn = 0` vs `htn = 1`）に集計。
  - 連続変数: 平均値 $\pm$ 標準偏差（SD）または中央値 [四分位範囲: IQR]
  - カテゴリ変数: 人数および割合 $n$ (%)
  - 群間比較: 連続変数は t検定またはWilcoxon順位和検定、カテゴリ変数はカイ二乗検定またはFisher正確検定（実測P値を併記）。
- **探索的可視化**:
  - 高血圧有無別の年齢・BMIの箱ひげ図 / バイオリンプロット
  - 各因子の分布と相関マトリクス

## 10. Primary Analysis
- **解析モデル**: 多項ロジスティック回帰（二項分布・ロジットリンク関数）
  $$\text{logit}(P(\text{htn} = 1)) = \beta_0 + \beta_1 \cdot \text{age} + \beta_2 \cdot I(\text{sex} = \text{"Male"}) + \beta_3 \cdot \text{bmi} + \beta_4 \cdot I(\text{smoking} = 1) + \beta_5 \cdot I(\text{alcohol} = \text{"Regular"})$$
- **算出項目**:
  - 各変数の回帰係数 $\beta$、標準誤差（SE）、調整オッズ比（Adjusted OR = $\exp(\beta)$）、95%信頼区間、Wald $P$ 値
- **モデル適合度・仮定検証**:
  - 多重共線性: 分散拡大係数（Variance Inflation Factor, VIF）を算出し、VIF < 5 であることを確認。
  - 全体適合度: Hosmer-Lemeshow 検定または逸脱度（Deviance）の評価。

## 11. Secondary Analyses
- **単変量ロジスティック回帰分析（Unadjusted OR）**:
  - 各説明変数（年齢、性別、BMI、喫煙、飲酒）を単独で投入した粗オッズ比（Crude OR）を算出し、多変量調整オッズ比と比較して交絡の程度を把握する。

## 12. Subgroup Analyses
- **性別による層別解析（Exploratory Subgroup）**:
  - 男性（Male）と女性（Female）の各サブグループにおいて同様の回帰モデルを推定し、効果の方向性に顕著な異質性がないかを定性的に確認する。

## 13. Sensitivity Analyses
- **多重共線性と共変量定義の感度分析**:
  - 飲酒習慣を除外したモデルでの主因子のオッズ比の頑健性を評価。
  - BMIの2乗項（非線形性）を投入したモデルとの比較。

## 14. Reproducibility and Code Operations
- **R環境**: R 4.6.1、base R / stats / graphics を核とし、ポータブルな設計とする。
- **スクリプト連番管理**: `00_setup.R` 〜 `07_exploratory_analysis.R`、`run_all.R`。
- **検証アーティファクト**: `code-review-companion` 規約に従い、Stage A（逆翻訳・トレーサビリティ）および Stage B（QAレポート・検証レポート）を自動生成。

## 15. References
1. 日本高血圧学会 高血圧治療ガイドライン作成委員会. 高血圧治療ガイドライン2019 (JSH2019).
2. von Elm E, Altman DG, Egger M, et al. The Strengthening the Reporting of Observational Studies in Epidemiology (STROBE) statement. *Lancet*. 2007;370(9596):1453-1457.
3. Hosmer DW, Lemeshow S, Sturdivant RX. *Applied Logistic Regression*. 3rd ed. John Wiley & Sons; 2013.

## 16. Decision Log
- **2026-11-03**: 初期SAP策定。ユーザーヒアリングに基づき、リスク因子評価目的の多変量ロジスティック回帰、完全データ（N=100）、標準リポジトリ構成を採用。

