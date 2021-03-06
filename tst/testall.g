#
# Memoisation: Shared persistent memoisation library for GAP and other systems
#
# This file runs package tests. It is also referenced in the package
# metadata in PackageInfo.g.
#
LoadPackage( "Memoisation" );

# Use temporary cache directory
MakeReadWriteGlobal("MEMO_DefaultCache");
tmp_dir := Filename(DirectoryTemporary(), "");
MEMO_DefaultCache := Concatenation("file://", tmp_dir);

# Test info statements
SetInfoLevel(InfoMemoisation, 3);

# Use custom comparison function
compareFunction := function(expected, found)
  # MEMODIR should match the temporary directory
  expected := ReplacedString(expected, "MEMODIR/", tmp_dir);

  # breaks in long lines should be ignored
  expected := ReplacedString(expected, "\\\n", "");
  found := ReplacedString(found, "\\\n", "");

  return expected = found;
end;

# Any files to exclude?
if not IsBound(MEMO_ExcludeTestFiles) then
  MEMO_ExcludeTestFiles := [];
fi;

TestDirectory(DirectoriesPackageLibrary( "Memoisation", "tst" ),
              rec(exitGAP := true,
                  rewriteToFile := false,
                  exclude := MEMO_ExcludeTestFiles,
                  testOptions := rec(compareFunction := compareFunction)));

FORCE_QUIT_GAP(1); # if we ever get here, there was an error
