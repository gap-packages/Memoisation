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

  return memo;
end);

InstallMethod(CallFuncList,
"for a memoised function",
[IsMemoisedFunction, IsList],
function(memo, args)
  local key, filename, key_filename, metadata_filename, storedkey, key_str, str,
        result, write, metadata_str;

    # Directory
    MEMO_CreateDirRecursively(memo!.dir);

    # Compute memoisation stuff
    key := memo!.key(args);
    Info(InfoMemoisation, 2, "Memo key: ", key);
    filename := MEMO_KeyToFilename(memo, key, MEMO_OUT);
    Info(InfoMemoisation, 2, "Using filename ", filename);

    # Other filenames we might not need
    key_filename := MEMO_KeyToFilename(memo, key, MEMO_KEY);
    metadata_filename := MEMO_KeyToFilename(memo, key, MEMO_META);

    if memo!.unhash <> fail then
      # Check injectivity
      storedkey := MEMO_FilenameToKey(memo, filename);
      if storedkey <> key then
        Error("Hash collision: unhash is not the inverse of hash");
      fi;
    fi;

    if IsReadableFile(filename) then
      # Retrieve cached answer
      Info(InfoMemoisation, 2, "File exists - reading...");
      if memo!.storekey then
        key_str := StringFile(key_filename);
        storedkey := memo!.unpickle(key_str);
        if key <> storedkey then
          Error("Hash collision: stored key does not match");
        fi;
        Info(InfoMemoisation, 2, "Key matches ", key_filename);
      fi;
      str := StringFile(filename);
      Info(InfoMemoisation, 3, "Got ", Length(str), " bytes from file");
      result := memo!.unpickle(str);
      Info(InfoMemoisation, 2, "Got cached result from file");
      if Size(args) = 1 and
         (IsAttribute(memo!.func) or IsProperty(memo!.func)) then
        Info(InfoMemoisation, 3, "Setting attribute");
        Setter(memo!.func)(args[1], result);
      fi;
    else
      # Compute and store
      result := CallFuncList(memo!.func, args);
      str := memo!.pickle(result);
      Info(InfoMemoisation, 2, "File does not exist - computing result...");
      write := FileString(filename, str);
      if write = fail then
        Error("Memoisation: could not write result to ", filename);
        # user can "return;" and result will still be returned
      fi;
      Info(InfoMemoisation, 2, "Result stored in file");
      # Store key
      if memo!.storekey then
        key_str := memo!.pickle(key);
        FileString(key_filename, key_str);
        Info(InfoMemoisation, 2, "Key stored at ", key_filename);
      fi;
      # Store metadata
      if memo!.metadata <> fail then
        metadata_str := memo!.metadata();
        Info(InfoMemoisation, 2, "Metadata stored at ", metadata_filename);
        FileString(metadata_filename, metadata_str);
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

InstallGlobalFunction(MEMO_FilenameToKey,
function(memo, filename)
  local pos, h;
  if StartsWith(filename, memo!.dir) then  # remove directory
    filename := filename{[Length(memo!.dir) + 2 .. Length(filename)]};
  fi;
  # Remove extension
  pos := Remove(Positions(filename, '.'));  # position of final dot
  h := filename{[1 .. pos - 1]};
  return memo!.unhash(h);
end);

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
