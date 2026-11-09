```@meta
CurrentModule = FIIBCIcorpus
```

## Database.jl

This module implements tools to facilitate the work with EEG databases, in particular, **BCI databases** in **NY format** — see the [FII BCI Corpus Overview](@ref "FII BCI Corpus Overview").

To learn how to use BCI databases, see [Tutorial ML 2](https://marco-congedo.github.io/Eegle.jl/dev/Tutorials/Tutorial%20Machine%20Learning%202/) of **Eegle**.

Most functionalities of this module are also encapsulated in the [pyLittleEegle](https://github.com/FhmDmi/pyLittleEegle) package for the Python language.


## Structures

|  Function            |           Description             |
|:---------------------|:----------------------------------|
|[`FIIBCIcorpus.Database.InfoDB`](@ref)      | structure holding the information summarizing an EEG-BCI database |

## Methods

|  Function            |           Description             |
|:---------------------|:----------------------------------|
|[`FIIBCIcorpus.Database.loadDB`](@ref)        | return a list of *.npz* files in a directory (this is considered a [database](@ref "database")) |
|[`FIIBCIcorpus.Database.infoDB`](@ref)        | print, save and return metadata about a database |
|[`FIIBCIcorpus.Database.selectDB`](@ref)      | select databases and sessions based on inclusion criteria
|[`FIIBCIcorpus.Database.weightsDB`](@ref)     | get weights for each session of a database for statistical analysis |

📖
```@docs
    FIIBCIcorpus.Database.InfoDB
    FIIBCIcorpus.Database.loadDB
    FIIBCIcorpus.Database.infoDB
    FIIBCIcorpus.Database.selectDB
    FIIBCIcorpus.Database.weightsDB
```
