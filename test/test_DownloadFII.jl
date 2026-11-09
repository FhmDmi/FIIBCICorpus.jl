println("\x1b[95m", "\nTesting module FIIBCIcorpus.DownloadFII.jl...", "\x1b[0m")

# All tests are offline: the download engine is tested on local zip archives served as `file://` URLs,
# and every other code path tested here returns or throws before any HTTP request.

const DF = FIIBCIcorpus.DownloadFII

# Run `f` with the homedir redirected to `dir`
# (libuv reads USERPROFILE on Windows and HOME elsewhere)
withHome(f, dir) = withenv(f, "USERPROFILE" => dir, "HOME" => dir)

fileURL(path) = "file:///" * replace(lstrip(replace(path, '\\' => '/'), '/'), " " => "%20")

# Write a zip archive holding `files` (relative path => content)
function writeZip(zippath, files)
    w = DF.ZipFile.Writer(zippath)
    for (name, content) ∈ files
        f = DF.ZipFile.addfile(w, name; method = DF.ZipFile.Deflate)
        write(f, content)
    end
    close(w)
end

# Read all files of a folder as relative path => content
function readTree(dir)
    tree = Dict{String, String}()
    for (root, _, files) ∈ walkdir(dir), f ∈ files
        tree[replace(relpath(joinpath(root, f), dir), '\\' => '/')] = read(joinpath(root, f), String)
    end
    return tree
end


@testset "DB catalog" begin
    @test length(DF.DB_CATALOG) == 40
    @test count(db -> db.paradigm == :MI, DF.DB_CATALOG) == 16
    @test count(db -> db.paradigm == :P300, DF.DB_CATALOG) == 24
    @test allunique(db.name for db ∈ DF.DB_CATALOG)
    @test all(db -> endswith(db.url, db.name * ".zip/content"), DF.DB_CATALOG)
    # class labels are the standardized labels of `Eegle.readNY`
    @test all(db -> db.classes ⊆ (db.paradigm == :MI ? DF.MI_CLASSES : DF.P300_CLASSES), DF.DB_CATALOG)
end


@testset "filterDB" begin
    @test DF.filterDB() == DF.DB_CATALOG
    @test length(DF.filterDB(:MI)) == 16
    @test length(DF.filterDB(:P300)) == 24

    # all requested classes must be present
    dbs = DF.filterDB(:MI; classes = ["left_hand", "right_hand", "feet"])
    @test Set(db.name for db ∈ dbs) == Set(["BNCI2014001", "Schirrmeister2017", "Weibo2014", "Zhou2016"])

    # minTrials is inclusive
    dbs = DF.filterDB(:MI; minTrials = 120)
    @test Set(db.name for db ∈ dbs) == Set(["GrosseWentrup2009", "Schirrmeister2017"])

    @test isempty(DF.filterDB(:P300; minTrials = 1000))
end


@testset "downloadDB argument checks" begin
    @test_throws ErrorException downloadDB("not a url")
    @test_throws ErrorException downloadDB("https://example.com/records/17670014")
    @test_throws ErrorException downloadDB("https://zenodo.org/records/17670014", joinpath(mktempdir(), "missing"))

    # several records: failures are reported as warnings and skipped
    @test_logs (:warn,) (:warn,) downloadDB(["not a url", "https://example.com/records/1"], mktempdir())
end


@testset "downloadDB GUI" begin
    @test downloadDB() isa DF.Bonito.App
    @test downloadDB(; nDownloads = 2) isa DF.Bonito.App
end


@testset "_extract" begin
    src = mktempdir()
    content = Dict("DB1/subject_01/session_01.txt" => "a", "DB1/subject_01/session_01.yml" => "b")

    # archive with a top folder named as the database: extracted as is
    writeZip(joinpath(src, "DB1.zip"), content)
    dest = mktempdir()
    DF._extract(joinpath(src, "DB1.zip"), dest, "DB1")
    @test readTree(dest) == content

    # archive without top folder: extracted in a folder named as the database
    writeZip(joinpath(src, "DB2.zip"), Dict("s1.txt" => "c", "sub/s2.txt" => "d"))
    dest = mktempdir()
    DF._extract(joinpath(src, "DB2.zip"), dest, "DB2")
    @test readTree(dest) == Dict("DB2/s1.txt" => "c", "DB2/sub/s2.txt" => "d")
end


@testset "_runJobs! without network" begin
    src = mktempdir()
    contents = Dict(
        "DB$i" => Dict("DB$i/subject_0$j/data.txt" => "database $i, subject $j " ^ 1000 for j ∈ 1:3)
        for i ∈ 1:6)
    for (name, files) ∈ contents
        writeZip(joinpath(src, name * ".zip"), files)
    end
    write(joinpath(src, "Corrupt.zip"), "this is not a zip archive")

    dest = mktempdir()

    # a database present already is skipped and not modified
    mkpath(joinpath(dest, "DB6"))
    write(joinpath(dest, "DB6", "keep.txt"), "untouched")

    # a zip left by an interrupted download is removed
    write(joinpath(dest, "DB1.zip"), "partial")

    jobs = [DF._Job(name, fileURL(joinpath(src, name * ".zip")), dest) for name ∈ sort(collect(keys(contents)))]
    push!(jobs, DF._Job("Missing", fileURL(joinpath(src, "Missing.zip")), dest))  # download fails
    push!(jobs, DF._Job("Corrupt", fileURL(joinpath(src, "Corrupt.zip")), dest))  # extraction fails

    # more jobs than concurrent downloads, to exercise the semaphore
    DF._runJobs!(jobs; nDownloads = 2)

    status = Dict(j.name => j.status[] for j ∈ jobs)
    @test all(status["DB$i"] == DF._DONE for i ∈ 1:5)
    @test status["DB6"] == DF._SKIPPED
    @test status["Missing"] == DF._FAILED
    @test status["Corrupt"] == DF._FAILED

    # extracted data equal the archives, zip archives removed
    for i ∈ 1:5
        @test readTree(joinpath(dest, "DB$i")) == Dict(replace(k, "DB$i/" => "") => v for (k, v) ∈ contents["DB$i"])
        @test !isfile(joinpath(dest, "DB$i.zip"))
    end
    @test readTree(joinpath(dest, "DB6")) == Dict("keep.txt" => "untouched")

    # failed databases leave nothing behind, so that they are downloaded again next time
    @test !ispath(joinpath(dest, "Missing")) && !ispath(joinpath(dest, "Missing.zip"))
    @test !ispath(joinpath(dest, "Corrupt")) && !ispath(joinpath(dest, "Corrupt.zip"))

    # downloaded bytes equal the size of the archives
    @test all(j.nowB[] == filesize(joinpath(src, j.name * ".zip")) for j ∈ jobs if j.status[] == DF._DONE)

    frac, txt = DF._progress(jobs)
    @test frac ≈ 1.0
    @test occursin("5 of 7 databases done, 2 failed", txt)

    # nothing to download
    @test DF._runJobs!(DF._Job[]) == DF._Job[]
    again = [DF._Job(j.name, j.url, dest) for j ∈ jobs if j.status[] == DF._DONE]
    DF._runJobs!(again)
    @test all(j.status[] == DF._SKIPPED for j ∈ again)
end


@testset "_statusText and _fmtSize" begin
    job = DF._Job("DB", "file:///DB.zip", mktempdir(), 200)
    @test DF._statusText(job) == "queued"
    job.status[] = DF._DOWNLOADING; job.nowB[] = 50
    @test DF._statusText(job) == "⬇ 25%"
    job.status[] = DF._FAILED
    @test DF._statusText(job) == "✗ failed"
    # the bytes of failed jobs are not counted in the total progress
    done = DF._Job("A", "file:///A.zip", mktempdir(), 100)
    done.status[] = DF._DONE; done.nowB[] = 100
    @test DF._progress([done, job])[1] ≈ 1.0
    @test occursin("1 of 2 databases done, 1 failed", DF._progress([done, job])[2])

    @test DF._fmtSize(60_492_453) == "60.5 MB"
    @test DF._fmtSize(2_500_000_000) == "2.5 GB"
end


@testset "corpusDir" begin
    home = mktempdir()
    withHome(home) do
        @test homedir() == home
        # not found: warning, no prompt since tests are not interactive
        @test_logs (:warn,) @test corpusDir() === nothing
        mkpath(joinpath(home, "FII_BCI_Corpus"))
        @test corpusDir() == joinpath(home, "FII_BCI_Corpus")
    end
end
