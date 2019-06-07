#
# Memoisation: Shared persistent memoisation library for GAP and other systems
#
# Implementations
#

InstallGlobalFunction(MemoisedFunction,
function(func)
  local basedir, funcName, dir, memo, type;

  # Defaults
  basedir := MEMO_StoreDir;
  funcName := NameFunction(func);
  dir := Filename(Directory(basedir), funcName);

  # Checks
  if funcName = "unknown" then
    ErrorNoReturn("Memoisation: memoised function <func> has no name,\n",
                  "and no funcName was specified");
  fi;

  # Make the record
  memo := rec(func := func,
              basedir := basedir,
              funcName := funcName,
              dir := dir);

  # Objectify
  type := NewType(FunctionsFamily, IsMemoisedFunction);
  memo := Objectify(type, memo);

  return memo;
end);

InstallMethod(CallFuncList,
"for a memoised function",
[IsMemoisedFunction, IsList],
function(memo, args)
  local key, hash, filename, str, result;

    # Directory
    CreateDir(memo!.basedir);
    CreateDir(memo!.dir);
    Print("Using directory ", memo!.dir, "\n");

    # Compute memoisation stuff
    key := MEMO_Key(args);
    Print("Got key ", key, "\n");
    hash := MEMO_Hash(key);
    Print("Hashed to ", hash, "\n");
    filename := Filename(Directory(memo!.dir), MEMO_HashToFilename(hash));

    if IsReadableFile(filename) then
      # Retrieve cached answer
      Print("Getting cached answer from ", filename, "...\n");
      str := StringFile(filename);
      Print("Got string of length ", Length(str), " to unpickle\n");
      result := IO_Unpickle(str);
      if Size(args) = 1 and
         (IsAttribute(memo!.func) or IsProperty(memo!.func)) then
        Print("Setting attribute/property\n");
        Setter(memo!.func)(args[1], result);
      fi;
    else
      # Compute and store
      result := CallFuncList(memo!.func, args);
      str := IO_Pickle(result);
      FileString(filename, str);
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
  Print("MemoisedFunction( ");
  PrintObj(memo!.func);
  Print(" )");
end);

for delegated_function in [NamesLocalVariablesFunction,
                           NumberArgumentsFunction] do
  InstallMethod(delegated_function,
                "for a memoised function",
                [IsMemoisedFunction],
                memo -> delegated_function(memo!.func));
od;

InstallGlobalFunction(MEMO_HashToFilename,
function(hash)
  return Concatenation(hash, ".out");
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

InstallGlobalFunction(MEMO_Key,
function(args_list)
  return args_list;
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
