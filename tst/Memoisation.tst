# Check that the test suite's string replacement is working
gap> MEMO_DefaultCache;
"file://MEMODIR/"

# Simple test
gap> double := x -> x * 2;;
gap> mdoub := MemoisedFunction(double);
<memoised function( x ) ... end>
gap> mdoub(13);
#I  Memo key: [ 13 ]
#I  Using filename MEMODIR/double/7kBFu8v1BAsv2OKlKbOnFXy9uXmNp8dSvgNKPKlAwmn.out
#I  File does not exist - computing result...
#I  Result stored in file
26
gap> mdoub(13);
#I  Memo key: [ 13 ]
#I  Using filename MEMODIR/double/7kBFu8v1BAsv2OKlKbOnFXy9uXmNp8dSvgNKPKlAwmn.out
#I  File exists - reading...
#I  Got cached result from file
26
