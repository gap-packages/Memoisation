#! @Chapter Types of cache

#! @Section Disk cache

#! The default type of cache is a **disk cache**.  This cache saves and loads
#! results at a specified location in the filesystem, and these files can be
#! shared or edited by hand as desired.
#!
#! To create a disk cache, one should specify a `cache` option beginning with
#! "file://" to <Ref Func="MemoisedFunction" />.  The rest of the string after
#! this prefix should be a path to a directory on the local filesystem.
#! Memoised results will be stored inside this directory, inside a subdirectory
#! named after the memoised function's `funcname`.
#!
#! Consider the following example:
#!
#! @BeginExample
#! gap> ds := MemoisedFunction(DerivedSubgroup,
#! >                rec(cache := "file://results_for_alice/group_theory"));;
#! gap> ds(Group((1,2,3,4), (1,2)));
#! Group([ (1,3,2), (1,4,3) ])
#! gap> MEMO_IsDiskCache(ds!.cache);
#! true
#! @EndExample
#!
#! This will create a file called `HASH.out` in a subdirectory called
#! `results_for_alice/group_theory/DerivedSubgroup/` inside the local directory,
#! where `HASH` will be a hash of the key `[ Group([ (1,3,2), (1,4,3) ]) ]`.
#! The file will contain a pickled version of the function's output.
#!
#! To change the format of the filename, we could specify a different `hash`
#! option to <Ref Func="MemoisedFunction" />.  To change the format of the file
#! contents, we could specify different `pickle` and `unpickle` options.  This
#! could make the files human-readable or readable by another system:
#!
#! @BeginExample
#! gap> pow := MemoisedFunction(\^,
#! >                rec(funcname := "powers",
#! >                    cache := "file://arithmetic_results",
#! >                    hash := k -> StringFormatted("{}_to_the_{}", k[1], k[2]),
#! >                    pickle := z -> StringFormatted("The answer is {}.", z),
#! >                    unpickle := str -> Int(str{[15 .. Length(str)-1]})));;
#! gap> pow(2, 3);
#! 8
#! gap> pow(10, 5);; pow(1, 0);; pow(8, 4);;
#! gap> DirectoryContents("arithmetic_results/powers/");
#! [ ".", "..", "2_to_the_3.out", "10_to_the_5.out", "1_to_the_0.out",
#!   "8_to_the_4.out" ]
#! gap> StringFile("arithmetic_results/powers/10_to_the_5.out");
#! "The answer is 100000."
#! @EndExample
#!
#! If `storekey` is set to `true`, then a corresponding `HASH.key` file will be
#! created, and if `metadata` is specified, then a corresponding `HASH.meta`
#! file will also be created.
#!
#! By default, a memoised function will store its results in `memo/` in the
#! local directory.

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
