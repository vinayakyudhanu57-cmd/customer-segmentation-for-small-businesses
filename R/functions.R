# ==============================================================================
# R/functions.R
# Reusable analytical functions for Customer Segmentation for Small Businesses
# Built using Base R • Zero External Dependencies • Reproducible K-means
# ==============================================================================

#' Load and validate customer dataset
#'
#' @param file_path Character. Path to customer CSV file.
#' @return A validated data.frame of customer records.
load_and_validate_customers <- function(file_path = "data/customers.csv") {
  if (!file.exists(file_path)) {
    stop(paste("Dataset file not found at path:", file_path))
  }

  customers <- read.csv(file_path, stringsAsFactors = FALSE)

  required_cols <- c("customer_id", "age", "annual_income", "purchase_frequency", "average_purchase_amount")
  missing_cols <- setdiff(required_cols, names(customers))
  if (length(missing_cols) > 0) {
    stop(paste("Dataset is missing required column(s):", paste(missing_cols, collapse = ", ")))
  }

  # Check for minimum sample size
  if (nrow(customers) < 15) {
    stop(paste("Insufficient records for 3-cluster segmentation. Found only", nrow(customers), "records."))
  }

  # Check for duplicate customer IDs
  if (any(duplicated(customers$customer_id))) {
    dup_ids <- customers$customer_id[duplicated(customers$customer_id)]
    stop(paste("Duplicate customer_id found in dataset:", paste(unique(dup_ids), collapse = ", ")))
  }

  # Check for missing values (NA / NaN)
  has_na <- apply(customers[, required_cols], 1, function(row) any(is.na(row)))
  if (any(has_na)) {
    stop(paste("Dataset contains", sum(has_na), "record(s) with missing (NA) values."))
  }

  # Numeric type check
  numeric_cols <- c("age", "annual_income", "purchase_frequency", "average_purchase_amount")
  for (col in numeric_cols) {
    if (!is.numeric(customers[[col]])) {
      stop(paste("Column", col, "must be strictly numeric."))
    }
  }

  # Range validation
  if (any(customers$age < 16 | customers$age > 100)) {
    stop("Customer age values fall outside valid human range (16 - 100).")
  }
  if (any(customers$annual_income <= 0)) {
    stop("Annual income values must be strictly positive numbers.")
  }
  if (any(customers$purchase_frequency <= 0)) {
    stop("Purchase frequency values must be strictly positive numbers.")
  }
  if (any(customers$average_purchase_amount <= 0)) {
    stop("Average purchase amount values must be strictly positive numbers.")
  }

  # Ensure clean numeric types
  customers$customer_id <- as.integer(customers$customer_id)
  customers$age <- as.integer(customers$age)
  customers$annual_income <- as.numeric(customers$annual_income)
  customers$purchase_frequency <- as.numeric(customers$purchase_frequency)
  customers$average_purchase_amount <- as.numeric(customers$average_purchase_amount)

  return(customers)
}

#' Calculate comprehensive overall dataset summary statistics
#'
#' @param customers Data.frame of validated customer records.
#' @return A named list of descriptive statistics.
calculate_overall_summary <- function(customers) {
  total_n <- nrow(customers)
  
  summary_info <- list(
    total_customers = total_n,
    avg_age = round(mean(customers$age), 1),
    min_age = min(customers$age),
    max_age = max(customers$age),
    avg_annual_income = round(mean(customers$annual_income), 2),
    min_annual_income = round(min(customers$annual_income), 2),
    max_annual_income = round(max(customers$annual_income), 2),
    avg_purchase_frequency = round(mean(customers$purchase_frequency), 1),
    min_purchase_frequency = min(customers$purchase_frequency),
    max_purchase_frequency = max(customers$purchase_frequency),
    avg_purchase_amount = round(mean(customers$average_purchase_amount), 2),
    min_purchase_amount = round(min(customers$average_purchase_amount), 2),
    max_purchase_amount = round(max(customers$average_purchase_amount), 2),
    total_annual_revenue_est = round(sum(customers$purchase_frequency * customers$average_purchase_amount), 2)
  )
  
  return(summary_info)
}

#' Perform K-means clustering on customer behavioral features
#'
#' @param customers Data.frame of customers.
#' @param k Integer. Number of clusters (default 3).
#' @param seed Integer. Random seed for reproducibility (default 42).
#' @param nstart Integer. Number of random initial starts (default 25).
#' @return A list containing segmented data.frame, model object, and scaled matrix.
perform_customer_clustering <- function(customers, k = 3, seed = 42, nstart = 25) {
  feature_cols <- c("age", "annual_income", "purchase_frequency", "average_purchase_amount")
  
  # Extract feature matrix (excluding customer_id)
  features_raw <- customers[, feature_cols]
  
  # Standardize features using scale() (Z-score normalization)
  scaled_matrix <- scale(features_raw)
  
  # Enforce reproducibility
  set.seed(seed)
  
  # Run K-means clustering
  km_model <- kmeans(scaled_matrix, centers = k, nstart = nstart)
  
  # Append cluster assignment to original customer dataset
  segmented_df <- customers
  segmented_df$cluster <- as.integer(km_model$cluster)
  
  return(list(
    segmented_data = segmented_df,
    model = km_model,
    scaled_features = scaled_matrix,
    feature_names = feature_cols
  ))
}

#' Compute descriptive summary statistics for each assigned cluster
#'
#' @param segmented_df Data.frame containing original customer columns and 'cluster'.
#' @return Data.frame of cluster statistics.
compute_cluster_summaries <- function(segmented_df) {
  total_customers <- nrow(segmented_df)
  cluster_ids <- sort(unique(segmented_df$cluster))
  
  summary_rows <- list()
  
  for (cid in cluster_ids) {
    cluster_subset <- segmented_df[segmented_df$cluster == cid, ]
    count_c <- nrow(cluster_subset)
    pct_c <- round((count_c / total_customers) * 100, 1)
    
    avg_age_c <- round(mean(cluster_subset$age), 1)
    avg_income_c <- round(mean(cluster_subset$annual_income), 2)
    avg_freq_c <- round(mean(cluster_subset$purchase_frequency), 1)
    avg_amount_c <- round(mean(cluster_subset$average_purchase_amount), 2)
    avg_annual_spend_c <- round(avg_freq_c * avg_amount_c, 2)
    
    summary_rows[[length(summary_rows) + 1]] <- data.frame(
      cluster = as.integer(cid),
      customer_count = as.integer(count_c),
      percentage = pct_c,
      avg_age = avg_age_c,
      avg_annual_income = avg_income_c,
      avg_purchase_frequency = avg_freq_c,
      avg_purchase_amount = avg_amount_c,
      est_annual_spend_per_customer = avg_annual_spend_c,
      stringsAsFactors = FALSE
    )
  }
  
  summary_df <- do.call(rbind, summary_rows)
  rownames(summary_df) <- NULL
  return(summary_df)
}

#' Generate explainable marketing insights based on actual cluster characteristics
#'
#' @param cluster_summary Data.frame of computed cluster summary metrics.
#' @param overall_summary Named list of overall metrics.
#' @return A list of marketing insight objects for each cluster.
generate_marketing_insights <- function(cluster_summary, overall_summary) {
  insights <- list()
  
  ov_freq <- overall_summary$avg_purchase_frequency
  ov_amount <- overall_summary$avg_purchase_amount
  ov_income <- overall_summary$avg_annual_income
  
  for (i in seq_len(nrow(cluster_summary))) {
    cid <- cluster_summary$cluster[i]
    c_count <- cluster_summary$customer_count[i]
    c_pct <- cluster_summary$percentage[i]
    c_age <- cluster_summary$avg_age[i]
    c_income <- cluster_summary$avg_annual_income[i]
    c_freq <- cluster_summary$avg_purchase_frequency[i]
    c_amount <- cluster_summary$avg_purchase_amount[i]
    c_spend <- cluster_summary$est_annual_spend_per_customer[i]
    
    # Determine cluster characteristics dynamically relative to overall dataset
    is_high_spend <- c_amount > (ov_amount * 1.2)
    is_high_freq <- c_freq > (ov_freq * 1.2)
    is_budget <- c_amount < (ov_amount * 0.8) && c_freq < (ov_freq * 0.8)
    
    if (is_high_spend) {
      segment_name <- "High-Value Occasional Spenders"
      characteristics <- sprintf("Higher average purchase value ($%.2f vs avg $%.2f) and higher income ($%.2f), with moderate visit frequency (%.1f visits/yr).",
                                 c_amount, ov_amount, c_income, c_freq)
      strategy <- "VIP concierge service, premium product launches, high-tier bundling, and personalized relationship marketing."
      rationale <- sprintf("Because these customers exhibit the highest basket size ($%.2f/purchase), premium upselling and exclusive service maximize revenue without requiring constant purchase frequency.",
                           c_amount)
    } else if (is_high_freq) {
      segment_name <- "Frequent Repeat Shoppers"
      characteristics <- sprintf("Significantly higher visit frequency (%.1f visits/yr vs avg %.1f) and moderate basket sizes ($%.2f), reflecting regular ongoing patronage.",
                                 c_freq, ov_freq, c_amount)
      strategy <- "Points-based loyalty program, automatic replenishment reminders, frequency milestone rewards, and member-only weekly specials."
      rationale <- sprintf("With visit frequency at %.1f purchases annually, rewarding continuous repeat engagement strengthens brand loyalty and increases lifetime customer retention.",
                           c_freq)
    } else {
      segment_name <- "Occasional Value Shoppers"
      characteristics <- sprintf("Lower purchase frequency (%.1f visits/yr) and budget-conscious basket sizes ($%.2f vs avg $%.2f) with lower average income ($%.2f).",
                                 c_freq, c_amount, ov_amount, c_income)
      strategy <- "Targeted re-engagement discounts, entry-level promotional bundles, seasonal flash sales, and low-barrier referral bonuses."
      rationale <- sprintf("Because this segment spends less per transaction ($%.2f) and shops less frequently (%.1f/yr), price-accessible incentives encourage repeat visits and habit formation.",
                           c_amount, c_freq)
    }
    
    insights[[length(insights) + 1]] <- list(
      cluster = as.integer(cid),
      segment_name = segment_name,
      customer_count = as.integer(c_count),
      percentage = c_pct,
      avg_age = c_age,
      avg_annual_income = c_income,
      avg_purchase_frequency = c_freq,
      avg_purchase_amount = c_amount,
      est_annual_spend = c_spend,
      key_characteristics = characteristics,
      recommended_strategy = strategy,
      rationale = rationale
    )
  }
  
  return(insights)
}

#' Pure Base R JSON serializer (Zero External Dependency)
#'
#' @param obj Any R object (list, vector, data.frame).
#' @return Valid JSON formatted character string.
to_json_string <- function(obj) {
  if (is.null(obj)) {
    return("null")
  }
  
  if (is.data.frame(obj)) {
    # Convert data frame to array of JSON objects
    row_list <- lapply(seq_len(nrow(obj)), function(r) {
      row_vals <- as.list(obj[r, , drop = FALSE])
      names(row_vals) <- names(obj)
      return(row_vals)
    })
    return(to_json_string(row_list))
  }
  
  if (is.list(obj)) {
    # Check if named list (JSON object) or unnamed list (JSON array)
    nms <- names(obj)
    if (!is.null(nms) && any(nms != "")) {
      # JSON Object
      pairs <- vapply(seq_along(obj), function(idx) {
        k <- nms[idx]
        v <- obj[[idx]]
        sprintf("\"%s\": %s", escape_json_str(k), to_json_string(v))
      }, FUN.VALUE = character(1))
      return(paste0("{\n  ", paste(pairs, collapse = ",\n  "), "\n}"))
    } else {
      # JSON Array
      items <- vapply(obj, to_json_string, FUN.VALUE = character(1))
      return(paste0("[\n  ", paste(items, collapse = ",\n  "), "\n]"))
    }
  }
  
  if (is.vector(obj)) {
    if (length(obj) == 0) {
      return("[]")
    }
    if (length(obj) == 1) {
      if (is.na(obj)) return("null")
      if (is.logical(obj)) return(if (obj) "true" else "false")
      if (is.numeric(obj)) {
        if (is.finite(obj)) return(format(obj, scientific = FALSE, trim = TRUE))
        return("null")
      }
      # Character / string
      return(sprintf("\"%s\"", escape_json_str(as.character(obj))))
    } else {
      # Multi-element atomic vector -> JSON array
      items <- vapply(obj, function(x) {
        if (is.na(x)) return("null")
        if (is.logical(x)) return(if (x) "true" else "false")
        if (is.numeric(x)) {
          if (is.finite(x)) return(format(x, scientific = FALSE, trim = TRUE))
          return("null")
        }
        sprintf("\"%s\"", escape_json_str(as.character(x)))
      }, FUN.VALUE = character(1))
      return(paste0("[", paste(items, collapse = ", "), "]"))
    }
  }
  
  return(sprintf("\"%s\"", escape_json_str(as.character(obj))))
}

#' Escape special characters for valid JSON strings
escape_json_str <- function(s) {
  if (is.null(s) || length(s) == 0 || is.na(s)) return("")
  s <- as.character(s)
  s <- gsub("\\\\", "\\\\\\\\", s)
  s <- gsub("\"", "\\\\\"", s)
  s <- gsub("\r", "\\\\r", s)
  s <- gsub("\n", "\\\\n", s)
  s <- gsub("\t", "\\\\t", s)
  return(s)
}

#' Export all customer segmentation analysis results to output/
#'
#' @param segmented_df Customer data with cluster assignments.
#' @param cluster_summary Cluster summary statistics.
#' @param marketing_insights List of marketing insight objects.
#' @param overall_summary Overall dataset statistics list.
#' @param output_dir Output folder path (default "output").
export_analysis_outputs <- function(segmented_df,
                                    cluster_summary,
                                    marketing_insights,
                                    overall_summary,
                                    output_dir = "output") {
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # 1. output/customer_segments.csv
  csv_segments_path <- file.path(output_dir, "customer_segments.csv")
  write.csv(segmented_df, csv_segments_path, row.names = FALSE)
  
  # 2. output/cluster_summary.csv
  csv_summary_path <- file.path(output_dir, "cluster_summary.csv")
  write.csv(cluster_summary, csv_summary_path, row.names = FALSE)
  
  # 3. output/marketing_insights.json
  json_insights_path <- file.path(output_dir, "marketing_insights.json")
  insights_json_text <- to_json_string(marketing_insights)
  writeLines(insights_json_text, json_insights_path, useBytes = TRUE)
  
  # 4. output/dashboard_data.json
  # Convert customers dataframe to list of records
  customers_list <- lapply(seq_len(nrow(segmented_df)), function(r) {
    as.list(segmented_df[r, ])
  })
  
  dashboard_data <- list(
    generated_at = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    overview = overall_summary,
    clusters = lapply(seq_len(nrow(cluster_summary)), function(r) as.list(cluster_summary[r, ])),
    insights = marketing_insights,
    customers = customers_list
  )
  
  dashboard_json_path <- file.path(output_dir, "dashboard_data.json")
  dashboard_json_text <- to_json_string(dashboard_data)
  writeLines(dashboard_json_text, dashboard_json_path, useBytes = TRUE)
  
  cat(sprintf("[OK] Exported 4 result files to '%s/' successfully:\n", output_dir))
  cat(sprintf("  - %s\n", csv_segments_path))
  cat(sprintf("  - %s\n", csv_summary_path))
  cat(sprintf("  - %s\n", json_insights_path))
  cat(sprintf("  - %s\n", dashboard_json_path))
  
  return(invisible(TRUE))
}
