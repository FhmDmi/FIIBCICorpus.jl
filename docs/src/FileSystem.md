```@meta
CurrentModule = FIIBCICorpus
```

## FileSystem.jl

This module implements utilities for **working with files and directories**.

It is a complement to the standard
[Julia FileSystem](https://docs.julialang.org/en/v1/base/file/) module.

|  Function      |           Description             |
|:-----------------------|:----------------------------------|
| [`FIIBCICorpus.FileSystem.fileBase`](@ref) | get a file path without the extension|
| [`FIIBCICorpus.FileSystem.fileExt`](@ref) | extract the extension from a file name, including the dot |
| [`FIIBCICorpus.FileSystem.changeFileExt`](@ref) | change the extension of a file |
| [`FIIBCICorpus.FileSystem.getFilesInDir`](@ref) | search for files in a directory and its subdirectories |
| [`FIIBCICorpus.FileSystem.getFoldersInDir`](@ref) | search for directories in a directory and its subdirectories |
📖
```@docs
    FIIBCICorpus.FileSystem.fileBase
    FIIBCICorpus.FileSystem.fileExt
    FIIBCICorpus.FileSystem.changeFileExt
    FIIBCICorpus.FileSystem.getFilesInDir
    FIIBCICorpus.FileSystem.getFoldersInDir
```
