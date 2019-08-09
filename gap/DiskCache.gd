DeclareGlobalFunction("MEMO_DiskCache");
DeclareCategory("MEMO_IsDiskCache", IsLookupDictionary);

DeclareOperation("AddDictionary",[MEMO_IsDiskCache, IsObject, IsObject]);

# Return the filename to use for a call, based on its key
# Arguments: cache, key, ext
DeclareGlobalFunction("MEMO_KeyToFilename");

# Return the key used to create a given filename, assuming an unhash function
# was provided
# Arguments: cache, filename
DeclareGlobalFunction("MEMO_FilenameToKey");

BindGlobal("MEMO_OUT", ".out");
BindGlobal("MEMO_KEY", ".key");
BindGlobal("MEMO_META", ".meta");
