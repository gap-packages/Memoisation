#
# Memoisation: Shared persistent memoisation library for GAP and other systems
#
# Declarations
#

#! @Description
#!   Default backend for storage: disk storage in the local directory 'memo'.
BindGlobal("MEMO_DefaultCache", "file://memo/");

#! @Description
#!   Return a new function that acts the same as func, but using memoisation.
#!   The result will be retrieved from the store if possible, or computed and
#!   added to the store otherwise.
#! @Arguments func
DeclareGlobalFunction("MemoisedFunction");

DeclareCategory("IsMemoisedFunction", IsFunction);

#! @Description
#!   Clear all known memoised results from the cache of this memoised function.
#!   Return `true` if the operation was successful, and `fail` otherwise.
#! @Returns 
#!   true or fail
DeclareOperation("ClearMemoisedFunction", [IsMemoisedFunction]);

DeclareInfoClass("InfoMemoisation");
SetInfoLevel(InfoMemoisation, 2);
