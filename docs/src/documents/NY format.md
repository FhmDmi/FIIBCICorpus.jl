# NY format

The NY (New York) format is specifically conceived for BCI data. It holds data and metadata and allow convenient handling of BCI data in any programming language.

!!! note
    When converted to NY format, the EEG data is stored in microvolts (*µ*V), as it is the standard in the EEG community.

The NY format consists of two files with same name and different extension:

- **`.npz file`**: contains the raw data and [stimulation vector](https://marco-congedo.github.io/Eegle.jl/dev/ERPs/#stimulation-vector). The *.npz* file is the standard [NumPy](https://numpy.org/) compressed archive format, which can store multiple arrays in a single file using ZIP compression. The file contains two arrays:
  - `X`: the``N×T`` EEG data matrix, where ``N`` and ``T`` denotes the number of samples and channels, respectively, in Float32 *µ*V format.
  - `stim`: the stimulation vector holding the ``T`` tags for the samples.

  This format is natively supported in Python through NumPy and easily readable in Julia via the [NPZ.jl](https://github.com/fhs/NPZ.jl) package.

- **`.yml file`**: stores metadata offering a comprehensive description of the dataset's characteristics — see [YAML Structure](yamlstruct.md). 

!!! tip
    NY files in **Eegle** are read using function [`readNY`](https://marco-congedo.github.io/Eegle.jl/dev/InOut/#Eegle.InOut.readNY), which creates an [`EEG`](https://marco-congedo.github.io/Eegle.jl/dev/InOut/#Eegle.InOut.EEG) structure holding both the data and the metadata.

## Converters

All scripts for data conversion between formats (Base repository/MOABB to CSV and CSV to NY), tailored to each dataset's requirements, are available in [this GitHub repository](https://github.com/FhmDmi/Eegle-Tools/tree/master/Converters).

