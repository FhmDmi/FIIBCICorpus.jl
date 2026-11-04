# BCI FII Corpus Benchmark

This document reports the results of a benchmark run on the [FII BCI Corpus](@ref "FII BCI Corpus Overview") using **Eegle**.

Only subjects/sessions that passed *all exclusion criteria* described in the *@discarded.md* file (see it for [MI](https://zenodo.org/records/21687278/files/@discarded.md?download=1)) were included in this benchmark.

Individual subject/session accuracies are included in the `.yml` [metadata files](@ref "NY Metadata (YAML)") and are also available in CSV format in this [GitHub repository](https://github.com/FhmDmi/Eegle-Tools/tree/master/Within-Session-Evaluation/results). The repository also hosts the scripts used to make this benchmark and more information. 

This document reports the mean(±sd) balanced accuracies for each database according to the analyzed tasks:
    - MI: "right_hand" vs. "feet" and "left_hand" vs. "right_hand" 

## Available Classifiers

The benchmark has employed three Riemannian classifiers, all adopting the affine-invariant (Fisher-Rao) [metric](https://marco-congedo.github.io/PosDefManifold.jl/stable/introToRiemannianGeometry/):

**Native classifiers** (acting on the manifold); the metric is used for computing distances and barycenters:

- **MDM** (Minimum Distance to Mean).

**Tangent space classifiers**; the metric is used to compute a barycenter for projecting the data onto the tangent space:

- **ENLR** (Elastic Net Logistic Regression) 
- **Linear SVM** (Linear Support Vector Machine).

---

## Processing Pipelines

The default pipeline implementd by the [`crval`](https://marco-congedo.github.io/Eegle.jl/dev/BCI/#PosDefManifoldML.crval) function has bene used with the following two customizations:

- Stratified K-Fold (K=10) instead of the default 8-fold
- Seed set to 109 (instead of default 1234).

---

## Motor Imagery (MI) Benchmark Results

### Task: right_hand vs. feet

!!! details "show me"

    | Database | MDM (%) | ENLR (%) | SVM (%) |
    |----------|---------|----------|----------|
    | AlexMI-None | 73.75 ± 18.03 | 79.06 ± 15.64 | 75.31 ± 13.39 |
    | BNCI2014001-None | 85.13 ± 12.2 | 87.66 ± 10.01 | 86.33 ± 11.05 |
    | BNCI2014002-Test | 80.77 ± 15.81 | 81.22 ± 17.43 | 81.92 ± 14.58 |
    | BNCI2014002-Train | 77.07 ± 11.4 | 77.41 ± 11.19 | 74.07 ± 13.87 |
    | BNCI2015001-None | 81.62 ± 13.08 | 84.6 ± 10.18 | 78.94 ± 12.42 |
    | Schirrmeister2017-None | 86.13 ± 12.67 | 96.48 ± 4.52 | 97.07 ± 3.62 |
    | Weibo2014-None | 61.94 ± 9.56 | 86.5 ± 8.99 | 81.72 ± 8.32 |
    | Zhou2016-None | 87.33 ± 6.76 | 92.71 ± 3.99 | 87.45 ± 8.41 |

### Task: left_hand vs. right_hand

!!! details "show me"

    | Database | MDM (%) | ENLR (%) | SVM (%) |
    |----------|---------|----------|----------|
    | BNCI2014001-None | 77.75 ± 13.99 | 78.31 ± 15.05 | 78.85 ± 14.27 |
    | BNCI2014004-Test | 78.9 ± 12.41 | 80.73 ± 12.06 | 78.59 ± 12.58 |
    | BNCI2014004-Train | 66.15 ± 9.95 | 68.82 ± 9.63 | 66.92 ± 9.63 |
    | Cho2017-None | 64.96 ± 9.42 | 73.57 ± 10.51 | 69.54 ± 10.07 |
    | GrosseWentrup2009-None | 60.12 ± 8.38 | 86.17 ± 10.93 | 82.23 ± 10.81 |
    | Lee2019_MI-Train | 66.2 ± 13.26 | 79.72 ± 11.97 | 75.38 ± 13.15 |
    | PhysionetMI-Task 2 | 55.59 ± 16.31 | 77.16 ± 11.18 | 63.16 ± 12.92 |
    | SPSM2025-None | 62.49 ± 7.5 | 66.68 ± 7.74 | 60.08 ± 9.14 |
    | Schirrmeister2017-None | 65.26 ± 16.51 | 83.12 ± 11.93 | 82.08 ± 12.21 |
    | Shin2017A-None | 61.67 ± 18.58 | 79.74 ± 15.52 | 73.08 ± 17.46 |
    | Weibo2014-None | 55.14 ± 11.93 | 81.66 ± 10.97 | 74.52 ± 16.58 |
    | Zhou2016-None | 84.52 ± 7.76 | 87.2 ± 8.49 | 82.46 ± 9.31 |

