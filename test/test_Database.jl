println("\x1b[95m", "\nTesting module FIIBCIcorpus.Database.jl...", "\x1b[0m")

# All tests run on small fake databases in NY format built in a temporary directory:
# realistic .yml metadata files (same field structure as the files of the FII BCI Corpus)
# and empty .npz files, since the functions of this module only read the metadata.
# `withHome` is defined in test_DownloadFII.jl.

const SENSORS16 = ["F7", "F3", "F4", "F8", "T7", "C3", "Cz", "C4", "T8", "P7", "P3", "Pz", "P4", "P8", "O1", "O2"]

_ymlList(v, indent) = join(("$(indent)- $x" for x ∈ v), "\n")
_ymlDict(d, indent) = join(("$(indent)$k: $v" for (k, v) ∈ d), "\n")

# Write the .yml metadata file of one session (formatversion 0.0.3), with an empty .npz data file next to it
function writeSession(dir, file; database, paradigm, subject, session = 1, run = 1, condition = "None",
                      sr = 128, wl = 128, offset = 0, sensors = SENSORS16, labels, trialsperclass,
                      perf = nothing, npz = true)
    mkpath(dir)
    perfText = isnothing(perf) ? "" : "\nperf:\n" * join(("  $task:\n" * _ymlDict(acc, "    ") for (task, acc) ∈ perf), "\n")
    write(joinpath(dir, file * ".yml"), """
    acquisition:
      filter: None
      ground: FZ
      hardware: NeXus-32 EEG
      reference: Hardware common average reference
      samplingrate: $sr
      sensors:
    $(_ymlList(sensors, "  "))
      sensortype: Ag/AgCl Wet electrodes
      software: OpenVibe
    documentation:
      description: https://hal.science/hal-02126068
      doi: https://doi.org/10.5281/zenodo.2649006
      investigators: Korczowski, Congedo
      place: University of Grenoble Alpes, GipsaLab France
      repository: https://zenodo.org/records/806023
    formatversion: 0.0.3
    id:
      condition: $condition
      database: $database
      paradigm: $paradigm
      run: $run
      session: $session
      subject: $subject
      timestamp: 2012
    stim:
      labels:
    $(_ymlDict(labels, "    "))
      nclasses: $(length(labels))
      trialsperclass:
    $(_ymlDict(trialsperclass, "    "))
      offset: $offset
      windowlength: $wl$perfText
    """)
    npz && touch(joinpath(dir, file * ".npz"))
end

# Fake corpus:
# MI/MIA  : 3 subjects, subject 1 with 2 sessions, classes right_hand, feet, rest (codes 2, 3, 4), sr 256
# MI/MIB  : 2 subjects, classes left_hand, right_hand, sr 512, upper-case sensor labels
# P300/PA : 2 subjects, classes nontarget, target, no `perf` section
function writeCorpus(root)
    mi3 = ["right_hand" => 2, "feet" => 3, "rest" => 4]
    dir = joinpath(root, "MI", "MIA")
    writeSession(dir, "subject_01_session_01"; database = "MIA", paradigm = "MI", subject = 1, session = 1,
                 sr = 256, wl = 768, labels = mi3, trialsperclass = ["right_hand" => 20, "feet" => 20, "rest" => 20],
                 perf = ["right_hand-feet" => ["MDM" => 0.825, "TSSVM" => 0.675]])
    writeSession(dir, "subject_01_session_02"; database = "MIA", paradigm = "MI", subject = 1, session = 2,
                 sr = 256, wl = 768, labels = mi3, trialsperclass = ["right_hand" => 10, "feet" => 30],
                 perf = ["right_hand-feet" => ["MDM" => 0.55, "TSSVM" => 0.6]])
    writeSession(dir, "subject_02_session_01"; database = "MIA", paradigm = "MI", subject = 2,
                 sr = 256, wl = 768, labels = mi3, trialsperclass = ["right_hand" => 20, "feet" => 20, "rest" => 20],
                 perf = ["right_hand-feet" => ["MDM" => 0.1, "TSSVM" => 0.2]])
    writeSession(dir, "subject_03_session_01"; database = "MIA", paradigm = "MI", subject = 3,
                 sr = 256, wl = 768, labels = mi3, trialsperclass = ["right_hand" => 20, "feet" => 20, "rest" => 20],
                 perf = ["right_hand-feet" => ["MDM" => 0.9, "TSSVM" => 0.85]])

    mi2 = ["left_hand" => 1, "right_hand" => 2]
    dir = joinpath(root, "MI", "MIB")
    for (s, acc) ∈ ((1, 0.75), (2, 0.65))
        writeSession(dir, "subject_0$(s)_session_01"; database = "MIB", paradigm = "MI", subject = s,
                     sr = 512, wl = 1024, offset = 256, sensors = ["FZ", "C3", "CZ", "C4"], labels = mi2,
                     trialsperclass = ["left_hand" => 50, "right_hand" => 50],
                     perf = ["left_hand-right_hand" => ["MDM" => acc, "TSSVM" => acc]])
    end

    p300 = ["nontarget" => 1, "target" => 2]
    dir = joinpath(root, "P300", "PA")
    for s ∈ 1:2
        writeSession(dir, "subject_0$(s)_session_01"; database = "PA", paradigm = "P300", subject = s,
                     condition = "Training", labels = p300, trialsperclass = ["nontarget" => 640, "target" => 128])
    end
    return root
end

const CORPUS = writeCorpus(joinpath(mktempdir(), "FII_BCI_Corpus"))
const MIA = joinpath(CORPUS, "MI", "MIA")
const MIB = joinpath(CORPUS, "MI", "MIB")
const PA = joinpath(CORPUS, "P300", "PA")

dbNames(dbs) = Set(db.dbName for db ∈ dbs)


@testset "loadDB" begin
    files = loadDB(MIA)
    @test length(files) == 4
    @test all(f -> endswith(f, ".npz") && isfile(f), files)

    @test basename.(loadDB(MIA, "subject_01")) == ["subject_01_session_01.npz", "subject_01_session_02.npz"]

    # a .npz file without its .yml file is excluded, with a warning
    dir = mktempdir()
    writeSession(dir, "subject_01_session_01"; database = "X", paradigm = "P300", subject = 1,
                 labels = ["nontarget" => 1, "target" => 2], trialsperclass = ["nontarget" => 10, "target" => 2])
    touch(joinpath(dir, "subject_02_session_01.npz"))
    files = @test_logs (:warn, r"\.yml files have not been found") loadDB(dir)
    @test basename.(files) == ["subject_01_session_01.npz"]
end


@testset "infoDB" begin
    db = infoDB(MIA)
    @test db isa InfoDB
    @test db.dbName == "MIA"
    @test db.paradigm == "MI"
    @test db.condition == "None"
    @test length(db.files) == 4
    @test db.nSubjects == 3
    @test db.nSessions == [2, 1, 1]
    @test db.nSensors == 16
    @test db.sensors == SENSORS16
    @test db.sensorType == "Ag/AgCl Wet electrodes"
    @test (db.sr, db.wl, db.offset) == (256, 768, 0)
    @test db.nClasses == 3
    # class labels are sorted by their numeric code in the .yml file, not by their order in the file
    @test db.cLabels == ["right_hand", "feet", "rest"]
    # one entry per session, 0 when a class is missing in a session
    @test db.nTrials == Dict("right_hand" => [20, 10, 20, 20], "feet" => [20, 30, 20, 20], "rest" => [20, 0, 20, 20])
    @test (db.filter, db.hardware, db.software) == ("None", "NeXus-32 EEG", "OpenVibe")
    @test (db.reference, db.ground) == ("Hardware common average reference", "FZ")
    @test db.doi == "https://doi.org/10.5281/zenodo.2649006"
    @test db.repository == "https://zenodo.org/records/806023"
    @test (db.timestamp, db.formatVersion) == (2012, "0.0.3")

    db = infoDB(MIB)
    @test (db.sr, db.wl, db.offset) == (512, 1024, 256)
    @test db.cLabels == ["left_hand", "right_hand"]
    @test db.nSessions == [1, 1]

    s = sprint(show, MIME("text/plain"), infoDB(PA))
    @test occursin("Database Summary: PA | 2 subjects, 2 classes", s)
    @test occursin("nontarget: 640 ± 0", s)

    # non-unique sampling rate: warning, the first value is retained
    dir = mktempdir()
    for (s, sr) ∈ ((1, 128), (2, 256))
        writeSession(dir, "subject_0$(s)_session_01"; database = "X", paradigm = "P300", subject = s, sr = sr,
                     labels = ["nontarget" => 1, "target" => 2], trialsperclass = ["nontarget" => 10, "target" => 2])
    end
    db = @test_logs (:warn, r"Sampling rate is not unique") infoDB(dir)
    @test db.sr == 128

    # duplicated triplet (subject, session, run): error
    dir = mktempdir()
    for f ∈ ("a", "b")
        writeSession(dir, f; database = "X", paradigm = "P300", subject = 1,
                     labels = ["nontarget" => 1, "target" => 2], trialsperclass = ["nontarget" => 10, "target" => 2])
    end
    @test_throws ErrorException infoDB(dir)

    # no .npz file: error
    @test_logs (:warn,) @test_throws ErrorException infoDB(mktempdir())
end


@testset "selectDB" begin
    # the search starts in the paradigm subfolder of the corpus
    @test dbNames(selectDB(CORPUS, :MI; summarize = false)) == Set(["MIA", "MIB"])
    @test dbNames(selectDB(joinpath(CORPUS, "MI"), :MI; summarize = false)) == Set(["MIA", "MIB"])

    # all the requested classes must be present, case-insensitively
    @test dbNames(selectDB(CORPUS, :MI; classes = ["left_hand", "right_hand"], summarize = false)) == Set(["MIB"])
    @test dbNames(selectDB(CORPUS, :MI; classes = ["Right_Hand"], summarize = false)) == Set(["MIA", "MIB"])
    @test_throws ErrorException selectDB(CORPUS, :MI; classes = ["tongue"], summarize = false)

    # P300: default classes target and nontarget
    dbs = selectDB(CORPUS, :P300; summarize = false)
    @test dbNames(dbs) == Set(["PA"])
    @test length(dbs[1].files) == 2

    # the summary table is printed without error
    @test length(selectDB(CORPUS, :P300)) == 1

    @test_throws ErrorException selectDB(CORPUS, :SSVEP)
    @test_throws ErrorException selectDB(joinpath(CORPUS, "nonexistent"), :MI)
end


@testset "selectDB inclusion" begin
    sel(inclusion; kwargs...) = selectDB(CORPUS, :MI; inclusion, summarize = false, kwargs...)

    # shortcut `sr`, whole databases
    dbs = sel((("sr", ==(256)),))
    @test dbNames(dbs) == Set(["MIA"])
    @test length(dbs[1].files) == 4

    # explicit dot notation and short form (nested search) are equivalent
    @test dbNames(sel((("acquisition.samplingrate", x -> x > 300),))) == Set(["MIB"])
    @test dbNames(sel((("windowlength", x -> x > 1000),))) == Set(["MIB"])

    # string vectors are matched case-insensitively ("FZ" in MIB)
    @test dbNames(sel((("acquisition.sensors", x -> "fz" ∈ x),))) == Set(["MIB"])

    # session-level filtering on the perf section: only the files passing the filter are kept
    dbs = sel((("perfLHRH.MDM", x -> x >= 0.7),))
    @test dbNames(dbs) == Set(["MIB"])
    @test basename.(dbs[1].files) == ["subject_01_session_01.npz"]

    # sessions whose perf values are all in [0, 0.2] are rejected automatically (MIA subject 2)
    dbs = sel((("perfRHF.MDM", x -> x >= 0),))
    @test dbNames(dbs) == Set(["MIA"])
    @test length(dbs[1].files) == 3
    @test "subject_02_session_01.npz" ∉ basename.(dbs[1].files)

    # dictionary fields: minimum number of trials per class (MIA session 2 has no `rest` trials)
    dbs = sel((("tpc", x -> minimum(values(x)) >= 20),); classes = ["right_hand", "feet", "rest"])
    @test length(dbs[1].files) == 3

    # AND logic between filters, with verbose feedback
    dbs = sel((("sr", ==(256)), ("perfRHF.MDM", x -> x >= 0.8)); verbose = true)
    @test basename.(dbs[1].files) == ["subject_01_session_01.npz", "subject_03_session_01.npz"]

    # a flat tuple is wrapped automatically, with a warning
    dbs = @test_logs (:warn, r"flat tuple") match_mode = :any sel(("sr", ==(512)))
    @test dbNames(dbs) == Set(["MIB"])

    # filters on `paradigm` and `classes` are removed, with a warning
    dbs = @test_logs (:warn, r"automatically removed") match_mode = :any sel((("paradigm", ==("P300")), ("sr", ==(512))))
    @test dbNames(dbs) == Set(["MIB"])

    # a field that does not exist excludes the sessions
    @test_throws ErrorException sel((("nonexistentfield", ==(1)),))
    # databases matching paradigm and classes, but no session passing the filters
    @test_throws ErrorException sel((("sr", ==(1000)),))
end


@testset "selectDB default corpus" begin
    # the corpus is searched in its default location homedir()/FII_BCI_Corpus
    withHome(dirname(CORPUS)) do
        @test dbNames(selectDB(:MI; classes = ["left_hand"], summarize = false)) == Set(["MIB"])
        @test dbNames(selectDB(:P300; summarize = false)) == Set(["PA"])
    end

    # corpus not found: `corpusDir` warns (no prompt in non-interactive sessions) and selectDB throws
    withHome(mktempdir()) do
        @test_logs (:warn,) @test_throws ArgumentError selectDB(:MI)
    end
end


@testset "weightsDB" begin
    # analytic weights √M·√S_m / S_m (M = 3 subjects, subject 1 with S_m = 2 sessions)
    w, schedule = weightsDB(loadDB(MIA))
    @test w ≈ [√3 * √2 / 2, √3 * √2 / 2, √3, √3]
    @test schedule == [1 2; 2 1; 3 1]

    # the sum of the weights of each subject is √M·√S_m
    @test w[1] + w[2] ≈ √3 * √2

    # examples A to D of the docstring
    dbW = FIIBCIcorpus.Database._weightsDB
    @test dbW(collect(1:64), 64)[1] ≈ fill(8.0, 64)
    @test dbW(repeat(1:64; inner = 4), 256)[1] ≈ fill(4.0, 256)
    @test dbW(repeat(1:16; inner = 4), 64)[1] ≈ fill(2.0, 64)
    @test dbW([1, 2, 3, 3, 3, 3, 4, 4, 4, 4], 10)[1] ≈ [2, 2, 1, 1, 1, 1, 1, 1, 1, 1]
    @test_throws ErrorException dbW([1, 1, 2], 4)

    # subject identifiers stored as strings are parsed
    dir = mktempdir()
    for (f, s) ∈ (("a", "'01'"), ("b", "'01'"), ("c", "'02'"))
        writeSession(dir, f; database = "X", paradigm = "P300", subject = s, session = f,
                     labels = ["nontarget" => 1, "target" => 2], trialsperclass = ["nontarget" => 10, "target" => 2])
    end
    w, schedule = weightsDB(loadDB(dir))
    @test w ≈ [√2 * √2 / 2, √2 * √2 / 2, √2]
    @test schedule == [1 2; 2 1]

    @test_throws ErrorException weightsDB(String[])
    @test_throws ErrorException weightsDB([joinpath(mktempdir(), "nofile.npz")])
end
