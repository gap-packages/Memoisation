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
function(func, arg)
  local filename, hash, out_stream, in_stream, line, result;
  CreateDir(MEMOISATION_StoreDir);
  filename := Concatenation(MEMOISATION_StoreDir, NameFunction(func), ".mem");
  hash := MEMOISATION_Hash(arg);
  out_stream := OutputTextFile(filename, true);
  in_stream := InputTextFile(filename);
  line := ReadLine(in_stream);
  while line <> fail do
    line := SplitString(line, ";\n");
    if line[1] = hash then
      return EvalString(line[2]);
    fi;
    line := ReadLine(in_stream);
  od;
  result := func(arg);
  WriteLine(out_stream, Concatenation(hash, ";", String(result)));
  CloseStream(out_stream);
  return result;
end);

#
# Key methods for various objects
#

InstallMethod(MEMOISATION_Key,
"for a group with generators",
[IsGroup and HasGeneratorsOfGroup],
G -> String(GeneratorsOfGroup(G)));
# Note: GeneratorsSmallest recognises equality better
