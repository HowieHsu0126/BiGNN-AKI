# GNN-Based Early Detection of Acute Kidney Injury: Integrating Multivariate Time Series and Patient Cohort Analysis

## Overview

This repository contains a collection of PostgreSQL scripts designed for the analysis and early detection of Acute Kidney Injury (AKI) using clinical data from databases like MIMIC-IV and eICU-CRD 2.0. The scripts utilize a combination of creatinine measurements, urine output data, and patient treatment records to identify and categorize AKI instances.

## Idea

In this study, we propose a model based on graph neural networks aimed at the early detection of patients with Acute Kidney Injury (AKI). Initially, we extracted time-series data and related indicators for both AKI and non-AKI patients from the MIMIC-IV and eICU-CRD 2.0 databases. This data reflects the patients' physiological states and clinical pathways, offering a rich source of information for deep learning. Subsequently, we employed graph neural networks for representational learning of these multivariate time series, capturing not only the temporal dynamic characteristics within individuals but also revealing complex relationships between patient cohorts through inter-patient graph representation learning. In this manner, we transformed the task of early AKI patient detection into a graph node anomaly detection problem, aiming to identify nodes behaving anomalously within the graph, i.e., early-stage AKI patients. The innovation of our model lies in its ability to integrate a wealth of clinical data and leverage advanced graph representation techniques, providing robust support for clinical decision-making. Consequently, it facilitates early recognition and intervention of AKI in clinical practice, thereby improving patient outcomes.

## Files Description

- **aki_cr.sql**: Defines the view for AKI detection based on creatinine ratios within 48 hours and 7 days.
- **aki_final.sql**: Compiles the final AKI status by combining creatinine and urine output diagnostics with considerations for Renal Replacement Therapy (RRT).
- **aki_rrt.sql**: Identifies patients who have received renal replacement therapies prior to ICU admission, indicating chronic AKI conditions.
- **aki_uo.sql**: Determines AKI status based on urine output criteria as per KDIGO guidelines, calculating per-hour urine volume against patient weight.
- **cr_7d.sql**: Calculates peak creatinine levels within a 7-day window.
- **cr_48h.sql**: Identifies peak creatinine levels within the first 48 hours of ICU admission.
- **cr_baseline.sql**: Establishes baseline creatinine levels for patients upon ICU admission.
- **main.sql**: Acts as the primary script importing other SQL files and orchestrating the workflow.
- **patient_weight.sql**: Creates a table for patient weights, crucial for calculations in other scripts.

## Usage

The SQL scripts are designed to be run in a sequential manner:

1. **Set up the environment**: Ensure that your database environment is compatible with the scripts, typically PostgreSQL or a similar system.
   
2. **Run the scripts**: Start with `main.sql`, which will guide the order of execution. Ensure that all dependent views and tables are created before running scripts that rely on them.

3. **Data Analysis**: After running the scripts, use the resulting data to analyze AKI incidence, progression, and potential treatment paths.

## Dependencies

- A database containing MIMIC-IV or eICU-CRD 2.0 data.
- PostgreSQL environment capable of executing complex queries and view creation.

## Contributing

We welcome contributions and enhancements to these scripts. Please provide a clear description of your changes and their benefits.
