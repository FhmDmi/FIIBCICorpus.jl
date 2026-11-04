module FIIBCICorpus

using Reexport

# Module REPL text colors
const titleFont     = "\x1b[95m"
const separatorFont = "\x1b[35m"
const defaultFont   = "\x1b[0m"
const greyFont      = "\x1b[90m"

export FIIBCICorpus

include("FileSystem.jl");       @reexport using .FileSystem
include("DownloadFII.jl");      @reexport using .DownloadFII
# modules with internal dependencies
include("Database.jl");         @reexport using .Database

end # module
