#! @Chapter Types of cache
#!
#! A memoised function stores its results in a **cache**; that is, a backend
#! that stores computed values, along with hashes of their keys.  If
#! appropriate, the key itself and any metadata will also be stored in the
#! cache.
#!
#! Users can decide what type of cache they wish to use by specifying the
#! `cache` option to <Ref Func="MemoisedFunction" />: a string starting with
#! "file://" will create a disk cache (see Section <Ref
#! Label="Section_DiskCache"/>), and a string starting with "mongodb://" will
#! create a MongoDB cache (see Section <Ref Label="Section_MongoDBCache"/>).

#! @Section Internals

#! A user will generally not need to interact directly with the cache, which
#! should be viewed as a backend to a memoised function.  However, one can
#! access the object directly by adding `!.cache` to a memoised function.

#! @Description
#!   Generic category for memoisation caches (backends).
#!
#!   An object of this type is created automatically by
#!   <Ref Func="MemoisedFunction" />, and is stored in the `!.cache` component
#!   of the memoised function.  A cache implements `IsLookupDictionary`, and so
#!   entries can be manually added, searched, and looked up using
#!   `AddDictionary`, `KnowsDictionary` and `LookupDictionary`.
#!
#! @BeginExample
#! gap> memo := MemoisedFunction(x -> x * x, rec(funcname := "square"));;
#! gap> memo!.cache;
#! <lookup dictionary>
#! gap> MEMO_IsCache(memo!.cache);
#! true
#! gap> AddDictionary(memo!.cache, 4, 16);
#! gap> KnowsDictionary(memo!.cache, 4);
#! true
#! gap> LookupDictionary(memo!.cache, 4);
#! 16
#! @EndExample
DeclareCategory("MEMO_IsCache", IsLookupDictionary);

DeclareOperation("AddDictionary", [MEMO_IsCache, IsObject, IsObject]);
# KnowsDictionary and LookupDictionary are declared elsewhere.

DeclareOperation("MEMO_ClearCache", [MEMO_IsCache]);  # Delete all entries

#! @Section Disk cache
#! @SectionLabel DiskCache

#! @Section MongoDB cache
#! @SectionLabel MongoDBCache
