```@meta
CurrentModule = FIIBCICorpus
```

## Database.jl

This module implements tools to facilitate the work with EEG databases, in particular, **BCI databases** in **NY format** — see the [FII BCI Corpus Overview](@ref "FII BCI Corpus Overview").

To learn how to use BCI databases, see [Tutorial ML 2](https://marco-congedo.github.io/Eegle.jl/dev/Tutorials/Tutorial%20Machine%20Learning%202/) of **Eegle**.

Most functionalities of this module are also encapsulated in the [pyLittleEegle](https://github.com/FhmDmi/pyLittleEegle) package for the Python language.


## Structures

|  Function            |           Description             |
|:---------------------|:----------------------------------|
|[`FIIBCICorpus.Database.InfoDB`](@ref)      | structure holding the information summarizing an EEG-BCI database |

## Methods

|  Function            |           Description             |
|:---------------------|:----------------------------------|
|[`FIIBCICorpus.Database.loadDB`](@ref)        | return a list of *.npz* files in a directory (this is considered a [database](@ref "database")) |
|[`FIIBCICorpus.Database.infoDB`](@ref)        | print, save and return metadata about a database |
|[`FIIBCICorpus.Database.selectDB`](@ref)      | select databases and sessions based on inclusion criteria
|[`FIIBCICorpus.Database.weightsDB`](@ref)     | get weights for each session of a database for statistical analysis |

📖
```@docs
    FIIBCICorpus.Database.InfoDB
    FIIBCICorpus.Database.loadDB
    FIIBCICorpus.Database.infoDB
    FIIBCICorpus.Database.selectDB
    FIIBCICorpus.Database.weightsDB
```
