# QA Report: hypertension_logistic_sim

- **Execution Timestamp**: 2026-11-03 12:44:39.217253
- **Overall Verification Status**: ✅ PASSED

## Key Results vs Expected Criteria

| Plan ID | Metric | Expected | Tolerance | Observed | Diff | Status |
|---|---|---|---|---|---|---|
| `G0-3` | `n_events` | 43.000 | 0.000 | 43.000 | 0.000 | ✅ PASS |
| `G0-3` | `n_total` | 100.000 | 0.000 | 100.000 | 0.000 | ✅ PASS |
| `G2B-1` | `age_or` | 1.061 | 0.020 | 1.061 | 0.000 | ✅ PASS |
| `G2B-1` | `male_or` | 1.267 | 0.050 | 1.267 | 0.000 | ✅ PASS |
| `G2B-1` | `smoking_or` | 2.790 | 0.050 | 2.790 | 0.000 | ✅ PASS |

## Model Assumption Checks

| Plan ID | Model | Check Item | Required | Diagnostic Result | Status |
|---|---|---|---|---|---|
| `G2B-1` | `logistic_regression` | `sample_events` | Yes | events = 43, non-events = 57 (both >= 10) | ✅ PASS |
| `G2B-1` | `logistic_regression` | `complete_convergence` | Yes | max SE = 0.59 < 10 (no complete separation) | ✅ PASS |
| `G2C-1` | `logistic_regression` | `vif_multicollinearity` | No | max VIF = 1.07 < 5.0 | ✅ PASS |

## Summary Conclusion
All pre-specified key numerical criteria and model assumptions passed successfully within defined tolerance margins.
