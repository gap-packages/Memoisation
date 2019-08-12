InstallGlobalFunction(MEMO_DiskCache,
function(memo, path)
  local dir, cache, type;

  # Directory for this function
  dir := Filename(Directory(path), memo!.funcname);

  # Make cache object
  cache := rec(memo := memo,  # memoised function
               dir := dir);  # directory for storing results
  # Objectify
  type := NewType(DictionariesFamily, MEMO_IsDiskCache);
  cache := Objectify(type, cache);

  return cache;
end);

InstallMethod(AddDictionary,
"for a memoisation disk cache and two objects",
[MEMO_IsDiskCache, IsObject, IsObject],
function(cache, key, val)
  local memo, filename, storedkey, str, write, key_filename, key_str,
        metadata_filename, metadata_str;
  memo := cache!.memo;

  # Create directory if needed
  if not IsDirectoryPath(cache!.dir) then
    MEMO_CreateDirRecursively(cache!.dir);
  fi;

  # Get filename for storage
  filename := MEMO_KeyToFilename(cache, key, MEMO_OUT);
  Info(InfoMemoisation, 2, "Using filename ", filename);

  # OPTION: unhash
  if memo!.unhash <> fail then
    # unhash and check if key still matches
    storedkey := MEMO_FilenameToKey(cache, filename);
    if key <> storedkey then
      ErrorNoReturn("Hash collision: <key> does not match <storedkey>");
    fi;
  fi;

  # Write to disk
  str := memo!.pickle(val);
  write := FileString(filename, str);
  if write = fail then
    Error("Memoisation: could not write result to ", filename);
    # user can "return;" and result will still be returned
  else
    Info(InfoMemoisation, 2, "Result stored in file");
  fi;

  # OPTION: storekey
  if memo!.storekey then
    key_filename := MEMO_KeyToFilename(cache, key, MEMO_KEY);
    key_str := memo!.pickle(key);
    FileString(key_filename, key_str);
    Info(InfoMemoisation, 2, "Key stored at ", key_filename);
  fi;

  # OPTION: metadata
  if memo!.metadata <> fail then
    metadata_filename := MEMO_KeyToFilename(cache, key, MEMO_META);
    metadata_str := memo!.metadata();
    FileString(metadata_filename, metadata_str);
    Info(InfoMemoisation, 2, "Metadata stored at ", metadata_filename);
  fi;

  # no return value
end);

InstallMethod(KnowsDictionary,
"for a memoisation disk cache and an object",
[MEMO_IsDiskCache, IsObject],
function(cache, key)
  local filename;
  filename := MEMO_KeyToFilename(cache, key, MEMO_OUT);
  return IsReadableFile(filename);
end);

InstallMethod(LookupDictionary,
"for a memoisation disk cache and an object",
[MEMO_IsDiskCache, IsObject],
function(cache, key)
  local memo, filename, key_filename, key_str, storedkey, str, val;
  memo := cache!.memo;

  # Get filename
  filename := MEMO_KeyToFilename(cache, key, MEMO_OUT);
  Info(InfoMemoisation, 2, "Using filename ", filename);
  if not IsReadableFile(filename) then
    # We shouldn't normally get here, as we usually check KnowsDictionary first
    Info(InfoMemoisation, 1, "File ", filename, "not readable");
    return fail;
  fi;

  # OPTION: storekey
  if memo!.storekey then
    key_filename := MEMO_KeyToFilename(cache, key, MEMO_KEY);
    key_str := StringFile(key_filename);
    storedkey := memo!.unpickle(key_str);
    # check if key still matches
    if key <> storedkey then
      ErrorNoReturn("Hash collision: <key> does not match <storedkey>");
    fi;
    Info(InfoMemoisation, 2, "Key matches ", key_filename);
  fi;

  # Load result
  str := StringFile(filename);
  Info(InfoMemoisation, 3, "Got ", Length(str), " bytes from file");
  val := memo!.unpickle(str);
  Info(InfoMemoisation, 2, "Got cached result from file");

  return val;
end);

InstallMethod(MEMO_ClearCache,
"for a memoisation disk cache",
[MEMO_IsDiskCache],
function(cache)
  local dir, file, ext, path, result;
  dir := cache!.dir;
  if not IsDirectoryPath(dir) then
    return true;
  fi;
  for file in DirectoryContents(dir) do
    for ext in [MEMO_OUT, MEMO_KEY, MEMO_META] do
      if EndsWith(file, ext) then
        path := Filename(Directory(dir), file);
        if RemoveFile(path) <> true then
          Info(InfoMemoisation, 1, "Failed to delete ", path);
        fi;
      fi;
    od;
  od;
  result := RemoveDir(dir);
  if result = true then
    return true;
  fi;
  return false;
end);

InstallGlobalFunction(MEMO_KeyToFilename,
function(cache, key, ext)
  local h, fname;
  h := cache!.memo!.hash(key);
  fname := Concatenation(h, ext);
  return Filename(Directory(cache!.dir), fname);
end);

InstallGlobalFunction(MEMO_FilenameToKey,
function(cache, filename)
  local pos, h;
  if StartsWith(filename, cache!.dir) then  # remove directory
    filename := filename{[Length(cache!.dir) + 2 .. Length(filename)]};
  fi;
  # Remove extension
  pos := Remove(Positions(filename, '.'));  # position of final dot
  h := filename{[1 .. pos - 1]};
  return cache!.memo!.unhash(h);
end);

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
