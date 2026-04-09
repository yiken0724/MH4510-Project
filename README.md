# Supply Chain Customer Segmentation via Unsupervised Learning

> MH4510 Fantastic Four — Nanyang Technological University

A customer segmentation analysis of a global supply chain dataset using three unsupervised clustering methods — **K-Means**, **DBSCAN**, and **Gaussian Mixture Models (GMM)** — applied to 180,519 transactions across 20,652 unique customers. The project investigates how behavioural clustering can surface actionable customer segments that support logistics prioritisation, service differentiation, and anomaly detection.

---

## Motivation

Modern supply-chain operations generate large volumes of transactional data, yet organisations typically lack systematic understanding of customer heterogeneity in purchasing behaviour, order frequency, profit contribution and delivery reliability. Without data-driven segmentation, firms operate with uniform service levels and reactive decision-making, leading to inefficient resource allocation and limited ability to prioritise high-value customers. This project applies unsupervised learning to uncover latent behavioural patterns that directly inform supply-chain strategy.

---

## Repository Structure

```
.
├── dataset/
│   └── DataCoSupplyChainDataset.csv           # Primary dataset (download from Kaggle — see Dataset)
├── mh_4510_report_r_latex_latest.Rmd          # Main R Markdown source — analysis, models, and report
├── references.bib                             # BibTeX references
├── advances-in-computational-mathematics.csl  # Citation style
├── images/
│   └── logo.png                               # NTU logo used in the report header
└── README.md
```

---

## Dataset

**Source:** [`DataCo SMART Supply Chain for Big Data Analysis`](https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis) on Kaggle

A transaction-level dataset of global supply chain orders with the following characteristics:

| Metric | Value |
|---|---|
| Total Orders | 180,519 |
| Unique Customers | 20,652 |
| Countries Served | 164 |
| Product Categories | 11 |
| Order Date Range | January 2015 – January 2018 |

Each row represents a single transaction. See the Appendix in the project report for full field descriptions.

A supplementary geocoding step was performed using the **Google Cloud Geocoding API** to retrieve latitude/longitude coordinates for each unique `Order City, Order Country` pair (3,665 pairs), enabling distance-based feature engineering.

### Preprocessing

The full pipeline is contained in `mh_4510_report_r_latex_latest.Rmd`. Knit the document in RStudio to reproduce all results. The preprocessing pipeline covers:

1. **Data Cleaning** — removes columns with >80% NA values, zero-variance columns, duplicate records, and records with out-of-range values (e.g. negative sales, invalid coordinates)
2. **Feature Engineering** — computes `delivery_distance_km` using the Haversine formula from source and destination coordinates
3. **Customer-Level Aggregation** — aggregates all transaction variables by `Customer.Id` using sum, mean and count functions to produce a single behavioural profile per customer
4. **Feature Selection** — removes low-variance and redundant features; retains behavioural metrics most relevant to clustering
5. **PCA** — reduces dimensionality while retaining 86.5% of total variance, ensuring stable and interpretable clustering

---

## Models

### K-Means (k = 6)

Centroid-based hard partitioning. The optimal k was selected via the elbow method and silhouette analysis. Produces 6 well-separated, compact clusters suitable for direct business interpretation.

### DBSCAN

Density-based clustering that identifies arbitrarily shaped clusters and explicitly labels outliers as noise. Particularly useful for detecting anomalous customer profiles indicating potential operational errors or fraud. Key hyperparameters (ε and minPts) were tuned using a k-distance plot.

### Gaussian Mixture Model (k = 6)

Model-based soft clustering using probabilistic assignments. Customers can have partial membership across segments, capturing overlapping behavioural tendencies missed by hard partitioning.

---

## Results

### Multi-Criteria Evaluation

Clustering performance was assessed using a weighted composite score across five internal validity indices:

$$\text{Score}_m = 0.30 \times S_m + 0.25 \times (1 - DB_m) + 0.25 \times CH_m + 0.10 \times D_m + 0.10 \times VE_m$$

| Method | K | Silhouette | Davies-Bouldin | Calinski-Harabasz | Dunn | Var Exp (%) | Score |
|--------|---|------------|----------------|-------------------|------|-------------|-------|
| **K-Means** | 6 | 0.3560 | 1.1456 | 5350.94 | 0.0086 | 51.19 | **0.7479** |
| DBSCAN | 2 | 0.5413 | 0.9023 | 2273.85 | 0.2465 | 21.19 | 0.6500 |
| GMM | 6 | 0.0932 | 2.9103 | 2320.63 | 0.0030 | 51.19 | 0.1038 |

K-Means achieved the highest weighted score, confirming it as the most balanced and interpretable method for this task.

### K-Means Cluster Profiles (Summary)

- **Cluster 1** — High-value customers generating negative profits due to heavy discounts or returns; highest financial risk
- **Cluster 2** — Small, highly profitable premium group; ideal for prioritised or loyalty service
- **Cluster 3** — Core customer base with frequent purchases and stable profitability
- **Cluster 4** — Moderate-value customers with high late-delivery rates; indicates logistics inefficiencies
- **Cluster 5** — Low-spending but reliable customers with healthy margins
- **Cluster 6** — Moderate spending with extremely high late-delivery rates; potential churn risk

DBSCAN additionally identified 52 anomalous customers (0.3% of total) with extreme negative profits, flagged as potential operational errors or fraud.

---

## Setup

### 1. Install R and RStudio

Download and install [R](https://cran.r-project.org/) and [RStudio](https://posit.co/download/rstudio-desktop/).

### 2. Install required R packages

Open RStudio and run the following in the console:

```r
install.packages(c(
  "tidyverse", "knitr", "kableExtra", "readr", "lubridate",
  "janitor", "corrplot", "car", "caret", "cluster", "factoextra",
  "ggplot2", "gridExtra", "dbscan", "mclust", "clusterSim",
  "clValid", "fpc", "plotly", "bookdown"
))
```

### 3. Download the dataset

Download `DataCoSupplyChainDataset.csv` from [Kaggle](https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis) and place it in the `dataset/` directory.

### 4. (Optional) Configure geocoding credentials

If re-running the geocoding step, you will need a Google Cloud API key with the Geocoding API enabled. The pre-geocoded coordinate file is included in `dataset/` so this step can be skipped.

---

## Running the Project

Open `mh_4510_report_r_latex_latest.Rmd` in RStudio and knit to PDF or HTML. The document is fully self-contained — all data cleaning, feature engineering, PCA, modelling, and evaluation are executed inline when knitted.

> **Note:** Knitting to PDF requires a LaTeX distribution (e.g. [TinyTeX](https://yihui.org/tinytex/)). Install it from RStudio with:
> ```r
> install.packages("tinytex")
> tinytex::install_tinytex()
> ```

---

## References

- Jain, A.K. (2010). [Data clustering: 50 years beyond k-means](https://doi.org/10.1016/j.patrec.2009.09.011)
- Ester et al. (1996). A density-based algorithm for discovering clusters in large spatial databases with noise. *KDD*, pp. 226–231
- McLachlan, G.J., Lee, S.X., Rathnayake, S.I. (2019). [Finite mixture models](https://doi.org/10.1146/annurev-statistics-031017-100325)
- Tiwari et al. (2018). [Big data analytics in supply chain management](https://doi.org/10.1016/j.cie.2017.11.017)
- Jolliffe, I.T., Cadima, J. (2016). [Principal component analysis: a review and recent developments](https://doi.org/10.1098/rsta.2015.0202)
