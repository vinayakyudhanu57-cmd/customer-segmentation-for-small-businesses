# Customer Segmentation for Small Businesses

An empirical customer analytics and segmentation application designed for small businesses to discover distinct behavioral customer groups, analyze purchasing patterns, and derive data-backed marketing strategies using K-means clustering.

---

## 1. Project Overview

Small business owners frequently face challenges in prioritizing marketing budgets and tailoring promotions effectively across diverse customer bases. This application implements an unsupervised K-means clustering workflow in Base R to segment customers by age, annual income, visit frequency, and average transaction amount. 

The analytical results are exported to structured CSV and JSON outputs, which feed an interactive, minimal light web dashboard allowing business stakeholders to explore segment profiles, compare purchasing metrics, search individual customers, and review targeted retention strategies.

---

## 2. Main Features

- **Standardized Behavioral Clustering:** Standardizes multi-scale customer attributes using `scale()` and applies 3-cluster K-means clustering (`kmeans()`, `nstart = 25`, `seed = 42`) for robust, scale-invariant segmentation.
- **Empirical Cluster Profiling:** Computes population counts, customer base percentages, average income, visit frequency, basket size, and estimated annual customer spend.
- **Actionable Marketing Strategies:** Dynamically formulates explainable marketing recommendations based on actual cluster metrics (e.g., VIP concierge for high basket sizes, points loyalty programs for high visit frequency, re-engagement offers for occasional shoppers).
- **Zero-Dependency R Architecture:** Built completely in Base R without requiring external packages or database servers.
- **Minimal Light Web Dashboard:** A responsive, calm, data-focused frontend featuring an analytical overview, dynamic SVG metric comparisons, a searchable/filterable customer table, and strategic insight cards.
- **Automated Quality Testing:** Includes an automated Base R test suite verifying data validation, cluster mathematics, and output integrity (100% pass rate).

---

## 3. Technologies Used

- **Analysis & Core Algorithms:** Base R (`read.csv`, `scale`, `kmeans`, vector aggregation, Base R JSON serialization).
- **Web Frontend:** Vanilla HTML5, CSS3 (Minimal Light Design System), and Vanilla JavaScript (ES6+).
- **Data & Exchange Formats:** CSV (`data/customers.csv`, `output/customer_segments.csv`, `output/cluster_summary.csv`) and JSON (`output/marketing_insights.json`, `output/dashboard_data.json`).
- **Version Control & Hosting:** Git, GitHub, and GitHub Pages.

---

## 4. Folder Structure

```text
customer-segmentation-for-small-businesses/
│
├── .gitignore                      # Git exclusion rules
├── README.md                       # Project documentation
├── PROGRESS.md                     # Development tracking log
├── NEXT_STEPS.md                   # Resumable task roadmap
├── index.html                      # Root redirect for GitHub Pages
│
├── R/
│   ├── main.R                      # Main pipeline execution entry point
│   └── functions.R                 # Reusable analytical & JSON export functions
│
├── data/
│   ├── customers.csv               # 100 fictional customer records
│   └── generate_dataset.R          # Reproducible dataset generator script
│
├── output/
│   ├── customer_segments.csv       # Customers with assigned cluster IDs
│   ├── cluster_summary.csv         # Aggregated cluster metrics
│   ├── marketing_insights.json     # Strategic recommendations & rationales
│   └── dashboard_data.json         # Complete web dashboard payload
│
├── web/
│   ├── index.html                  # Minimal light web application
│   ├── style.css                   # Calm, clean stylesheet
│   └── script.js                   # Client-side filtering & SVG comparisons
│
│
└── tests/
    ├── test_clustering.R           # 27 automated Base R unit tests
    └── test-cases.md               # Detailed quality assurance documentation
```

---

## 5. Prerequisites

- **R:** Base R 4.0 or newer (tested on R 4.6.1). No external packages required.
- **Web Browser:** Any modern browser (Chrome, Edge, Firefox, Safari).
- **Local Server (Optional for testing):** Python 3.x or Node.js.

---

## 6. How to Run the R Analysis

From the project root directory (`customer-segmentation-for-small-businesses`), execute:

```powershell
# Using Rscript on PATH
Rscript R/main.R

# Or using the full Rscript path on Windows
& "C:\Program Files\R\R-4.6.1\bin\Rscript.exe" R/main.R
```

This runs the complete analytical pipeline, outputs formatted cluster profiles to the terminal, and updates all 4 files in `output/`.

---

## 7. How to Start the Local Website

Because the web application fetches JSON data via HTTP requests, serve the directory using a lightweight local web server:

```powershell
# Start local server from project root
python -m http.server 8080
```

Open your browser and navigate to:
```
http://localhost:8080/web/
```
*(Navigating to `http://localhost:8080/` will also automatically redirect to `/web/` via the root `index.html`).*

---

## 8. How to Run Tests

Execute the automated Base R test suite:

```powershell
# Using Rscript on PATH
Rscript tests/test_clustering.R

# Or using the full Rscript path on Windows
& "C:\Program Files\R\R-4.6.1\bin\Rscript.exe" tests/test_clustering.R
```

*All 27 unit and integration assertions will run, verifying data validation, cluster math, JSON syntax, and output integrity.*

---

## 9. How to Deploy to GitHub Pages

1. Initialize Git and commit the project files (see Git commands below).
2. Push the repository to GitHub.
3. In your GitHub repository, open **Settings** > **Pages** (in the left sidebar).
4. Under **Build and deployment** > **Branch**, select `main` and keep `/ (root)` selected.
5. Click **Save**.
6. Within 1–2 minutes, your live dashboard will be accessible at:
   `https://[YOUR_USERNAME].github.io/[YOUR_REPOSITORY_NAME]/`

---

## 10. Important Architecture & Deployment Limitation

GitHub Pages is a static file host; **it serves static files and does not execute R code on the server**.

The R analysis (`R/main.R`) generates the data files (`output/dashboard_data.json` and CSVs) in advance. The web frontend directly consumes these pre-generated static outputs. Whenever new customer records are added or updated, rerun `Rscript R/main.R` locally and commit the resulting `output/` files to update the live website.

---

## Synthetic Data Notice

All customer names, IDs, incomes, and purchasing records in `data/customers.csv` are entirely fictional and generated using fixed random seeds exclusively for algorithmic demonstration and educational analysis.
