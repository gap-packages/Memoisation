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

# Kill MongoDB server
gap> CloseStream(SERVER);
