# FIIBCIcorpus Documentation

**FIIBCIcorpus** is the data loader of the [Eegle](https://marco-congedo.github.io/Eegle.jl/dev/) ecosystem
for the [FII BCI Corpus](@ref "FII BCI Corpus Overview").

It downloads the databases of the corpus in [NY format](@ref "NY format").
The NY files are then read and processed with **Eegle**, which depends on **FIIBCIcorpus** and re-exports it.

## 🧩 Requirements 

**Julia**: version ≥ 1.13

---

## ⚙️ Installation

Execute the following commands in Julia's REPL:

```julia
]add https://github.com/FhmDmi/FIIBCIcorpus.jl/tree/master
```
then hit the 'back' keyboard key to exit the REPL package manager mode.

---

## —͟͟͞͞★ Quick Start

```julia
using FIIBCIcorpus

downloadDB() # run the GUI to download the corpus in the homedir
```

Read the [next page](@ref "FIIBCIcorpus") of this documentation for general informations.

---

## ✍️ About the Authors

[Fahim Doumi](https://www.linkedin.com/in/fahim-doumi-4888a9251/?locale=fr_FR), corresponding author, is a PhD student at [University Federico II of Naples](https://www.unina.it/en_GB/home) and [UGA](https://www.univ-grenoble-alpes.fr/english/) (University of Grenoble Alpes). **Contact**: fahim dot doumi dot pro at gmail dot com.

[Marco Congedo](https://sites.google.com/site/marcocongedo) is a Research Director of [CNRS](http://www.cnrs.fr/en) (Centre National de la Recherche Scientifique), working at UGA.

---

## 🧑‍💻 Contributors

| Contributor | Contribution |
|:----------|:----------|
| [Abdeljalil Anajjar](https://github.com/AbdeljalilAnajjar) | original web GUI for downloading the FII BCI Corpus |

---

## 🧪 Package Test

```julia
using Pkg
Pkg.test("FIIBCIcorpus")
```

---

## ➡️ Contents

```@contents
Pages = [       "index.md",
                "FIIBCIcorpus.md",
                "DownloadFII.md",
                "Database.md",
                "documents/FII BCI Corpus Overview.md",
                "documents/Terminology.md",
                "documents/Summary of MI Databases.md",
                "documents/Treatment MI.md",
                "documents/Summary of P300 Databases.md",
                "documents/Treatment P300.md",
                "documents/NY format.md",
                "documents/yamlstruct.md",
                "documents/Benchmark.md",
		]
Depth = 1
```

---

## 🧭 Index

```@index
```
