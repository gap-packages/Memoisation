#
# Memoisation: Shared persistent memoisation library for GAP and other systems
#
# Implementations
#

InstallGlobalFunction(MemoisedFunction,
function(func, args...)
  local opts, funcname, key, storekey, pickle, unpickle, hash, unhash, metadata,
        rnam, basedir, dir, memo, cache, type;

  # Default options
  opts := rec(cache := "file://memo/",
              funcname := NameFunction(func),
              key := IdFunc,  # default: use args as key
              storekey := false,  # TODO
              pickle := IO_Pickle,
              unpickle := IO_Unpickle,
              hash := MEMO_Hash,
              unhash := fail,  # TODO
              metadata := fail);  # TODO

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

  # Directory to use for results
  basedir := opts.cache{[Length("file://") + 1 .. Length(opts.cache)]};  # TODO
  dir := Filename(Directory(basedir), opts.funcname);

  # Make the record
  memo := rec(
               func := func,
               dir := dir,
               cache := opts.cache,
               funcname := opts.funcname,
               key := opts.key,
               pickle := opts.pickle,
               unpickle := opts.unpickle,
               hash := opts.hash,
             );

  # Objectify
  type := NewType(FunctionsFamily, IsMemoisedFunction);
  memo := Objectify(type, memo);

  return memo;
end);

InstallMethod(CallFuncList,
"for a memoised function",
[IsMemoisedFunction, IsList],
function(memo, args)
  local key, filename, key_filename, key_str, storedkey, str, result;

    # Directory
    MEMO_CreateDirRecursively(memo!.dir);
    Print("Using directory ", memo!.dir, "\n");

    # Compute memoisation stuff
    key := memo!.key(args);
    Print("Got key ", key, "\n");
    filename := MEMO_KeyToFilename(memo, key, MEMO_OUT);
    Print("Using filename ", filename, "\n");
    key_filename := MEMO_KeyToFilename(memo, key, MEMO_KEY);

    if IsReadableFile(filename) then
      # Retrieve cached answer
      Print("Getting cached answer from ", filename, "...\n");
      if memo!.storekey then
        Print("Checking key in ", key_filename, "...\n");
        key_str := StringFile(key_filename);
        storedkey := memo!.unpickle(key_str);
        if key <> storedkey then
          Error("Hash collision: stored key does not match");
        fi;
      fi;
      str := StringFile(filename);
      Print("Got string of length ", Length(str), " to unpickle\n");
      result := memo!.unpickle(str);
      if Size(args) = 1 and
         (IsAttribute(memo!.func) or IsProperty(memo!.func)) then
        Print("Setting attribute/property\n");
        Setter(memo!.func)(args[1], result);
      fi;
    else
      # Compute and store
      result := CallFuncList(memo!.func, args);
      str := memo!.pickle(result);
      FileString(filename, str);
      # Store key
      if memo!.storekey then
        key_str := memo!.pickle(key);
        Print("Storing key at ", key_str, "...\n");
        FileString(key_filename, key_str);
      fi;
    fi;

    return result;
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

InstallGlobalFunction(MEMO_KeyToFilename,
function(memo, key, ext)
  local h, fname;
  h := memo!.hash(key);
  fname := Concatenation(h, ext);
  return Filename(Directory(memo!.dir), fname);
end);

InstallGlobalFunction(MEMO_ClearStore,
function(funcs...)
  local func;
  if IsEmpty(funcs) then
    RemoveDirectoryRecursively(MEMO_StoreDir);
  fi;
  for func in funcs do
    RemoveFile(Concatenation(MEMO_StoreDir,
                             NameFunction(func),
                             MEMO_FileExt));
  od;
end);

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
