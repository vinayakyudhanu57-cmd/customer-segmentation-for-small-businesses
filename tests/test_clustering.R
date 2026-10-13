# ==============================================================================
# tests/test_clustering.R
# Automated Unit & Integration Tests using Base R Assertions
# Customer Segmentation for Small Businesses
# ==============================================================================

source("R/functions.R")

test_count <- 0
passed_count <- 0

assert_test <- function(test_name, condition) {
  test_count <<- test_count + 1
  if (isTRUE(condition)) {
    passed_count <<- passed_count + 1
    cat(sprintf("  [PASS] Test %02d: %s\n", test_count, test_name))
  } else {
    cat(sprintf("  [FAIL] Test %02d: %s\n", test_count, test_name))
    stop(paste("Assertion failed for:", test_name))
  }
}

cat("\n======================================================================\n")
cat(" RUNNING AUTOMATED R TEST SUITE: CUSTOMER SEGMENTATION                \n")
cat("======================================================================\n\n")

# 1. Dataset Loading & Schema Validation
customers <- load_and_validate_customers("data/customers.csv")
assert_test("Dataset loads successfully with exactly 100 records", nrow(customers) == 100)
assert_test("All 5 required columns exist", all(c("customer_id", "age", "annual_income", "purchase_frequency", "average_purchase_amount") %in% names(customers)))
assert_test("No missing (NA) values in any column", all(!is.na(customers)))
assert_test("All customer IDs are unique", !any(duplicated(customers$customer_id)))
assert_test("Age values are within valid human range (16 - 100)", all(customers$age >= 16 & customers$age <= 100))
assert_test("Annual income values are positive", all(customers$annual_income > 0))
assert_test("Purchase frequency values are positive", all(customers$purchase_frequency > 0))
assert_test("Average purchase amounts are positive", all(customers$average_purchase_amount > 0))

# 2. Overall Summary Computation
ov <- calculate_overall_summary(customers)
assert_test("Overall summary total_customers equals 100", ov$total_customers == 100)
assert_test("Overall summary avg_age is between 18 and 65", ov$avg_age >= 18 && ov$avg_age <= 65)
assert_test("Overall summary avg_income is positive", ov$avg_annual_income > 30000)

# 3. K-means Clustering Execution
cluster_res <- perform_customer_clustering(customers, k = 3, seed = 42, nstart = 25)
segmented <- cluster_res$segmented_data

assert_test("Customer data retains all original columns plus 'cluster'", all(c("customer_id", "age", "annual_income", "purchase_frequency", "average_purchase_amount", "cluster") %in% names(segmented)))
assert_test("Cluster assignment count matches customer count (100)", nrow(segmented) == 100)
assert_test("All assigned clusters are strictly 1, 2, or 3", all(segmented$cluster %in% c(1, 2, 3)))
assert_test("Exactly 3 distinct clusters are discovered", length(unique(segmented$cluster)) == 3)

# 4. Cluster Summary Verification
summary_df <- compute_cluster_summaries(segmented)
assert_test("Cluster summary contains exactly 3 rows", nrow(summary_df) == 3)
assert_test("Cluster customer counts sum to total customers (100)", sum(summary_df$customer_count) == 100)
assert_test("Cluster percentages sum to 100% (within rounding)", abs(sum(summary_df$percentage) - 100.0) < 0.2)
assert_test("Cluster averages match manual subset calculations", {
  c1_sub <- segmented[segmented$cluster == 1, ]
  abs(summary_df$avg_age[summary_df$cluster == 1] - round(mean(c1_sub$age), 1)) < 1e-4
})

# 5. Marketing Insights Alignment
insights <- generate_marketing_insights(summary_df, ov)
assert_test("Marketing insights generated for all 3 clusters", length(insights) == 3)
assert_test("Each insight has segment_name, strategy, and rationale", all(vapply(insights, function(ins) {
  nchar(ins$segment_name) > 3 && nchar(ins$recommended_strategy) > 10 && nchar(ins$rationale) > 10
}, FUN.VALUE = logical(1))))

# 6. JSON Serialization & Output Files Verification
export_analysis_outputs(segmented, summary_df, insights, ov, output_dir = "output")

assert_test("File output/customer_segments.csv exists", file.exists("output/customer_segments.csv"))
assert_test("File output/cluster_summary.csv exists", file.exists("output/cluster_summary.csv"))
assert_test("File output/marketing_insights.json exists", file.exists("output/marketing_insights.json"))
assert_test("File output/dashboard_data.json exists", file.exists("output/dashboard_data.json"))

# Test JSON file readability without errors
insights_raw <- readLines("output/marketing_insights.json", warn = FALSE)
assert_test("output/marketing_insights.json is non-empty and starts with array", grepl("^\\[", trimws(insights_raw[1])))

dashboard_raw <- readLines("output/dashboard_data.json", warn = FALSE)
assert_test("output/dashboard_data.json is non-empty and starts with object", grepl("^\\{", trimws(dashboard_raw[1])))

cat("\n======================================================================\n")
cat(sprintf(" TEST SUITE SUMMARY: %d / %d TESTS PASSED (100%% SUCCESS)\n", passed_count, test_count))
cat("======================================================================\n\n")
