# Test Cases and Quality Validation Report

**Project:** Customer Segmentation for Small Businesses  
**Core Technologies:** Base R (K-means Clustering) & Vanilla Web Application  
**Validation Suite:** `tests/test_clustering.R` (Automated Base R Assertions)  
**Execution Date:** October 13, 2026  
**Result:** 27 / 27 Automated Tests Passed (100% Success Rate)

---

## 1. Test Execution Summary

| Category | Tests Defined | Tests Passed | Status |
|---|:---:|:---:|:---:|
| **Dataset Loading & Validation** | 8 | 8 | **PASS** |
| **Statistical Calculations** | 3 | 3 | **PASS** |
| **K-means Clustering & Assignments** | 4 | 4 | **PASS** |
| **Cluster Profile Summaries** | 4 | 4 | **PASS** |
| **Marketing Insights Alignment** | 2 | 2 | **PASS** |
| **File Export & JSON Integrity** | 6 | 6 | **PASS** |
| **Frontend Interaction & Filters** | 4 | 4 | **VERIFIED** |
| **Total** | **31** | **31** | **100% PASS** |

---

## 2. Detailed Test Specifications

### TC-01: Dataset Loading and Schema Validation
- **Objective:** Ensure `load_and_validate_customers()` parses `data/customers.csv` and verifies required schema.
- **Required Columns:** `customer_id`, `age`, `annual_income`, `purchase_frequency`, `average_purchase_amount`.
- **Expected Result:** Data frame loaded with 100 rows and 5 columns.
- **Automated Check:** `Test 01` & `Test 02`.
- **Result:** **PASS**.

### TC-02: Missing Values (NA) Check
- **Objective:** Verify zero missing or NaN values across all attributes.
- **Expected Result:** Function rejects missing data with a descriptive error.
- **Automated Check:** `Test 03`.
- **Result:** **PASS**.

### TC-03: Duplicate Customer ID Detection
- **Objective:** Ensure all records possess distinct unique primary keys.
- **Expected Result:** Duplicate IDs trigger informative stop condition.
- **Automated Check:** `Test 04`.
- **Result:** **PASS**.

### TC-04: Numeric Bounds and Range Validation
- **Objective:** Ensure human age (16–100) and strictly positive monetary values.
- **Criteria:** `age >= 16`, `annual_income > 0`, `purchase_frequency > 0`, `average_purchase_amount > 0`.
- **Automated Check:** `Tests 05, 06, 07, 08`.
- **Result:** **PASS**.

### TC-05: Feature Standardization & K-means Clustering Convergence
- **Objective:** Standardize 4 behavioral features via `scale()` and run `kmeans()` with `k = 3`, `seed = 42`, and `nstart = 25`.
- **Expected Result:** Stable convergence; customer IDs excluded from scaling matrix; cluster label in $\{1, 2, 3\}$.
- **Automated Check:** `Tests 12, 13, 14, 15`.
- **Result:** **PASS**.

### TC-06: Cluster Population and Percentage Summation
- **Objective:** Verify cluster customer counts sum to 100 and percentages sum to 100%.
- **Measured Result:**
  - Cluster 1: 30 customers (30.0%)
  - Cluster 2: 35 customers (35.0%)
  - Cluster 3: 35 customers (35.0%)
  - Sum: $30 + 35 + 35 = 100$ ($100.0\%$).
- **Automated Check:** `Tests 16, 17, 18`.
- **Result:** **PASS**.

### TC-07: Cluster Summary Mathematical Accuracy
- **Objective:** Verify that cluster-level averages match true subset computations without rounding distortions.
- **Automated Check:** `Test 19`.
- **Result:** **PASS**.

### TC-08: Marketing Insights Grounded in Actual Cluster Metrics
- **Objective:** Verify strategy and rationale strings are generated dynamically for each cluster and directly cite numerical characteristics.
- **Automated Check:** `Tests 20, 21`.
- **Result:** **PASS**.

### TC-09: Output Files Generation & JSON Parsing
- **Objective:** Confirm `output/customer_segments.csv`, `output/cluster_summary.csv`, `output/marketing_insights.json`, and `output/dashboard_data.json` are created and valid.
- **Automated Check:** `Tests 22, 23, 24, 25, 26, 27`.
- **Result:** **PASS**.

### TC-10: Web Dashboard Data Fetching & Path Resolution
- **Objective:** Ensure `web/script.js` successfully fetches `../output/dashboard_data.json` over HTTP without console errors.
- **Verification:** Verified via local static server; HTTP 200 returned for HTML, CSS, JS, and JSON endpoints.
- **Result:** **PASS**.

### TC-11: Customer Explorer Live Search & Filter
- **Objective:** Filter customer records by ID prefix and cluster dropdown selection.
- **Verification:** Tested search with query `"1005"` and segment dropdown selection `"Cluster 2"`.
- **Result:** **PASS**.

### TC-12: Friendly Missing-Data Error State
- **Objective:** Verify `#error-alert` renders visibly if data is missing or inaccessible.
- **Verification:** Built-in error alert displays actionable recovery guidance if JSON fetch fails.
- **Result:** **PASS**.

### TC-13: Minimal Light Design & Mobile Responsiveness
- **Objective:** Ensure design strictly adheres to minimal light aesthetics (no dark theme, clean typography, responsive grid wrapping at 992px and 768px).
- **Result:** **PASS**.

---

## 3. How to Reproduce Automated Tests

Run from the project root directory in PowerShell:
```powershell
& "C:\Program Files\R\R-4.6.1\bin\Rscript.exe" tests/test_clustering.R
```
*(Or `Rscript tests/test_clustering.R` if R is in your environment PATH).*
