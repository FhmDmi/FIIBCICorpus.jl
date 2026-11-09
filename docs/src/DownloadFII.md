```@meta
CurrentModule = FIIBCIcorpus
```

## DownloadFII.jl

This module downloads the databases of the
[FII BCI Corpus](@ref "FII BCI Corpus Overview")
and locates them on disk.

By default, the corpus is downloaded in folder *FII_BCI_Corpus* in the *homedir*
(e.g., `C:\Users\Name\FII_BCI_Corpus` on Windows), where [`selectDB`](@ref FIIBCIcorpus.Database.selectDB) finds it automatically.

## Methods

|  Function            |           Description             |
|:---------------------|:----------------------------------|
|[`FIIBCIcorpus.DownloadFII.downloadDB`](@ref)    | run a web-based GUI to download the FII BCI corpus |
|[`FIIBCIcorpus.DownloadFII.corpusDir`](@ref)     | return the default directory of the FII BCI corpus |

📖
```@docs
    FIIBCIcorpus.DownloadFII.downloadDB
    FIIBCIcorpus.DownloadFII.corpusDir
```
