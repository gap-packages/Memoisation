#
# Memoisation: Shared persistent memoisation library for GAP and other systems
#
# Implementations
#

InstallGlobalFunction(MemoisedFunction,
function(func, args...)
  local opts, funcname, key, storekey, pickle, unpickle, hash, unhash, metadata,
        rnam, memo, type, pos, typestring, path, cachetypes, cachetype;

  # Default options
  opts := rec(cache := MEMO_DefaultCache,
              funcname := NameFunction(func),
              key := IdFunc,  # default: use args as key
              storekey := false,
              pickle := IO_Pickle,
              unpickle := IO_Unpickle,
              hash := MEMO_Hash,
              unhash := fail,
              metadata := fail);

  # Process optional argument
  if Length(args) = 1 then
    if not IsRecord(opts) then
      ErrorNoReturn("Memoisation: MemoisedFunction: ",
                    "2nd argument <opts> should be a record");
    fi;
    # Import user options
    for rnam in RecNames(args[1]) do
      opts.(rnam) := args[1].(rnam);
    od;
  elif Length(args) > 1 then
    ErrorNoReturn("Memoisation: MemoisedFunction takes 1 or 2 arguments, not ",
                  Length(args) + 1);
  fi;

  # Checks
  if opts.funcname = "unknown" then
    ErrorNoReturn("Memoisation: memoised function <func> has no name,\n",
                  "and no funcname was specified");
  fi;

  # Make the record
  memo := rec(
               func := func,
               funcname := opts.funcname,
               key := opts.key,
               storekey := opts.storekey,
               pickle := opts.pickle,
               unpickle := opts.unpickle,
               hash := opts.hash,
               unhash := opts.unhash,
               metadata := opts.metadata
             );

  # Objectify
  type := NewType(FunctionsFamily, IsMemoisedFunction);
  memo := Objectify(type, memo);

  # Determine which backend to use
  pos := PositionSublist(opts.cache, "://");
  if pos = fail then  # no backend specified: use disk
    typestring := "file";
    path := opts.cache;
  else
    typestring := opts.cache{[1 .. pos-1]};
    path := opts.cache{[pos+3 .. Length(opts.cache)]};
  fi;
  cachetypes := rec(file := MEMO_DiskCache);  # , mongodb := MEMO_MongoDBCache);
  if not typestring in RecNames(cachetypes) then
    ErrorNoReturn("Memoisation: MemoisedFunction: <cache> cannot start with \"",
                  typestring, "://\"");
  fi;
  cachetype := cachetypes.(typestring);

  # Create backend
  memo!.cache := cachetype(memo, path);

  return memo;
end);

InstallMethod(CallFuncList,
"for a memoised function",
[IsMemoisedFunction, IsList],
function(memo, args)
  local key, val;

  # Compute key
  key := memo!.key(args);
  Info(InfoMemoisation, 2, "Memo key: ", key);

  # Search in cache
  if KnowsDictionary(memo!.cache, key) then
    # Retrieve cached result
    Info(InfoMemoisation, 2, "Key known!  Loading result from cache...");
    val := LookupDictionary(memo!.cache, key);
  else
    # Compute and store result
    Info(InfoMemoisation, 2, "Key unknown.  Computing result...");
    val := CallFuncList(memo!.func, args);
    AddDictionary(memo!.cache, key, val);
  fi;

  # Set attribute/property
  if Size(args) = 1 and
     (IsAttribute(memo!.func) or IsProperty(memo!.func)) and
     not Tester(memo!.func)(args[1]) then
    Info(InfoMemoisation, 3, "Setting attribute ", NameFunction(memo!.func));
    Setter(memo!.func)(args[1], val);
  fi;

  return val;
end);

InstallMethod(ViewObj,
"for a memoised function",
[IsMemoisedFunction],
function(memo)
  Print("<memoised ");
  ViewObj(memo!.func);
  Print(">");
end);

InstallMethod(PrintObj,
"for a memoised function",
[IsMemoisedFunction],
function(memo)
  Print("MemoisedFunction(\n");
  PrintObj(memo!.func);
  Print(",\nrec(funcname := \"", memo!.funcname, "\") )");
end);

for delegated_function in [NamesLocalVariablesFunction,
                           NumberArgumentsFunction] do
  InstallMethod(delegated_function,
                "for a memoised function",
                [IsMemoisedFunction],
                memo -> delegated_function(memo!.func));
od;

# InstallGlobalFunction(MEMO_ClearStore,
# function(funcs...)
#   local func;
#   if IsEmpty(funcs) then
#     RemoveDirectoryRecursively(MEMO_StoreDir);
#   fi;
#   for func in funcs do
#     RemoveFile(Concatenation(MEMO_StoreDir,
#                              NameFunction(func),
#                              MEMO_FileExt));
#   od;
# end);

#
# 2. Helper functions
#

InstallGlobalFunction(MEMO_CreateDirRecursively,
function(dir)
  # Borrowed from PackageManager
  local path, newdir, i, res;
  path := SplitString(dir, "/");
  newdir := "";
  for i in [1 .. Length(path)] do
    Append(newdir, path[i]);
    Append(newdir, "/");
    if not IsDirectoryPath(newdir) then
      res := CreateDir(newdir);
      if res <> true then
        return fail;
      fi;
    fi;
  od;
  return true;
end);

InstallGlobalFunction(MEMO_Hash,
function(key)
  local str, ints, sum, i;
  str := IO_Pickle(key);  # Pickle the key to a string
  ints := SHA256String(str);  # Get the SHA-256 checksum in 32-bit chunks
  sum := 0;  # Bring all 256 bits together into a single integer
  for i in [1..Length(ints)] do
    sum := sum + ints[i] * 2 ^ (32 * (i-1));
  od;
  str := MEMO_Digits(sum, 64, 43);  # Make into a padded base-64 string
  return str;
end);
