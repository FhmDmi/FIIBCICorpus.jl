println("\x1b[95m", "\nTesting module FIIBCIcorpus.FileUtils.jl...", "\x1b[0m")

using FIIBCIcorpus.FileUtils: _fileBase, _getFilesInDir, _getFoldersInDir

# Eegle re-exports FIIBCIcorpus: these internal helpers must stay out of its namespace
@testset "FileUtils is internal" begin
    @test :FileUtils ∉ names(FIIBCIcorpus)
    @test isempty(names(FIIBCIcorpus.FileUtils) ∩ [:_fileBase, :_getFilesInDir, :_getFoldersInDir])
end


@testset "_fileBase" begin
    @test _fileBase("/home/user/myfile.txt") == "/home/user/myfile"
    @test _fileBase("noextension") == "noextension"

    # multiple extensions
    @test _fileBase("archive.tar.gz") == "archive.tar"

    # hidden file
    @test _fileBase(".gitignore") == ""

    # directory containing dots
    @test _fileBase("/tmp.v1/file.txt") == "/tmp.v1/file"
end


@testset "_getFilesInDir" begin
    tmpdir = mktempdir()

    touch(joinpath(tmpdir, "file1.txt"))
    touch(joinpath(tmpdir, "file2.jl"))
    touch(joinpath(tmpdir, "Analysis.txt"))

    mkdir(joinpath(tmpdir, "subdir"))
    touch(joinpath(tmpdir, "subdir", "nested.txt"))

    files = _getFilesInDir(tmpdir)
    @test length(files) == 3          # nested file ignored

    @test all(isfile, files)

    jl_files = _getFilesInDir(tmpdir; ext=(".jl",))
    @test length(jl_files) == 1
    @test endswith(jl_files[1], "file2.jl")

    txt_files = _getFilesInDir(tmpdir; ext=(".txt",))
    @test length(txt_files) == 2

    analysis = _getFilesInDir(tmpdir; isin="Analysis")
    @test length(analysis) == 1
    @test occursin("Analysis", basename(analysis[1]))

    filtered = _getFilesInDir(tmpdir; ext=(".txt",), isin="Analysis")
    @test length(filtered) == 1

    rm(tmpdir; recursive=true)
end


@testset "_getFilesInDir with multiple directories" begin
    dir1 = mktempdir()
    dir2 = mktempdir()

    touch(joinpath(dir1, "a.txt"))
    touch(joinpath(dir2, "b.txt"))
    touch(joinpath(dir2, "c.jl"))

    files = _getFilesInDir([dir1, dir2])

    @test length(files) == 3

    txt = _getFilesInDir([dir1, dir2]; ext=(".txt",))
    @test length(txt) == 2

    rm(dir1; recursive=true)
    rm(dir2; recursive=true)
end


@testset "_getFilesInDir warnings/errors" begin
    emptydir = mktempdir()

    @test_logs (:warn,) begin
        files = _getFilesInDir(emptydir)
        @test isempty(files)
    end

    rm(emptydir; recursive=true)

    @test_logs (:error,) begin
        _getFilesInDir("this_directory_does_not_exist")
    end
end


@testset "_getFoldersInDir" begin
    tmpdir = mktempdir()

    mkdir(joinpath(tmpdir, "FolderA"))
    mkdir(joinpath(tmpdir, "FolderB"))
    mkdir(joinpath(tmpdir, "AnalysisFolder"))

    folders = _getFoldersInDir(tmpdir)

    @test length(folders) == 3
    @test all(isdir, folders)

    analysis = _getFoldersInDir(tmpdir; isin="Analysis")

    @test length(analysis) == 1
    @test occursin("Analysis", basename(analysis[1]))

    rm(tmpdir; recursive=true)
end


@testset "_getFoldersInDir warnings/errors" begin
    emptydir = mktempdir()

    @test_logs (:warn,) begin
        folders = _getFoldersInDir(emptydir)
        @test isempty(folders)
    end

    rm(emptydir; recursive=true)

    @test_logs (:error,) begin
        _getFoldersInDir("this_directory_does_not_exist")
    end
end
