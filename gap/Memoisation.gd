#
# Memoisation: Shared persistent memoisation library for GAP and other systems
#
# Declarations
#

#! @Description
#!   Return a string which identifies the arguments of this function call
#! @Arguments obj
DeclareGlobalFunction("MEMO_Key");

#! @Description
#!   Return an SHA-256 hash string for the key
#! @Arguments obj
DeclareGlobalFunction("MEMO_Hash");

#! @Description
#!   Return the filename to use for a call, based on its key
#! @Arguments memo, key, ext
DeclareGlobalFunction("MEMO_KeyToFilename");

#! @Description
#!  Return the key used to create a given filename, assuming an unhash function
#!  was provided
#! @Arguments memo, filename
DeclareGlobalFunction("MEMO_FilenameToKey");

#! @Description
#!   Default directory to store memoisation tables
BindGlobal("MEMO_StoreDir", "./memo/");

#! @Description
#!   Filename extension for memoisation tables
BindGlobal("MEMO_FileExt", "out");

#! @Description
#!   Clear the memoisation tables of the given functions, or clear all
#!   memoisation tables if one is not given
#! @Arguments funcs
DeclareGlobalFunction("MEMO_ClearStore");

DeclareGlobalFunction("MEMO_CreateDirRecursively");

#! @Description
#!   Return a new function that acts the same as func, but using memoisation.
#!   The result will be retrieved from the store if possible, or computed and
#!   added to the store otherwise.
#! @Arguments func
DeclareGlobalFunction("MemoisedFunction");

DeclareCategory("IsMemoisedFunction", IsFunction);

#DeclareOperation("CallFuncList", [IsMemoisedFunction, IsList]);

BindGlobal("MEMO_OUT", ".out");
BindGlobal("MEMO_KEY", ".key");
