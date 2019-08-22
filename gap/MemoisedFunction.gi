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
              key := {args...} -> args,  # default: use list of args as key
              storekey := false,
              pickle := IO_Pickle,
              unpickle := IO_Unpickle,
              hash := MEMO_Hash,
              unhash := fail,  # TODO: iterate through keys (storekey or unhash)
              metadata := fail);

  # Process optional argument
  if Length(args) = 1 then
    if not IsRecord(args[1]) then
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
  cachetypes := rec(file := MEMO_DiskCache, mongodb := MEMO_MongoDBCache);
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

  # In case IO_Pickle was recently interrupted
  if memo!.pickle = IO_Pickle or memo!.unpickle = IO_Unpickle then
    IO_ClearPickleCache();
  fi;

  # Compute key
  key := CallFuncList(memo!.key, args);
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

InstallMethod(ClearMemoisedFunction,
"for a memoised function",
[IsMemoisedFunction],
function(memo)
  return MEMO_ClearCache(memo!.cache);
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
