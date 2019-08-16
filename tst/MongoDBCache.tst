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
#I  Querying localhost:5000/persist/quint/94TlBvHCAjh64_t67c127xiBiQLDhfwmbDiJoNq84lR?where={%22namespace%22=%22gapmemo%22}
#I  Key unknown.  Computing result...
#I  Posting to localhost:5000/persist/quint
505
gap> mq(101);
#I  Memo key: [ 101 ]
#I  Querying localhost:5000/persist/quint/94TlBvHCAjh64_t67c127xiBiQLDhfwmbDiJoNq84lR?where={%22namespace%22=%22gapmemo%22}
#I  Key known!  Loading result from cache...
#I  Querying localhost:5000/persist/quint/94TlBvHCAjh64_t67c127xiBiQLDhfwmbDiJoNq84lR?where={%22namespace%22=%22gapmemo%22}
#I  Fetching from localhost:5000/persist/quint
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
#I  Querying localhost:5000/persist/exp/e_to_the_2.?where={%22namespace%22=%22gapmemo%22}
#I  Key unknown.  Computing result...
#I  Posting to localhost:5000/persist/exp
gap> exp(2.0);;  # same key as last
#I  Memo key: 2.
#I  Querying localhost:5000/persist/exp/e_to_the_2.?where={%22namespace%22=%22gapmemo%22}
#I  Key known!  Loading result from cache...
#I  Querying localhost:5000/persist/exp/e_to_the_2.?where={%22namespace%22=%22gapmemo%22}
#I  Fetching from localhost:5000/persist/exp
gap> exp(-1);;
#I  Memo key: -1.
#I  Querying localhost:5000/persist/exp/e_to_the_-1.?where={%22namespace%22=%22gapmemo%22}
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
#I  Querying localhost:5000/persist/square/16?where={%22namespace%22=%22gapmemo%22}
#I  Key unknown.  Computing result...
#I  Posting to localhost:5000/persist/square
256
gap> square(16);
#I  Memo key: 16
#I  Querying localhost:5000/persist/square/16?where={%22namespace%22=%22gapmemo%22}
#I  Key known!  Loading result from cache...
#I  Querying localhost:5000/persist/square/16?where={%22namespace%22=%22gapmemo%22}
#I  Fetching from localhost:5000/persist/square
256
gap> square(12);
#I  Memo key: 12
#I  Querying localhost:5000/persist/square/16?where={%22namespace%22=%22gapmemo%22}
#I  Key known!  Loading result from cache...
#I  Querying localhost:5000/persist/square/16?where={%22namespace%22=%22gapmemo%22}
#I  Fetching from localhost:5000/persist/square
Error, Hash collision: <key> does not match <storedkey>

# Kill MongoDB server
gap> CloseStream(SERVER);
