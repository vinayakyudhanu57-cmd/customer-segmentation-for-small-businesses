# ==============================================================================
# data/generate_dataset.R
# Generates reproducible synthetic customer dataset (100 records)
# Customer Segmentation for Small Businesses
# ==============================================================================

set.seed(42)

n_a <- 35  # High-value / Premium spenders
n_b <- 35  # Frequent loyal repeat shoppers
n_c <- 30  # Occasional budget shoppers
n_total <- n_a + n_b + n_c

# Group A: High Income, High Average Purchase, Moderate Frequency
age_a <- round(rnorm(n_a, mean = 46, sd = 8))
income_a <- round(rnorm(n_a, mean = 88000, sd = 11000))
freq_a <- round(rnorm(n_a, mean = 12, sd = 3))
amount_a <- round(rnorm(n_a, mean = 230, sd = 35), 2)

# Group B: Moderate Income, High Frequency, Moderate Average Purchase
age_b <- round(rnorm(n_b, mean = 33, sd = 6))
income_b <- round(rnorm(n_b, mean = 54000, sd = 7500))
freq_b <- round(rnorm(n_b, mean = 34, sd = 5))
amount_b <- round(rnorm(n_b, mean = 92, sd = 16), 2)

# Group C: Lower Income, Low Frequency, Budget Average Purchase
age_c <- round(rnorm(n_c, mean = 29, sd = 7))
income_c <- round(rnorm(n_c, mean = 31000, sd = 4500))
freq_c <- round(rnorm(n_c, mean = 7, sd = 2))
amount_c <- round(rnorm(n_c, mean = 44, sd = 9), 2)

# Combine and enforce realistic bounds
age <- pmax(18, pmin(70, c(age_a, age_b, age_c)))
income <- pmax(18000, pmin(125000, c(income_a, income_b, income_c)))
freq <- pmax(2, pmin(50, c(freq_a, freq_b, freq_c)))
amount <- pmax(15, pmin(350, c(amount_a, amount_b, amount_c)))

# Shuffle records so groups are randomly distributed
shuffle_idx <- sample(n_total)

customers <- data.frame(
  customer_id = 1001:(1000 + n_total),
  age = age[shuffle_idx],
  annual_income = income[shuffle_idx],
  purchase_frequency = freq[shuffle_idx],
  average_purchase_amount = amount[shuffle_idx],
  stringsAsFactors = FALSE
)

# Ensure directory exists and write CSV
if (!dir.exists("data")) {
  dir.create("data", recursive = TRUE)
}

write.csv(customers, "data/customers.csv", row.names = FALSE)
cat(sprintf("[OK] Successfully generated data/customers.csv with %d records.\n", nrow(customers)))
