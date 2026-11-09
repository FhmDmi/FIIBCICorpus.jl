```@meta
CurrentModule = FIIBCICorpus
```

# FIIBCICorpus

Is the data loader of the [Eegle](https://marco-congedo.github.io/Eegle.jl/dev/) ecosystem.
It is organized as a collection of modules, which are all re-exported. Thus, if you state

```julia
using FIIBCICorpus
```

you have access to all functions exported by all **FIIBCICorpus** modules.
Since **Eegle** re-exports **FIIBCICorpus**, `using Eegle` gives access to them as well.

## Internal modules

| Code Unit   | Description |
|:------------|:------------|
| [DownloadFII.jl](@ref) | download and locate the FII BCI Corpus |
| [Database.jl](@ref) | summarize and select databases and sessions in NY format |

## Used but not re-exported external packages

!!! details "show me"

    |  Package | Scope |
    |:-----------------------|:-----------------------|
    | [Bonito](https://github.com/SimonDanisch/Bonito.jl)| build interactive web applications, dashboards, and visualizations |
    | [DataFrames](https://github.com/JuliaData/DataFrames.jl) | manipulation of tables|
    | [Downloads](https://github.com/JuliaLang/Downloads.jl) | standard Julia download functionality |
    | [HTTP](https://github.com/JuliaWeb/HTTP.jl)| Support for *HTTP* |
    | [IsURL](https://github.com/zlatanvasovic/IsURL.jl)| utilities to work with URLs |
    | [JSON](https://github.com/JuliaIO/JSON.jl)| Support for the *JSON* data format |
    | [NativeFileDialog](https://github.com/JuliaGraphics/NativeFileDialog.jl)| native OS dialogs, e.g., for selecting files |
    | [Reexport](https://github.com/simonster/Reexport.jl)| re-export the modules of the package |
    | [YAML](https://github.com/JuliaData/YAML.jl)| support for the *YAML* data format |
    | [ZipFile](https://github.com/fhs/ZipFile.jl)| read and write *ZIP* archives |
