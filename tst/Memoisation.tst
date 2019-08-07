# Check that the test suite's string replacement is working
gap> MEMO_DefaultCache;
"file://MEMODIR/"

# Simple test
gap> double := x -> x * 2;;
gap> mdoub := MemoisedFunction(double);
<memoised function( x ) ... end>
gap> mdoub(13);
Using directory MEMODIR/double
Got key [ 13 ]
Using filename MEMODIR/double/7kBFu8v1BAsv2OKlKbOnFXy9uXmNp8dSvgNKPKlAwmn.out
26
gap> mdoub(13);
Using directory MEMODIR/double
Got key [ 13 ]
Using filename MEMODIR/double/7kBFu8v1BAsv2OKlKbOnFXy9uXmNp8dSvgNKPKlAwmn.out
Getting cached answer from MEMODIR/double/7kBFu8v1BAsv2OKlKbOnFXy9uXmNp8dSvgNKPKl\
Awmn.out...
Got string of length 8 to unpickle
26
