#
# Memoisation: Shared persistent memoisation library for GAP and other systems
#
# Implementations
#

InstallGlobalFunction(MemoisedFunction,
function(func)
  return function(args...)
    local basedir, funcdir, dir, key, hash, filename, str, result;

    # Directory
    basedir := MEMOISATION_StoreDir;
    CreateDir(basedir);
    funcdir := NameFunction(func);
    dir := Filename(Directory(basedir), funcdir);
    CreateDir(dir);
    Print("Using directory ", dir, "\n");

    # Compute memoisation stuff
    key := MEMOISATION_Key(args);
    Print("Got key ", key, "\n");
    hash := MEMOISATION_Hash(key);
    Print("Hashed to ", hash, "\n");
    filename := Filename(Directory(dir), MEMOISATION_HashToFilename(hash));

    if IsReadableFile(filename) then
      # Retrieve cached answer
      Print("Getting cached answer from ", filename, "...\n");
      str := StringFile(filename);
      Print("Got string ", str, "\n");
      result := IO_Unpickle(str);
      if Size(args) = 1 and (IsAttribute(func) or IsProperty(func)) then
        Print("Setting attribute/property\n");
        Setter(func)(args[1], result);
      fi;
    else
      # Compute and store
      result := CallFuncList(func, args);
      str := IO_Pickle(result);
      FileString(filename, str);
    fi;

    return result;
  end;
end);

InstallGlobalFunction(MEMOISATION_HashToFilename,
function(hash)
  return Concatenation(hash, ".out");
end);

InstallGlobalFunction(MEMOISATION_ClearStore,
function(funcs...)
  local func;
  if IsEmpty(funcs) then
    RemoveDirectoryRecursively(MEMOISATION_StoreDir);
  fi;
  for func in funcs do
    RemoveFile(Concatenation(MEMOISATION_StoreDir,
                             NameFunction(func),
                             MEMOISATION_FileExt));
  od;
end);

#
# 2. Helper functions
#

InstallGlobalFunction(MEMOISATION_Key,
function(args_list)
  return args_list;
end);

InstallGlobalFunction(MEMOISATION_Hash,
function(key)
  local str, ints, sum, i;
  str := IO_Pickle(key);  # Pickle the key to a string
  ints := SHA256String(str);  # Get the SHA-256 checksum in 32-bit chunks
  sum := 0;  # Bring all 256 bits together into a single integer
  for i in [1..Length(ints)] do
    sum := sum + ints[i] * 2 ^ (32 * (i-1));
  od;
  str := MEMOISATION_Digits(sum, 64, 43);  # Make into a padded base-64 string
  return str;
end);
