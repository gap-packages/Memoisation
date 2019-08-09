#
# Memoisation: Shared persistent memoisation library for GAP and other systems
#
# Declarations
#

#! @Description
#!   Return a hash string for the key using IO_Pickle, SHA-256, and base 64.
#!   This is the default method which users can override by specifying `hash`.
#! @Arguments key
DeclareGlobalFunction("MEMO_Hash");

#! @Description
#!   Default backend for storage: disk storage in the local directory 'memo'.
BindGlobal("MEMO_DefaultCache", "file://memo/");

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

DeclareInfoClass("InfoMemoisation");
SetInfoLevel(InfoMemoisation, 2);
