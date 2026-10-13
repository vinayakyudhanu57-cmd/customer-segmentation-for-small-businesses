# ==============================================================================
# R/main.R
# Customer Segmentation for Small Businesses
# Main Application Pipeline Entry Point
# ==============================================================================

# Source reusable analytical functions
source("R/functions.R")

main <- function() {
  cat("\n======================================================================\n")
  cat("           CUSTOMER SEGMENTATION FOR SMALL BUSINESSES                 \n")
  cat("          K-means Behavioral Clustering & Actionable Insights         \n")
  cat("======================================================================\n\n")

  # 1. Load and Validate Dataset
  data_path <- "data/customers.csv"
  cat(sprintf("[1/5] Loading and validating dataset from '%s'...\n", data_path))
  
  customers_df <- tryCatch({
    load_and_validate_customers(data_path)
  }, error = function(e) {
    cat(sprintf("[ERROR] Data validation failed: %s\n", e$message))
    stop("Halting analysis due to dataset errors.")
  })

  cat(sprintf("      Successfully loaded and validated %d customer records.\n", nrow(customers_df)))

  # 2. Compute Overall Summary Statistics
  cat("\n[2/5] Calculating overall customer metrics...\n")
  overall_stats <- calculate_overall_summary(customers_df)
  
  cat(sprintf("      Total Customers        : %d\n", overall_stats$total_customers))
  cat(sprintf("      Average Age            : %.1f years (Range: %d - %d)\n",
              overall_stats$avg_age, overall_stats$min_age, overall_stats$max_age))
  cat(sprintf("      Average Annual Income  : $%.2f (Range: $%.2f - $%.2f)\n",
              overall_stats$avg_annual_income, overall_stats$min_annual_income, overall_stats$max_annual_income))
  cat(sprintf("      Average Purchase Freq  : %.1f purchases/year\n", overall_stats$avg_purchase_frequency))
  cat(sprintf("      Average Basket Size    : $%.2f/purchase\n", overall_stats$avg_purchase_amount))
  cat(sprintf("      Est. Annual Revenue    : $%.2f\n", overall_stats$total_annual_revenue_est))

  # 3. Perform K-means Clustering
  cat("\n[3/5] Performing K-means behavioral clustering (k = 3, nstart = 25, seed = 42)...\n")
  clustering_result <- perform_customer_clustering(
    customers = customers_df,
    k = 3,
    seed = 42,
    nstart = 25
  )
  
  segmented_df <- clustering_result$segmented_data
  cat("      Standardized 4 behavioral features: age, annual_income, purchase_frequency, average_purchase_amount.\n")
  cat("      Cluster assignment completed for all 100 customer records.\n")

  # 4. Generate Cluster Summaries & Insights
  cat("\n[4/5] Computing cluster profile summaries and marketing insights...\n")
  cluster_summaries <- compute_cluster_summaries(segmented_df)
  insights <- generate_marketing_insights(cluster_summaries, overall_stats)

  cat("\n----------------------------------------------------------------------\n")
  cat(" CLUSTER SUMMARY PROFILES\n")
  cat("----------------------------------------------------------------------\n")
  for (i in seq_len(nrow(cluster_summaries))) {
    row <- cluster_summaries[i, ]
    insight <- insights[[i]]
    cat(sprintf("\n* CLUSTER %d: %s\n", row$cluster, toupper(insight$segment_name)))
    cat(sprintf("  Customers   : %d (%.1f%% of customer base)\n", row$customer_count, row$percentage))
    cat(sprintf("  Avg Age     : %.1f years\n", row$avg_age))
    cat(sprintf("  Avg Income  : $%.2f\n", row$avg_annual_income))
    cat(sprintf("  Avg Freq    : %.1f purchases/year\n", row$avg_purchase_frequency))
    cat(sprintf("  Avg Basket  : $%.2f / purchase\n", row$avg_purchase_amount))
    cat(sprintf("  Est. Spend  : $%.2f / customer / year\n", row$est_annual_spend_per_customer))
    cat(sprintf("  Strategy    : %s\n", insight$recommended_strategy))
    cat(sprintf("  Rationale   : %s\n", insight$rationale))
  }
  cat("----------------------------------------------------------------------\n")

  # 5. Export Results to output/
  cat("\n[5/5] Exporting analysis results for static web dashboard...\n")
  export_analysis_outputs(
    segmented_df = segmented_df,
    cluster_summary = cluster_summaries,
    marketing_insights = insights,
    overall_summary = overall_stats,
    output_dir = "output"
  )

  cat("\n======================================================================\n")
  cat(" [SUCCESS] Analysis complete! Output files generated in 'output/'.\n")
  cat("======================================================================\n\n")
}

# Run execution
main()
