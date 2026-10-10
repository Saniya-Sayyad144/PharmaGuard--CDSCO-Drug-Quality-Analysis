# PharmaGuard | Drug Quality Intelligence & Analytics

<p align="center">
  <strong>End-to-End Data Analytics Project</strong><br>
  SQL • Python • Excel • Power BI
</p>

---

## Project Overview

**PharmaGuard** is an end-to-end data analytics project focused on analyzing *Not of Standard Quality (NSQ)* drug records published by the Central Drugs Standard Control Organisation (CDSCO), India.

The project transforms raw drug-quality records into a structured analytical dataset and interactive Power BI dashboards. It demonstrates a complete data analytics workflow, from data preparation and cleaning to querying, analysis, visualization, and reporting.

## Business Objective

The objective is to explore reported drug-quality issues, identify patterns across products and manufacturers, understand changes over time, and present the findings through interactive dashboards that support data exploration and informed analysis.

## Technology Stack

| Technology | Application |
|---|---|
| SQL | Data querying, filtering, aggregation, and analysis |
| Python | Data processing and analysis using libraries such as Pandas and NumPy, where used |
| Microsoft Excel | Data inspection, validation, and preliminary analysis |
| Power BI | Interactive dashboards, KPI cards, charts, and detailed records |
| DAX | Measures and analytical calculations within Power BI |
| Power Query | Data transformation and preparation |

## Project Workflow

1. **Data Collection** — Gathered CDSCO NSQ drug records for the selected reporting period.
2. **Data Cleaning** — Processed missing values, duplicate records, inconsistent text, and column formats.
3. **Data Transformation** — Standardized relevant fields and prepared the dataset for analysis.
4. **SQL Analysis** — Queried and aggregated records to investigate relevant patterns.
5. **Python Analysis** — Used Python libraries for data preparation and analytical tasks.
6. **Data Modeling** — Organized fields and created analytical measures in Power BI.
7. **Dashboard Development** — Built interactive visualizations and detailed records views.
8. **Insight Exploration** — Used filters and charts to investigate patterns across reporting periods, products, manufacturers, and locations.

## Power BI Dashboard

The report is organized into five analytical pages:

### 1. Executive Overview
- High-level NSQ record indicators
- Reporting trends over time
- Summary of quality issue categories
- Interactive report filters

### 2. Quality Analysis
- Distribution of reported quality issues
- Comparison of issue categories
- Analysis of NSQ results
- Time-based quality reporting patterns

### 3. Product & Manufacturer Analysis
- Products with the highest numbers of reported NSQ records
- Manufacturer-level record comparisons
- Product and manufacturer filtering
- Exploration of recurring reported quality concerns

### 4. Laboratory & Geography
- Analysis by reporting laboratory or source
- Geographic exploration using available location fields
- State-wise distribution based on the dataset's location information
- Comparison across reporting sources, where available

### 5. Detailed NSQ Records
- Searchable or filterable record exploration
- Product and manufacturer information
- Batch and reporting details
- Quality issue descriptions and NSQ results
- Interactive filtering and record-level inspection

## Key Analytical Questions

This project is designed to investigate questions such as:

- How do reported NSQ record counts change over time?
- Which quality issue categories appear most frequently?
- Which products and manufacturers have the highest numbers of reported records?
- How are records distributed across the available geographic fields?
- How do reporting laboratories or sources differ in the records available?
- Which individual records require closer inspection?

These questions describe the analytical scope; findings should be established from the actual dataset and dashboard results.

## Dataset Information

**Data source:** Central Drugs Standard Control Organisation (CDSCO), India.

**Subject:** Not of Standard Quality (NSQ) drug records.

**Reporting period:** 2019–2026, subject to the coverage and completeness of the collected data.

The dataset includes relevant fields such as reporting year and month, product, batch, manufacturer, NSQ result, quality issue, and reporting laboratory or source, where available.

## Data Interpretation & Limitations

- NSQ records represent reported quality concerns; they are not a count of all drug samples tested.
- Record counts alone cannot establish an overall drug failure rate without the total number of samples tested.
- A higher number of records for a product or manufacturer does not, by itself, establish a higher failure probability or prove wrongdoing.
- Geographic analysis must be interpreted according to the meaning of the underlying location field.
- Conclusions depend on data completeness, consistency, reporting coverage, and classification quality.

## Repository Structure

```text
PharmaGuard-Drug-Quality-Analysis/
│
├── README.md
├── data/
│   └── sample_data.csv
├── sql/
│   └── analysis_queries.sql
├── python/
│   └── data_cleaning.py
├── excel/
│   └── analysis_workbook.xlsx
├── powerbi/
│   └── PharmaGuard.pbix
└── screenshots/
    ├── executive_overview.png
    ├── quality_analysis.png
    ├── product_manufacturer.png
    ├── laboratory_geography.png
    └── detailed_records.png
```

*The structure above is illustrative. Keep only files and folders that actually exist in your repository, and replace example filenames with your real filenames.*

## How to Explore the Project

1. Clone or download this repository.
2. Open the SQL scripts to review the analytical queries.
3. Review the Python scripts and Excel workbook, if included.
4. Open the `.pbix` file using Microsoft Power BI Desktop.
5. Update the data source path if prompted.
6. Refresh the data and interact with the report filters and visualizations.

## Project Outcomes

This project demonstrates practical application of:

- Data cleaning and preparation
- SQL-based querying and aggregation
- Python-based data processing
- Excel-based data inspection
- Power BI data modeling and visualization
- DAX measures and interactive filtering
- Analytical reporting and data interpretation

## Disclaimer

This project is intended for educational and portfolio purposes. It is an independent analysis of publicly available or otherwise permitted data and should not be interpreted as an official CDSCO assessment, a regulatory determination, or a substitute for laboratory testing.

## Author

**Saniya Sayyad**  
BE Information Technology Graduate | Aspiring Data Analyst

**Areas of interest:** Data Analytics • SQL • Python • Excel • Power BI

---

*If you find this project useful, feel free to explore the repository and review the dashboard screenshots.*