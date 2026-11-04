using Downloads

# Metadata describing each database in the corpus (type, classes, URL, etc.).
struct DBMeta
    name :: String
    paradigm :: Symbol
    classes :: Union{Vector{String}, Nothing} 
    minTrials :: Union{Int, Nothing} 
    url :: String
end

# Name of the corpus folder. Its default location is the homedir (as `~/mne_data` for MOABB),
# so that it does not depend on the Julia or package installation.
const CORPUS_DIR = "FII_BCI_Corpus"


# Zenodo API URLs for MI and P300 files.
const MIpath = "https://zenodo.org/api/records/21687278/files/" 
const P300path = "https://zenodo.org/api/records/21688242/files/"


# Available MI and P300 class labels in the corpus.
const MI_CLASSES = ["left_hand", "right_hand", "feet", "rest", "both_hands", "tongue"] # order of the standardized labels of `Eegle.readNY`
const P300_CLASSES = ["target", "nontarget"]

# Complete catalog of MI / P300 databases with their properties and URLs.
const DB_CATALOG = [
    # ==== MOTOR IMAGERY DATABASES ====
    DBMeta("AlexMI", :MI, ["right_hand", "feet", "rest"], 20,
        string(MIpath, "AlexMI.zip/content")),
    
    DBMeta("BNCI2014001", :MI, ["left_hand", "right_hand", "feet", "tongue"], 72,
        string(MIpath, "BNCI2014001.zip/content")),
    
    DBMeta("BNCI2014002-Train", :MI, ["right_hand", "feet"], 50,
        string(MIpath, "BNCI2014002-Train.zip/content")),
    
    DBMeta("BNCI2014002-Test", :MI, ["right_hand", "feet"], 30,
        string(MIpath, "BNCI2014002-Test.zip/content")),
    
    DBMeta("BNCI2014004-Train", :MI, ["left_hand", "right_hand"], 60,
        string(MIpath, "BNCI2014004-Train.zip/content")),
    
    DBMeta("BNCI2014004-Test", :MI, ["left_hand", "right_hand"], 60,
        string(MIpath, "BNCI2014004-Test.zip/content")),
    
    DBMeta("BNCI2015001", :MI, ["right_hand", "feet"], 100,
        string(MIpath, "BNCI2015001.zip/content")),
    
    DBMeta("Cho2017", :MI, ["left_hand", "right_hand"], 100,
        string(MIpath, "Cho2017.zip/content")),
    
    DBMeta("GrosseWentrup2009", :MI, ["left_hand", "right_hand"], 150,
        string(MIpath, "GrosseWentrup2009.zip/content")),
    
    DBMeta("Lee2019MI", :MI, ["left_hand", "right_hand"], 50,
        string(MIpath, "Lee2019MI.zip/content")),
    
    DBMeta("PhysionetMI-T2", :MI, ["left_hand", "right_hand"], 18,
        string(MIpath, "PhysionetMI-T2.zip/content")),
    
    DBMeta("PhysionetMI-T4", :MI, ["both_hands", "feet"], 18,
        string(MIpath, "PhysionetMI-T4.zip/content")),
    
    DBMeta("Schirrmeister2017", :MI, ["left_hand", "right_hand", "feet", "rest"], 120,
        string(MIpath, "Schirrmeister2017.zip/content")),
    
    DBMeta("Shin2017A", :MI, ["left_hand", "right_hand"], 10,
        string(MIpath, "Shin2017A.zip/content")),
    
    DBMeta("Weibo2014", :MI, ["left_hand", "right_hand", "both_hands", "feet", "rest"], 70,
        string(MIpath, "Weibo2014.zip/content")),
    
    DBMeta("Zhou2016", :MI, ["left_hand", "right_hand", "feet"], 45,
        string(MIpath, "Zhou2016.zip/content")),

    # ==== P300 DATABASES ====
    DBMeta("bi2012-T", :P300, ["target", "nontarget"], 126,
        string(P300path, "bi2012-T.zip/content")),
    
    DBMeta("bi2012-O", :P300, ["target", "nontarget"], 49,
        string(P300path, "bi2012-O.zip/content")),
    
    DBMeta("bi2013a-NAT", :P300, ["target", "nontarget"], 80,
        string(P300path, "bi2013a-NAT.zip/content")),
    
    DBMeta("bi2013a-NAO", :P300, ["target", "nontarget"], 26,
        string(P300path, "bi2013a-NAO.zip/content")),
    
    DBMeta("bi2013a-AT", :P300, ["target", "nontarget"], 80,
        string(P300path, "bi2013a-AT.zip/content")),
    
    DBMeta("bi2013a-AO", :P300, ["target", "nontarget"], 24,
        string(P300path, "bi2013a-AO.zip/content")),
    
    DBMeta("bi2014a", :P300, ["target", "nontarget"], 74,
        string(P300path, "bi2014a.zip/content")),
    
    DBMeta("bi2014b", :P300, ["target", "nontarget"], 24,
        string(P300path, "bi2014b.zip/content")),
    
    DBMeta("bi2015a-1", :P300, ["target", "nontarget"], 54,
        string(P300path, "bi2015a-1.zip/content")),
    
    DBMeta("bi2015a-2", :P300, ["target", "nontarget"], 54,
        string(P300path, "bi2015a-2.zip/content")),
    
    DBMeta("bi2015a-3", :P300, ["target", "nontarget"], 54,
        string(P300path, "bi2015a-3.zip/content")),
    
    DBMeta("BNCI2014009", :P300, ["target", "nontarget"], 96,
        string(P300path, "BNCI2014009.zip/content")),
    
    DBMeta("BNCI2015003-Train", :P300, ["target", "nontarget"], 75,
        string(P300path, "BNCI2015003-Train.zip/content")),
    
    DBMeta("BNCI2015003-Test", :P300, ["target", "nontarget"], 75,
        string(P300path, "BNCI2015003-Test.zip/content")),
    
    DBMeta("Cattan-PC", :P300, ["target", "nontarget"], 120,
        string(P300path, "Cattan-PC.zip/content")),
    
    DBMeta("Cattan-VR", :P300, ["target", "nontarget"], 120,
        string(P300path, "Cattan-VR.zip/content")),
    
    DBMeta("EPFLP300-1", :P300, ["target", "nontarget"], 20,
        string(P300path, "EPFLP300-1.zip/content")),
    
    DBMeta("EPFLP300-2", :P300, ["target", "nontarget"], 20,
        string(P300path, "EPFLP300-2.zip/content")),
    
    DBMeta("EPFLP300-3", :P300, ["target", "nontarget"], 21,
        string(P300path, "EPFLP300-3.zip/content")),
    
    DBMeta("EPFLP300-4", :P300, ["target", "nontarget"], 20,
        string(P300path, "EPFLP300-4.zip/content")),
    
    DBMeta("EPFLP300-5", :P300, ["target", "nontarget"], 21,
        string(P300path, "EPFLP300-5.zip/content")),
    
    DBMeta("EPFLP300-6", :P300, ["target", "nontarget"], 20,
        string(P300path, "EPFLP300-6.zip/content")),
    
    DBMeta("Lee2019_ERP-Train", :P300, ["target", "nontarget"], 330,
        string(P300path, "Lee2019_ERP-Train.zip/content")),
    
    DBMeta("Lee2019_ERP-Test", :P300, ["target", "nontarget"], 360,
        string(P300path, "Lee2019_ERP-Test.zip/content")),
]

# Filters the database catalog according to paradigm, classes and/or minimum number of trials.
function filterDB(
    paradigm::Union{Symbol, Nothing}=nothing;
    classes::Union{Vector{String}, Nothing}=nothing,
    minTrials::Union{Int64, Nothing}=nothing
)
    return filter(DB_CATALOG) do db
        (paradigm === nothing || db.paradigm == paradigm) &&
        (classes === nothing || all(c -> c in db.classes, classes)) &&
        (minTrials === nothing || db.minTrials ≥ minTrials)
    end
end


#=
function safe_download(url, localpath)
    open(localpath, "w") do io
        download(url, io)
    end
end
=#

# Status of a download job
const _QUEUED, _DOWNLOADING, _EXTRACTING, _DONE, _FAILED, _SKIPPED = 0, 1, 2, 3, 4, 5

# A database to download and extract. The atomic fields are written by the task running the job
# and read concurrently by the REPL progress printer and by the GUI.
struct _Job
    name     :: String               # database name, i.e., folder created by the extraction
    url      :: String
    basepath :: String               # folder where the database folder is created
    status   :: Threads.Atomic{Int}
    nowB     :: Threads.Atomic{Int}  # downloaded bytes
    totalB   :: Threads.Atomic{Int}  # size of the zip archive in bytes (0 if unknown)
end

_Job(name, url, basepath, totalB = 0) =
    _Job(name, url, basepath, Threads.Atomic{Int}(_QUEUED), Threads.Atomic{Int}(0), Threads.Atomic{Int}(totalB))

_finished(job::_Job) = job.status[] ∈ (_DONE, _FAILED, _SKIPPED)

_fmtSize(b) = b ≥ 1e9 ? "$(round(b / 1e9; digits = 2)) GB" : "$(round(b / 1e6; digits = 1)) MB"

# Fraction of bytes downloaded and summary text of the jobs not skipped.
# The bytes of the failed jobs are not counted, otherwise the total would never be reached.
function _progress(jobs)
    active = filter(j -> j.status[] != _SKIPPED, jobs)
    isempty(active) && return 0.0, ""
    counted = filter(j -> j.status[] != _FAILED, active)
    nowB, totalB = sum(j -> j.nowB[], counted; init = 0), sum(j -> j.totalB[], counted; init = 0)
    frac = totalB > 0 ? min(nowB / totalB, 1.0) : 0.0
    nDone = count(j -> j.status[] == _DONE, active)
    nFailed = count(j -> j.status[] == _FAILED, active)
    txt = "$(round(Int, 100 * frac))% ($(_fmtSize(nowB)) of $(_fmtSize(totalB))) · $(nDone) of $(length(active)) databases done"
    nFailed > 0 && (txt *= ", $(nFailed) failed")
    return frac, txt
end

# Extract the zip archive of a database in `basepath`. The archives of the corpus contain a top folder
# named as the database; an archive without it is extracted in `basepath/name`, so that the result is the same.
# The file is opened here rather than by `ZipFile.Reader(zippath)`, which leaves it open if the archive is invalid
# (on Windows an open file cannot be removed).
function _extract(zippath, basepath, name)
    open(zippath) do io
        reader = ZipFile.Reader(io)
        root = all(f -> startswith(f.name, name * "/"), reader.files) ? basepath : joinpath(basepath, name)
        for f ∈ reader.files
            dest = joinpath(root, f.name)
            if endswith(f.name, "/")
                mkpath(dest)
            else
                mkpath(dirname(dest))
                write(dest, read(f))
            end
        end
    end
end

function _runJob!(job::_Job, sem::Base.Semaphore, deleteZip::Bool)
    zippath = joinpath(job.basepath, job.name * ".zip")
    try
        # the semaphore bounds the concurrent downloads only: it is released before the extraction,
        # so that the next download starts while this archive is extracted
        Base.acquire(sem) do
            job.status[] = _DOWNLOADING
            mkpath(job.basepath)
            Downloads.download(job.url, zippath; timeout = 10800, # 3h timeout
                progress = (total, now) -> (total > 0 && (job.totalB[] = total); job.nowB[] = now))
        end
        job.status[] = _EXTRACTING
        _extract(zippath, job.basepath, job.name)
        deleteZip && rm(zippath; force = true)
        job.status[] = _DONE
    catch e
        job.status[] = _FAILED
        # an incomplete zip or database folder would make the next run skip this database
        rm(zippath; force = true)
        rm(joinpath(job.basepath, job.name); force = true, recursive = true)
        println()
        @error "FIIBCICorpus.DownloadFII, function downloadDB: error downloading $(job.name)" exception = e
    end
    return nothing
end

# Download and extract the databases of `jobs`, skipping those whose folder exists already.
# Up to `nDownloads` archives are downloaded at the same time (this is I/O bound and does not need threads),
# while the extractions (CPU bound) run in parallel on the threads available (see `Threads.nthreads()`).
# A progress bar is printed in the REPL if `verbose` is true.
function _runJobs!(jobs::Vector{_Job}; deleteZip::Bool = true, nDownloads::Int = 4, verbose::Bool = true)
    for job ∈ jobs
        if isdir(joinpath(job.basepath, job.name))
            job.status[] = _SKIPPED
        else
            # a zip left by an interrupted download
            rm(joinpath(job.basepath, job.name * ".zip"); force = true)
        end
    end

    skipped = [j.name for j ∈ jobs if j.status[] == _SKIPPED]
    todo = filter(j -> j.status[] == _QUEUED, jobs)

    if verbose && !isempty(skipped)
        println()
        println(titleFont, "The download of the following databases has been skipped as a folder with the same name exists already in the destination directory: ", defaultFont)
        println(greyFont, join(skipped, ", "), defaultFont)
    end

    if isempty(todo)
        verbose && println(titleFont, "No database has been downloaded.", defaultFont)
        return jobs
    end

    if verbose
        println(titleFont, "\nFIIBCICorpus is downloading the FII BCI corpus", defaultFont)
        println(greyFont, "$(length(todo)) databases, up to $(nDownloads) downloads at a time, extraction on $(Threads.nthreads()) threads.", defaultFont)
        println(greyFont, "You can keep using julia in the meanwhile,", defaultFont)
        println(greyFont, "while killing the REPL will interrupt the process.", defaultFont)
    end

    sem = Base.Semaphore(max(nDownloads, 1))
    printer = verbose ? (@async while true
        allDone = all(_finished, todo) # evaluated before printing, so that the last line is complete
        print("\rDownload progress: ", _progress(todo)[2], "        ")
        flush(stdout)
        allDone && break
        sleep(0.5)
    end) : nothing

    @sync for job ∈ todo
        Threads.@spawn _runJob!(job, sem, deleteZip)
    end

    if verbose
        wait(printer)
        failed = [j.name for j ∈ todo if j.status[] == _FAILED]
        println()
        isempty(failed) || println(titleFont, "The download of the following databases has failed: ", defaultFont, join(failed, ", "))
        println(titleFont, "Download process terminated.", defaultFont)
    end
    return jobs
end


"""
```julia
function corpusDir()
```

Return the default directory of the
[FII BCI corpus](@ref "FII BCI Corpus Overview"),
that is, folder *FII_BCI_Corpus* in the *homedir* (e.g., `C:\\Users\\Name\\FII_BCI_Corpus` on Windows),
where [`downloadDB`](@ref) downloads it by default.

If this folder does not exist, a warning is printed and `nothing` is returned. In an interactive session,
the user is first asked in the REPL whether to launch the GUI of [`downloadDB`](@ref) to download the corpus.
Since the download runs in the background, call `corpusDir()` again once it has ended.

If the corpus has been downloaded in another folder, that folder must be given explicitly
to the functions using it (e.g., argument `corpusdir` of
[`selectDB`](@ref FIIBCICorpus.Database.selectDB)).

**Return** the path of the corpus as a `String`, or `nothing` if it is not found.

**See Also** [`downloadDB`](@ref)

**Example**
```julia
using FIIBCICorpus

# get the full path of all .npz (data) files of database AlexMI
db = getFilesInDir(joinpath(corpusDir(), "MI", "AlexMI"); ext=(".npz", ))

# process the data file by file ...

```
"""
function corpusDir()
    path = joinpath(homedir(), CORPUS_DIR)
    isdir(path) && return path

    @warn "FIIBCICorpus.DownloadFII, function corpusDir: the FII BCI Corpus has not been found in its default location $(path)."
    # no prompt in non-interactive sessions (scripts, tests, CI), which would block on stdin
    isinteractive() || return nothing

    print("The GUI to download the FII BCI Corpus is about to be launched. Proceed? [y/n] ")
    if lowercase(strip(readline())) ∈ ("y", "yes")
        # the GUI is not displayed automatically when called from inside a function
        display(downloadDB())
        @info "Once the download has ended, call the function again."
    end
    return nothing
end
