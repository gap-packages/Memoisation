#
# Memoisation: Shared persistent memoisation library for GAP and other systems
#
# Implementations
#

InstallGlobalFunction(MemoisedFunction,
function(func)
  return function(args...)
    local filename, hash, out_stream, in_stream, line, result;
    CreateDir(MEMOISATION_StoreDir);
    filename := Concatenation(MEMOISATION_StoreDir, NameFunction(func),
                              ".", MEMOISATION_FileExt);
    hash := MEMOISATION_Hash(args);
    Print(hash, "\n");
    out_stream := OutputTextFile(filename, true);
    SetPrintFormattingStatus(out_stream, false);
    in_stream := InputTextFile(filename);
    line := ReadLine(in_stream);
    while line <> fail do
      line := SplitString(line, ";\n");
      if line[1] = hash then
        result := EvalString(line[2]);
        Print("setting? ", Size(args), "\n");
        if Size(args) = 1 and (IsAttribute(func) or IsProperty(func)) then
          Print("setting!\n");
          Setter(func)(args[1], result);
        fi;
        return result;
      fi;
      line := ReadLine(in_stream);
    od;
    Print("computing fresh...\n");
    result := CallFuncList(func, args);
    PrintTo(out_stream, hash, ";", result, "\n");
    CloseStream(out_stream);
    return result;
  end;
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

InstallGlobalFunction(MEMOISATION_Hash,
function(obj)
  local key, ints, sum, i, str;
  key := MEMOISATION_Key(obj);  # Get the key
  ints := SHA256String(key);  # Get the SHA-256 checksum in 32-bit chunks
  sum := 0;  # Bring all 256 bits together into a single integer
  for i in [1..Length(ints)] do
    sum := sum + ints[i] * 2 ^ (32 * (i-1));
  od;
  str := MEMOISATION_Digits(sum, 64, 43);  # Make into a padded base-64 string
  return str;
end);

#
# 3. Key methods for various objects
#

InstallMethod(MEMOISATION_Key,
"for a group with generators",
[IsGroup and HasGeneratorsOfGroup],
G -> Concatenation("Group(", String(GeneratorsSmallest(G)), ")"));

InstallMethod(MEMOISATION_Key,
"for an object",
[IsObject],
IO_Pickle);
