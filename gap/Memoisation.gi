#
# Memoisation: Shared persistent memoisation library for GAP and other systems
#
# Implementations
#

InstallGlobalFunction(MEMOISATION_Hash,
function(obj)
  local ints;
  ints := SHA256String(MEMOISATION_Key(obj));
  return Concatenation(List(ints, CRYPTING_HexStringIntPad8));
end);

InstallGlobalFunction(RunWithMemoisation,
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
# Key methods for various objects
#

# Simply use MathInTheMiddle for all objects

InstallMethod(MEMOISATION_Key,
"for an object",
[IsObject],
obj -> MitM_OMRecToXML(MitM_GAPToOMRec(obj)));

# InstallMethod(MEMOISATION_Key,
# "for a list",
# [IsList],
# L -> JoinStringsWithSeparator(List(L, MEMOISATION_Key), ";"));

# InstallMethod(MEMOISATION_Key,
# "for a group with generators",
# [IsGroup and HasGeneratorsOfGroup],
# G -> Concatenation("Group(", String(GeneratorsSmallest(G)), ")"));
