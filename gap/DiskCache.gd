DeclareGlobalFunction("MEMO_DiskCache");
DeclareCategory("MEMO_IsDiskCache", MEMO_IsCache);

# Return the filename to use for a call, based on its key
# Arguments: cache, key, ext
DeclareGlobalFunction("MEMO_KeyToFilename");

# Return the key used to create a given filename, assuming an unhash function
# was provided
# Arguments: cache, filename
DeclareGlobalFunction("MEMO_FilenameToKey");

# Filename extensions
BindGlobal("MEMO_OUT", ".out");
BindGlobal("MEMO_KEY", ".key");
BindGlobal("MEMO_META", ".meta");

# Create a directory and any necessary ancestors, given a path
DeclareGlobalFunction("MEMO_CreateDirRecursively");
