# GNN-Based Early Detection of Acute Kidney Injury: Integrating Multivariate Time Series and Patient Cohort Analysis

## Overview

In this study, we propose a model based on graph neural networks aimed at the early detection of patients with Acute Kidney Injury (AKI). Initially, we extracted time-series data and related indicators for both AKI and non-AKI patients from the MIMIC-IV and eICU-CRD 2.0 databases. This data reflects the patients' physiological states and clinical pathways, offering a rich source of information for deep learning. Subsequently, we employed graph neural networks for representational learning of these multivariate time series, capturing not only the temporal dynamic characteristics within individuals but also revealing complex relationships between patient cohorts through inter-patient graph representation learning. In this manner, we transformed the task of early AKI patient detection into a graph node anomaly detection problem, aiming to identify nodes behaving anomalously within the graph, i.e., early-stage AKI patients. The innovation of our model lies in its ability to integrate a wealth of clinical data and leverage advanced graph representation techniques, providing robust support for clinical decision-making. Consequently, it facilitates early recognition and intervention of AKI in clinical practice, thereby improving patient outcomes.

## Contributing

We welcome contributions and enhancements to these scripts. Please provide a clear description of your changes and their benefits.
