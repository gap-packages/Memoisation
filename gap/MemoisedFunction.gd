#! @Chapter Commands

#! @Section Memoised functions

#! @Description
#!   Return a special function object in the category `IsMemoisedFunction`.
#!   This will be functionally the same as `func`, but using persistent
#!   memoisation to store and retrieve results from a cache.
#!
#!   If the optional argument `opts` is specified, it should be a record of
#!   options that customise how this memoisation is done.  The following options
#!   are supported:
#!     * `cache` - string that starts with either "file://" or "mongodb://".
#!       This prefix determines which type of cache backend is used: files on
#!       the local disk or a MongoDB server.  The rest of the string should be a
#!       path to the directory of the disk cache, or a URL for the MongoDB
#!       server.  Default is "file://memo/".
#!     * `funcname` - string that will be used to uniquely describe this
#!       function, among all functions being stored in the present `cache`.  If
#!       two functions have the same `cache` and the same `funcname`, they will
#!       save and load each others' cached results.  If `NameFunction(func)` is
#!       "unknown", (e.g. if `func` was only defined inside this call to
#!       `MemoisedFunction`) then specifying a `funcname` is mandatory;
#!       otherwise, `NameFunction(func)` will be used by default.
#!     * `key` - function that takes the same arguments as `func` and returns
#!       an object (a __key__).  The `key` function should be chosen such that,
#!       for two sets of arguments `X` and `Y`, `key(X) = key(Y)` implies
#!       `func(X) = func(Y)`.  The default simply returns a list of the
#!       arguments, but one could specify a different `key` function in order to
#!       reorder arguments or discard any that have no functional effect.
#!     * `storekey` - boolean specifying whether to store the key along with
#!       the output when a result is stored.  If `true`, the key will be checked
#!       when recalling a previously computed value, to check for hash
#!       collisions.  If `false`, two keys will produce the same output whenever
#!       their `hash` values are the same.  Default is `false`.
#!     * `pickle` - function that converts the output of `func` to a string for
#!       storage.  Should be the inverse of `unpickle`.  If `storekey` is true,
#!       this will also be used to store the key.  Default is `IO_Pickle`, which
#!       does not work for all objects.
#!     * `unpickle` - function that converts a string back to an object when
#!       retrieving a computed value from storage.  Should be the inverse of
#!       `pickle`.  If `storekey` is `true`, this will also be used to retrieve
#!       the key.  Default is `IO_Unpickle`, which does not work for all
#!       objects.
#!     * `hash` - function that takes a key and produces a string that will be
#!       used to identify that key.  If this function is not injective, then
#!       `storekey` can be set to `true` to check for hash collisions.  The
#!       string should only contain characters safe for filenames.  Default uses
#!       `IO_Pickle`, SHA-256 and base 64 encoding, which has an extremely small
#!       chance of collision.
#!     * `unhash` - function that, if specified, should be the inverse of
#!       `hash`.  If this is specified, keys will be unhashed after hashing, to
#!       make sure that no mistakes were made.
#!     * `metadata` - function that takes no arguments and returns a string
#!       containing metadata to be stored with the result currently being
#!       written.  This might include the current time, or some data identifying
#!       the user or system that ran the computation.
#!
#! @BeginExample
#! gap> triple := x -> x * 3;
#! function( x ) ... end
#! gap> mtriple := MemoisedFunction(triple);
#! <memoised function( x ) ... end>
#! gap> mtriple(3);
#! #I  Memo key: [ 3 ]
#! #I  Key unknown.  Computing result...
#! 9
#! gap> mtriple(3);
#! #I  Memo key: [ 3 ]
#! #I  Key known!  Loading result from cache...
#! 9
#! @EndExample
#!
#! @BeginExample
#! gap> msize := MemoisedFunction(Size, rec(key := GeneratorsOfGroup,
#! >                                        storekey := true,
#! >                                        cache := "file://~/Desktop/mycache"));
#! <memoised <Attribute "Size">>
#! gap> msize(SymmetricGroup(6));
#! #I  Memo key: [ (1,2,3,4,5,6), (1,2) ]
#! #I  Key unknown.  Computing result...
#! 720
#! gap> msize(Group((5,6,1,2,3,4), (1,2)));
#! #I  Memo key: [ (1,2,3,4,5,6), (1,2) ]
#! #I  Key known!  Loading result from cache...
#! 720
#! @EndExample
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
#!   Return `true` if the operation was successful, and `false` otherwise.
#! @BeginExample
#! gap> triple := MemoisedFunction(x -> x*3,
#! >                               rec(storekey := true,
#! >                                   key := IdFunc,
#! >                                   hash := String,
#! >                                   funcname := "triple_any_number"));;
#! gap> ClearMemoisedFunction(triple);
#! true
#! @EndExample
#!
#! @Arguments memo
#! @Returns
#!   true or false
DeclareOperation("ClearMemoisedFunction", [IsMemoisedFunction]);

#! @Description
#!   Info class for the Memoisation package.  Set this to the following levels
#!   for different levels of information:
#!     * 0 - No messages
#!     * 1 - Problems only: messages describing what went wrong, with no
#!           messages if an operation is successful
#!     * 2 - Progress: also shows step-by-step progress of operations
#!     * 3 - All: includes extra information such as attributes and backends
#!
#!   Set this using, for example `SetInfoLevel(InfoMemoisation, 1)`.
#!   Default value is 2.
DeclareInfoClass("InfoMemoisation");
SetInfoLevel(InfoMemoisation, 2);

#  Default memoisation backend: disk storage in the local directory 'memo'.
#  This is the default `cache` option in `MemoisedFunction`.
BindGlobal("MEMO_DefaultCache", "file://memo/");
