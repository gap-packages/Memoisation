#
# Declarations for MEMO_IsCache, the generic category for memoisation backends.
#
# There is no corresponding .gi file, since only subcategories are implemented.
#
# To create a MEMO_IsCache object, use e.g. MEMO_DiskCache or MEMO_MongoDBCache,
# and the appropriate methods will be used.
#

DeclareCategory("MEMO_IsCache", IsLookupDictionary);

# Add an entry to the cache.
DeclareOperation("AddDictionary", [MEMO_IsCache, IsObject, IsObject]);

# KnowsDictionary and LookupDictionary are declared elsewhere.

# Delete all memoised information in this cache
DeclareOperation("MEMO_ClearCache", [MEMO_IsCache]);
