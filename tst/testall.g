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

TestDirectory(DirectoriesPackageLibrary( "Memoisation", "tst" ),
  rec(exitGAP := true));

FORCE_QUIT_GAP(1); # if we ever get here, there was an error
