#! @Description
#!   Return a special function object in the category `IsMemoisedFunction`.
#!   This will be functionally the same as `func`, but using persistent
#!   memoisation to store and retrieve results from a cache.
#!
#!   If the optional argument `opts` is specified, it should be a record which
#!   customises how this memoisation is done.
#!
#! @Arguments func[, opts]
DeclareGlobalFunction("MemoisedFunction");

#! @Description
#!   This category contains all memoised functions, special objects which wrap a
#!   function and store previously computed results in a cache, avoiding
#!   recomputation wherever possible.
#!
#!   For more information, and to create these objects, see `MemoisedFunction`.
DeclareCategory("IsMemoisedFunction", IsFunction);

#! @Description
#!   Clear all known memoised results from the cache of this memoised function.
#!   Return `true` if the operation was successful, and `fail` otherwise.
#! @Returns 
#!   true or fail
DeclareOperation("ClearMemoisedFunction", [IsMemoisedFunction]);

#! @Description
#!   Info class for the Memoisation package.  Set this to the following levels
#!   for different levels of information:
#!     * 0 - No messages
#!     * 1 - Problems only: messages describing what went wrong, with no
#!           messages if an operation is successful
#!     * 2 - Progress: also shows step-by-step progress of operations
#!     * 3 - All: includes extra information such as setting attributes
#!
#!   Set this using, for example `SetInfoLevel(InfoMemoisation, 1)`.
#!   Default value is 2.
DeclareInfoClass("InfoMemoisation");
SetInfoLevel(InfoMemoisation, 2);

#! @Description
#!   Default memoisation backend: disk storage in the local directory 'memo'.
#!   This is the default `cache` option in `MemoisedFunction`.
BindGlobal("MEMO_DefaultCache", "file://memo/");
