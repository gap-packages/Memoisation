#
# Memoisation: Shared persistent memoisation library for GAP and other systems
#
# Declarations
#

#! @Description
#!   Return a string which identifies the object
#! @Arguments obj
DeclareAttribute("MEMOISATION_Key", IsObject);

#! @Description
#!   Return an SHA-256 hash string for the object, based on its MEMOISATION_Key
#! @Arguments obj
DeclareGlobalFunction("MEMOISATION_Hash");

#! @Description
#!   Default directory to store memoisation tables
BindGlobal("MEMOISATION_StoreDir", "./memo/");

#! @Description
#!   Find the return value of the given function with the given arguments.
#!   First hash the arguments and look them up in the appropriate memoisation
#!   tables.  If no entry exists, compute the value, add it to the table, and
#!   return it.
#! @Arguments func_name, arg
DeclareGlobalFunction("RunWithMemoisation");
