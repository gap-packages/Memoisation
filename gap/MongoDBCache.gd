#! @Chapter Types of cache

#! @Section MongoDB cache

#! We can cache using MongoDB

DeclareGlobalFunction("MEMO_MongoDBCache");
DeclareCategory("MEMO_IsMongoDBCache", MEMO_IsCache);

# Default namespace for server
BindGlobal("MEMO_MongoDBNamespace", "gapmemo");  # TODO: make configurable

# Helper function for KnowsDictionary and LookupDictionary
DeclareGlobalFunction("MEMO_MongoDBQuery");
