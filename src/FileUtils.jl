# Internal helpers on files and folders, used by the other modules of FIIBCICorpus.
# Neither exported nor re-exported. The public module for this is `Eegle.FileSystem`: the different
# module name and the leading underscores avoid any confusion with it.
module FileUtils

# Return `file` (with its path, if any) without the extension, or `file` if it has none.
_fileBase(file::String) = isnothing(findlast(==('.'), file)) ? file : file[begin:findlast(==('.'), file)-1]

# Return the complete path of the files directly in `dir` (subfolders are not searched).
# `ext` is a tuple of lowercase extensions including the dot; if empty, any extension is accepted.
# If `isin` is not empty, keep only the files whose name contains it.
_getFilesInDir(dir::String; ext::Tuple=(), isin::String="") =
if !isdir(dir) @error "FIIBCICorpus.FileUtils, function `_getFilesInDir`: input directory is incorrect!"
else
    S=[]
    for (root, dirs, files) in walkdir(dir)
        if root==dir
            for file in files
                if ext==() || ( lowercase(string(file[last(findlast(".", file)): end])) ∈ ext )
                    if occursin(isin, file) # if isin=="" this is always true
                        push!(S, joinpath(root, file)) # complete path and file name
                    end
                end
            end
        end
    end
    isempty(S) && @warn "FIIBCICorpus.FileUtils, function `_getFilesInDir`: input directory does not contain any files"
    return Vector{String}(S)
end

# return a vector containing all files in all directories in `dirs`
function _getFilesInDir(dirs::Vector{String}; ext::Tuple=(), isin::String="")
    S = [_getFilesInDir(dir; ext = ext, isin = isin) for dir ∈ dirs]
    return reduce(vcat, S)
end

# Return the complete path of the folders directly in `dir`.
# If `isin` is not empty, keep only the folders whose name contains it.
_getFoldersInDir(dir::String; isin::String="") =
if !isdir(dir) @error "FIIBCICorpus.FileUtils, function `_getFoldersInDir`: input directory is incorrect!"
else
    S=[]
    for (root, dirs, files) in walkdir(dir)
        if root==dir
            for dir in dirs
                if occursin(isin, dir) # if isin=="" this is always true
                    push!(S, joinpath(root, dir)) # complete path and file name
                end
            end
        end
    end
    isempty(S) && @warn "FIIBCICorpus.FileUtils, function `_getFoldersInDir`: input directory does not contain any folders"
    return Vector{String}(S)
end

end # module
