#
# Memoisation: Shared persistent memoisation library for GAP and other systems
#
# This file runs package tests *excluding* MongoDBCache.tst.  This is for
# systems that can't run a local MongoDB service but still want to test the rest
# of the package.
#
MEMO_ExcludeTestFiles := ["MongoDBCache.tst"];
Read(Filename(DirectoriesPackageLibrary("Memoisation", "tst")[1], "testall.g"));
