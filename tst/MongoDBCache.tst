# Start MongoDB server
gap> d := Directory(PackageInfo("Memoisation")[1].InstallationPath);;
gap> f := Filename(DirectoriesSystemPrograms(), "python");;
gap> SERVER := InputOutputLocalProcess(d, f, ["mongodb_server/run.py"]);
< input/output stream to python >
gap> MicroSleep(500 * 1000);

# Simple test
gap> quint := x -> x * 5;;
gap> mq := MemoisedFunction(quint, rec(cache := "mongodb://localhost:5000/persist"));
<memoised function( x ) ... end>
gap> ClearMemoisedFunction(mq);
true
gap> mq(101);
#I  Memo key: [ 101 ]
#I  Key unknown.  Computing result...
#I  Posting to localhost:5000/persist/quint
505
gap> mq(101);
#I  Memo key: [ 101 ]
#I  Key known!  Loading result from cache...
505

# unhash
gap> exp := MemoisedFunction(x -> 2.71828 ^ x,
>                            rec(funcname := "exp",
>                                cache := "mongodb://localhost:5000/persist",
>                                key := x -> String(Float(x)),
>                                hash := k -> Concatenation("e_to_the_", k),
>                                unhash := s -> s{[10..Length(s)]}));;
gap> ClearMemoisedFunction(exp);
true
gap> exp(2);;
#I  Memo key: 2.
#I  Key unknown.  Computing result...
#I  Posting to localhost:5000/persist/exp
gap> exp(2.0);;  # same key as last
#I  Memo key: 2.
#I  Key known!  Loading result from cache...
gap> exp(-1);;
#I  Memo key: -1.
#I  Key unknown.  Computing result...
#I  Posting to localhost:5000/persist/exp

# unhash collision
gap> square := MemoisedFunction(x -> x * x,
>                               rec(funcname := "square",
>                                   cache := "mongodb://localhost:5000/persist",
>                                   key := x -> x,
>                                   hash := l -> "16",
>                                   unhash := Int));;  # only correct for x=16
gap> ClearMemoisedFunction(square);
true
gap> square(16);
#I  Memo key: 16
#I  Key unknown.  Computing result...
#I  Posting to localhost:5000/persist/square
256
gap> square(16);
#I  Memo key: 16
#I  Key known!  Loading result from cache...
256
gap> square(12);
#I  Memo key: 12
#I  Key known!  Loading result from cache...
Error, Hash collision: <key> does not match <storedkey>

# storekey collision
gap> square := MemoisedFunction(x -> x * x,
>                               rec(funcname := "square",
>                                   cache := "mongodb://localhost:5000/persist",
>                                   key := x -> x,
>                                   hash := l -> "16",
>                                   storekey := true));;  # only correct for x=16
gap> ClearMemoisedFunction(square);
true
gap> square(16);
#I  Memo key: 16
#I  Key unknown.  Computing result...
#I  Posting to localhost:5000/persist/square
256
gap> square(16);
#I  Memo key: 16
#I  Key known!  Loading result from cache...
#I  Key matches that stored on the server
256
gap> square(12);
#I  Memo key: 12
#I  Key known!  Loading result from cache...
Error, Hash collision: <key> does not match <storedkey>

# Metadata
gap> time_string := {} -> Concatenation("Result cached at ",
>                                       String(IO_gettimeofday().tv_sec));;
gap> deg_to_rad := MemoisedFunction(deg -> deg * 3.14 / 180,
>                                   rec(funcname := "deg_to_rad",
>                                       cache := "mongodb://localhost:5000/persist",
>                                       storekey := true,
>                                       hash := L -> String(L[1]),
>                                       metadata := time_string));;
gap> ClearMemoisedFunction(deg_to_rad);
true
gap> right_angle := deg_to_rad(90);;
#I  Memo key: [ 90 ]
#I  Key unknown.  Computing result...
#I  Posting to localhost:5000/persist/deg_to_rad
gap> right_angle := deg_to_rad(90);;
#I  Memo key: [ 90 ]
#I  Key known!  Loading result from cache...
#I  Key matches that stored on the server
gap> AbsoluteValue(right_angle - 3.14159 / 2) < 0.001;
true
gap> meta := MEMO_MongoDBQuery(deg_to_rad!.cache, [90]).metadata;;
gap> StartsWith(meta, "Result cached at 1");  # fails in 2033
true
gap> Length(meta) = Length("Result cached at 1565877929");  # fails in 2286
true
gap> ClearMemoisedFunction(deg_to_rad);
true
gap> ClearMemoisedFunction(deg_to_rad);
true
gap> LookupDictionary(deg_to_rad!.cache, [180]);
#I  No entry found in database
fail

# Kill MongoDB server
gap> CloseStream(SERVER);

# Errors when MongoDB server is not running
gap> quint := x -> x * 5;;
gap> mq := MemoisedFunction(quint, rec(cache := "mongodb://localhost:5000/persist"));
<memoised function( x ) ... end>
gap> AddDictionary(mq!.cache, 3, 15);
#I  Posting to localhost:5000/persist/quint
Error, AddDictionary (MongoDB cache): Failed to connect to localhost port 5000: Connection refused
gap> ClearMemoisedFunction(mq);
Error, MongoDB cache: failed to clear
gap> mq(10);
#I  Memo key: [ 10 ]
Error, MongoDB cache: Failed to connect to localhost port 5000: Connection refused
