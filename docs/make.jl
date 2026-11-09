# Nota Bene: Run it while in the \docs environment

using Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate() # local FIIBCIcorpus via [sources] in docs/Project.toml (`Pkg.develop` would store an absolute path)

using Documenter
## ADD HERE ALL MODULES!
using   FIIBCIcorpus,
        FIIBCIcorpus.DownloadFII,
        FIIBCIcorpus.Database

CI = get(ENV, "CI", "false") == "true"

makedocs(;
   sitename="FIIBCIcorpus",
   authors="Fahim Doumi, Marco Congedo and Contributors",
   format = Documenter.HTML(; prettyurls = CI, edit_link = "master"),
   modules = [FIIBCIcorpus, FIIBCIcorpus.DownloadFII, FIIBCIcorpus.Database],
   # explicit, so that the local build does not depend on the `origin` remote of the clone
   repo = Remotes.GitHub("FhmDmi", "FIIBCIcorpus.jl"),
 pages = [
        "index.md",
        "🗄️ FIIBCIcorpus Package" => "FIIBCIcorpus.md",
        "🧠 FIIBCIcorpus Modules" => [
            "Download" => "DownloadFII.md",
            "Database" => "Database.md",
        ],
        "📚 FII BCI Corpus" => [
            "FII BCI Corpus" => "documents/FII BCI Corpus Overview.md",
            "Terminology" => "documents/Terminology.md",
            "Summary of MI Databases" => "documents/Summary of MI Databases.md",
            "Treatment MI" => "documents/Treatment MI.md",
            "Summary of P300 Databases" => "documents/Summary of P300 Databases.md",
            "Treatment P300" => "documents/Treatment P300.md",
            "NY format"=> "documents/NY format.md",
            "NY metadata (YAML)" => "documents/yamlstruct.md",
            "Benchmark" => "documents/Benchmark.md",
        ],
    ]
)

if CI
    deploydocs(
        repo = "github.com/FhmDmi/FIIBCIcorpus.jl.git",
        branch = "gh-pages",
        devbranch = "master",
        push_preview = false,
    )
else
    include("local_run.jl")  # optional local run
end
