using Bonito
using ZipFile
using NativeFileDialog
using IsURL
using JSON
using HTTP
using Downloads
import Bonito.TailwindDashboard as D

include("db_catalog.jl")
include("styles.jl")


# Size in bytes of the zip archive of each database of the catalog, read from the Zenodo API.
# Return an empty dictionary if Zenodo cannot be reached (e.g., offline).
function _catalogSizes()
    sizes = Dict{String, Int}()
    for path ∈ (MIpath, P300path)
        try
            resp = HTTP.get(replace(path, r"/files/$" => ""))
            for f ∈ JSON.parse(String(resp.body))["files"]
                sizes[replace(f["key"], r"\.zip$" => "")] = f["size"]
            end
        catch e
            @warn "FIIBCICorpus.DownloadFII, function downloadDB: the size of the databases could not be read from Zenodo" exception = e
        end
    end
    return sizes
end

# Status text of a job shown in the GUI table
function _statusText(job::_Job)
    s = job.status[]
    s == _QUEUED      && return "queued"
    s == _DOWNLOADING && return "⬇ $(job.totalB[] > 0 ? round(Int, 100 * job.nowB[] / job.totalB[]) : 0)%"
    s == _EXTRACTING  && return "extracting"
    s == _DONE        && return "✓"
    s == _FAILED      && return "✗ failed"
    return "✓ (present)"
end

# Copy the state of the jobs into the Observables of the GUI.
# Called only from the GUI task, as the Observables are not updated by the download tasks.
function _updateGUI!(jobs, status, progress, totalProgress, totalText)
    for job ∈ jobs
        progress[job.name][] = job.totalB[] > 0 ? min(job.nowB[] / job.totalB[], 1.0) : 0.0
        status[job.name][] = _statusText(job)
    end
    totalProgress[], totalText[] = _progress(jobs)
end


# Launches the interactive GUI to browse, filter and download databases from the FII BCI corpus.
function _downloadDB(; nDownloads::Int = 4)

    app = App() do session

        # sizes of the databases, read from Zenodo without delaying the rendering
        sizes = Observable(Dict{String, Int}())
        @async sizes[] = _catalogSizes()

        # state of each database, kept when the filters change
        selected = Dict(db.name => Observable(true) for db ∈ DB_CATALOG)
        status   = Dict(db.name => Observable("") for db ∈ DB_CATALOG)
        progress = Dict(db.name => Observable(0.0) for db ∈ DB_CATALOG)
        running  = Observable(false)
        message  = Observable("")
        totalProgress = Observable(0.0)
        totalText     = Observable("")

        ### Paradigm
        dropdown = D.Dropdown("Paradigm", [:MI, :P300])

        ### minTrials (an invalid entry is replaced by 0)
        numberinput = D.TextField("0")
        minTrials = map(t -> something(tryparse(Int, strip(t)), -1), numberinput.value)

        mintrials = DOM.div(
            numberinput,
            DOM.span("Minimum Trials per class (enter an Integer)"; style = number_inuput_style),
            DOM.div(map(n -> n < 0 ? "⚠️ not a non-negative integer: 0 is used" : "", minTrials); style = warning_style),
        )

        ### MI classes. They are hidden for P300, since all P300 databases have the same classes
        checks = [(cb = D.Checkbox("", false), label = c) for c ∈ MI_CLASSES]

        checkbox_widgets = DOM.div(
            (D.FlexRow(c.cb, DOM.span(c.label; style = class_label_style); style = class_row_style) for c ∈ checks)...;
            hidden = map(p -> p != :MI, dropdown.value),
        )

        selected_classes = map((c.cb.value for c ∈ checks)...) do vs...
            [checks[i].label for i ∈ eachindex(vs) if vs[i]]
        end

        # Filter DBs based on UI inputs
        filtered = map(dropdown.value, minTrials, selected_classes) do p, t, cls
            filterDB(p; classes = (p == :MI && !isempty(cls)) ? cls : nothing, minTrials = max(t, 0))
        end

        ### Destination: <root>/FII_BCI_Corpus/<paradigm>
        # default root folder, evaluated when the GUI is rendered (not at precompilation time)
        root = Observable(homedir())
        destination = map((r, p) -> joinpath(r, CORPUS_DIR, string(p)), root, dropdown.value)

        # Lets the user choose the destination folder via native OS file dialog.
        path_button = Button("Choose path "; style = path_button_style)

        on(path_button.value) do click::Bool
            click || return
            folder = pick_folder()
            # `pick_folder` returns "" if the dialog is cancelled
            if folder === nothing || isempty(folder)
                @info "No folder chosen. The corpus will be downloaded in $(joinpath(root[], CORPUS_DIR))"
                return
            end
            root[] = folder
            println()
            @info "The corpus will be downloaded in $(joinpath(folder, CORPUS_DIR))"
            # only the default location is found automatically by `corpusDir`
            if normpath(folder) != normpath(homedir())
                @info "This is not the default location. Pass `corpusdir = \"$(joinpath(folder, CORPUS_DIR))\"` to `selectDB` to use this corpus."
            end
        end

        # Handles deletion of existing downloaded folders when enabled.
        overwrite_checkbox = D.Checkbox("Overwrite existing data ", false)

        # Button to start the download, disabled while a download is running
        download_button = Button("Download Now "; style = download_button_style, disabled = running)

        on(download_button.value) do click::Bool
            (click && !running[]) || return
            dbs = [db for db ∈ filtered[] if selected[db.name][]]
            if isempty(dbs)
                message[] = "⚠️ No database selected."
                return
            end

            basepath(db) = joinpath(root[], CORPUS_DIR, string(db.paradigm))

            if overwrite_checkbox.value[]
                @info "Overwrite enabled — removing the existing folders of the selected databases first..."
                for db ∈ dbs
                    folder = joinpath(basepath(db), db.name)
                    if isdir(folder)
                        println("Removing existing folder: $(folder)")
                        rm(folder; force = true, recursive = true)
                    end
                end
            else
                @info "Overwrite disabled — keeping existing data."
            end

            println()
            println(titleFont, "Selected databases:", defaultFont)
            for (d, db) ∈ enumerate(dbs)
                print(greyFont, d, defaultFont, " - ", db.name, "; ")
            end
            println()

            jobs = [_Job(db.name, db.url, basepath(db), get(sizes[], db.name, 0)) for db ∈ dbs]
            running[] = true
            message[] = "Downloading in $(joinpath(root[], CORPUS_DIR))…"

            # the download runs in the background, so that the GUI stays responsive
            task = Threads.@spawn _runJobs!(jobs; nDownloads)

            # the Observables are updated only from this task, running on the thread of the GUI
            @async begin
                while !istaskdone(task)
                    _updateGUI!(jobs, status, progress, totalProgress, totalText)
                    sleep(0.5)
                end
                _updateGUI!(jobs, status, progress, totalProgress, totalText)
                nFailed = count(j -> j.status[] == _FAILED, jobs)
                message[] = istaskfailed(task) ? "✗ The download has been interrupted (see the REPL)." :
                            nFailed > 0 ? "⚠️ Download terminated, failed for $(nFailed) database(s) (see the REPL)." :
                            "✓ Download terminated."
                running[] = false
            end
        end

        # Summary of the selected databases
        selectionSummary = map(filtered, sizes, values(selected)...) do dbs, sz, _...
            sel = [db for db ∈ dbs if selected[db.name][]]
            nUnknown = count(db -> !haskey(sz, db.name), sel)
            txt = "$(length(sel)) of $(length(dbs)) databases selected, $(_fmtSize(sum(db -> get(sz, db.name, 0), sel; init = 0)))"
            nUnknown > 0 ? txt * " (size unknown for $(nUnknown))" : txt
        end

        # Formats the filtered database list into a styled Bonito dashboard table.
        displayList = map(filtered, sizes, destination) do dbs, sz, dest
            # the status of the databases not being downloaded reflects the destination folder
            if !running[]
                for db ∈ dbs
                    status[db.name][] = isdir(joinpath(dest, db.name)) ? "✓ (present)" : ""
                    progress[db.name][] = 0.0
                end
            end

            # Header
            header = D.FlexRow(
                DOM.div("",                 style = header_style_0),
                DOM.div(D.Text("Name"),     style = header_name_style),
                DOM.div(D.Text("Paradigm"), style = header_style_1),
                DOM.div(D.Text("Trials"),   style = header_style_1),
                DOM.div(D.Text("Classes"),  style = header_style_2),
                DOM.div(D.Text("Size"),     style = header_style_1),
                DOM.div(D.Text("Status"),   style = header_style_2),
                style = table_header_style
            )

            # Rows
            rows = [ D.FlexRow(
                        DOM.div(Bonito.Checkbox(selected[db.name], Dict{Symbol, Any}()), style = rows_style_0),
                        DOM.div(D.Text(db.name),                  style = rows_name_style),
                        DOM.div(D.Text(db.paradigm),              style = rows_style_1),
                        DOM.div(D.Text(string(db.minTrials)),     style = rows_style_1),
                        DOM.div(D.Text(join(db.classes, ", ")),   style = rows_style_2),
                        DOM.div(D.Text(haskey(sz, db.name) ? _fmtSize(sz[db.name]) : "–"), style = rows_style_1),
                        DOM.div(
                            DOM.span(status[db.name]),
                            DOM.progress(; value = progress[db.name], max = 1, style = row_progress_style,
                                           hidden = map(s -> !startswith(s, "⬇"), status[db.name])),
                            style = rows_style_2),
                        style = table_rows_style
                    ) for db ∈ dbs ]

            # Combine header + rows with spacing
            D.FlexCol(header, rows...; style = table_style)
        end


        return DOM.div( D.FlexCol(
            DOM.br(),
            D.Title(" 📥 FIIBCICorpus GUI: download the FII BCI Corpus", style = title_style),
            DOM.br(),
            D.FlexRow(
                D.Card(D.FlexCol(D.Title("Database options"), dropdown, mintrials, checkbox_widgets,
                                 "Destination folder: ", DOM.div(destination; style = path_style), path_button,
                                 overwrite_checkbox, download_button, DOM.div(message; style = message_style))),
                D.Card(D.FlexCol(D.Title("Selected Databases "),
                                 DOM.div(selectionSummary),
                                 DOM.div(DOM.progress(; value = totalProgress, max = 1, style = total_progress_style),
                                         DOM.div(totalText; style = message_style);
                                         hidden = map(t -> isempty(t), totalText)),
                                 displayList)),
        )))
    end
end

# Downloads and extracts all zip archives of a Zenodo record URL into a local destination.
function _downloadDB(url::String, dest::String = homedir(); nDownloads::Int = 4)

    if !isurl(url)
        error("FIIBCICorpus.DownloadFII, function downloadDB: Invalid URL format: $url")
    end

    ## Transform the Zenodo url to JSON format
    if occursin("https://zenodo.org", url)
        url = replace(url, "https://zenodo.org" => "https://zenodo.org/api")
    else
        error("FIIBCICorpus.DownloadFII, function downloadDB: URL must be a Zenodo record")
    end

    ## Check the directory
    if !isdir(dest)
        error("FIIBCICorpus.DownloadFII, function downloadDB: invalid directory")
    end

    ## Check if the url is reachable
    resp = HTTP.get(url)
    if resp.status != 200
        error("FIIBCICorpus.DownloadFII, function downloadDB: URL not reachable (status $(resp.status))")
    end

    meta = JSON.parse(String(resp.body))

    # a record may also hold other files (e.g., documentation), which are not databases
    isZip(file) = endswith(file["key"], ".zip")
    others = [file["key"] for file ∈ meta["files"] if !isZip(file)]
    isempty(others) || @info "The following files are not zip archives and are not downloaded: $(join(others, ", "))"

    jobs = [_Job(replace(file["key"], r"\.zip$" => ""), file["links"]["self"], dest, file["size"])
            for file ∈ meta["files"] if isZip(file)]

    @info "Starting the download of the FII BCI Corpus"
    _runJobs!(jobs; nDownloads)
    println("Please make sure you have downloaded the databases for all paradigms you are interested in.")
    return nothing
end

# Sequentially downloads multiple Zenodo URLs, skipping those that fail.
function _downloadDB(urls::Vector{String}, dest::String = homedir(); nDownloads::Int = 4)
    for url in urls
        try
            downloadDB(url, dest; nDownloads)
        catch e
            @warn "FIIBCICorpus.DownloadFII, function downloadDB: download failed for $url — skipping. Error: $e"
        end
    end
end
