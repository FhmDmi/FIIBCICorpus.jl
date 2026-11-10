| Documentation | CI | EEG BCI Data | Ecosystem |
|:-----:|:-----:|:-----:|:-----:|
| [![](https://img.shields.io/badge/docs-dev-blue.svg)](https://fhmdmi.github.io/FIIBCIcorpus.jl/dev/) | [![CI](https://github.com/FhmDmi/FIIBCIcorpus.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/FhmDmi/FIIBCIcorpus.jl/actions/workflows/CI.yml) | [![](https://img.shields.io/badge/Motor_Imagery-blue.svg)](https://doi.org/10.5281/zenodo.17801878) [![](https://img.shields.io/badge/P300-blue.svg)](https://doi.org/10.5281/zenodo.17250465) | [![](https://img.shields.io/badge/Eegle-blue.svg)](https://github.com/Marco-Congedo/Eegle.jl) |

# FIIBCIcorpus

**FIIBCIcorpus** is the data loader of the [**Eegle**](https://github.com/Marco-Congedo/Eegle.jl) ecosystem
for the **FII BCI Corpus**, a selection of Brain-Computer Interface (BCI) EEG databases in Motor Imagery (MI)
and P300 paradigms, annotated and curated for research purposes in [NY format](https://fhmdmi.github.io/FIIBCIcorpus.jl/dev/documents/NY%20format/).

It provides:
- a web-based GUI to download the databases of the corpus from [Zenodo](https://zenodo.org/);
- tools to inspect the databases and select the sessions meeting given inclusion criteria (paradigm, classes, minimum number of trials, metadata);
- file system utilities.

The NY files are then read and processed with **Eegle**.

---

## 🧩 Requirements

**Julia**: version ≥ 1.12

---

## 📦 Installation

Execute the following command in Julia's REPL:

```julia
]add https://github.com/FhmDmi/FIIBCIcorpus.jl/tree/master
```

To read and process the NY files, also install [**Eegle**](https://github.com/Marco-Congedo/Eegle.jl), which is not a dependency of **FIIBCIcorpus**:

```julia
]add Eegle
```

and load both with `using Eegle, FIIBCIcorpus`.

Eegle 0.2.12 and earlier still export the database functions themselves: with these versions, write the names in full (`FIIBCIcorpus.selectDB`, `FIIBCIcorpus.downloadDB`, ...), since Julia leaves names exported by two packages undefined.

---

## —͟͟͞͞★ Quick Start

```julia
using FIIBCIcorpus

downloadDB() # run the GUI to download the corpus in the homedir

# select the MI sessions featuring classes "left_hand" and "right_hand",
# with more than 30 trials per class
DB_MI = selectDB(:MI;
                 classes = ["left_hand", "right_hand"],
                 inclusion = (("tpc", x -> minimum(values(x)) > 30),))
```

---

## ✍️ About the Authors

[Fahim Doumi](https://www.linkedin.com/in/fahim-doumi-4888a9251/?locale=fr_FR), corresponding author, is a PhD student at [University Federico II of Naples](https://www.unina.it/en_GB/home) and [UGA](https://www.univ-grenoble-alpes.fr/english/) (University of Grenoble Alpes). **Contact**: fahim dot doumi dot pro at gmail dot com.

[Marco Congedo](https://sites.google.com/site/marcocongedo) is a Research Director of [CNRS](http://www.cnrs.fr/en) (Centre National de la Recherche Scientifique), working at UGA.

---

## 🧑‍💻 Contributors

| Contributor | Contribution |
|:----------|:----------|
| [Abdeljalil Anajjar](https://github.com/AbdeljalilAnajjar) | original web GUI for downloading the FII BCI Corpus |
