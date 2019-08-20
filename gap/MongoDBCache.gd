#! @Chapter Types of cache

#! @Section MongoDB cache

#! Instead of saving results to a local disk, we can instead save them to a
#! MongoDB database, which may be hosted remotely.
#!
#! To create a MongoDB cache, one should specify a `cache` option beginning with
#! "mongodb://" to <Ref Func="MemoisedFunction" />.  The rest of the string
#! after this prefix should be the URL of a server configured to handle **GAP
#! Memoisation** or **pypersist** requests.
#!
#! The appropriate files to configure such a server are located in the
#! `mongodb_server` directory inside this package.  Navigate into that directory
#! and run `python3 run.py` to start a local server (the **MongoDB** service and
#! the **eve** python package should both be installed).  This server can then
#! be accessed locally using `cache := "mongodb://localhost:5000/persist"`.
#!
#! @BeginExample
#! gap> quintuple := x -> x * 5;;
#! gap> mq := MemoisedFunction(quintuple,
#! >                rec(cache := "mongodb://localhost:5000/persist"));
#! <memoised function( x ) ... end>
#! gap> mq(101);
#! 505
#! gap> mq(101);
#! 505
#! gap> ClearMemoisedFunction(mq);
#! true
#! gap> MEMO_IsMongoDBCache(mq!.cache);
#! true
#! @EndExample
#!
#! To see details of the requests sent to and from the server, set
#! `InfoMemoisation` to at least 3.
#!
#! Using a remote server, multiple users can interact with the same database at
#! once, sharing results between them.  The same servers can be reached by
#! **pypersist** to store cached Python results.  By default, results from GAP
#! will be stored using the "gapmemo" namespace, and thus kept separate from
#! pypersist results.  However, if one wishes to share results with a
#! functionally similar pypersist function, one can change the value of
#! `MEMO_MongoDBNamespace` to "pypersist" to gain access to the same results.

DeclareGlobalFunction("MEMO_MongoDBCache");
DeclareCategory("MEMO_IsMongoDBCache", MEMO_IsCache);

# Default namespace for server
MEMO_MongoDBNamespace := "gapmemo";

# Helper function for KnowsDictionary and LookupDictionary
DeclareGlobalFunction("MEMO_MongoDBQuery");
