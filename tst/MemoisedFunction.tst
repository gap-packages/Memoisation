# Check that the test suite's string replacement is working
gap> MEMO_DefaultCache;
"file://MEMODIR/"

# Simple test
gap> double := x -> x * 2;;
gap> mdoub := MemoisedFunction(double);
<memoised function( x ) ... end>
gap> mdoub(13);
#I  Memo key: [ 13 ]
#I  Key unknown.  Computing result...
#I  Using filename MEMODIR/double/7kBFu8v1BAsv2OKlKbOnFXy9uXmNp8dSvgNKPKlAwmn.out
#I  Result stored in file
26
gap> mdoub(13);
#I  Memo key: [ 13 ]
#I  Key known!  Loading result from cache...
#I  Using filename MEMODIR/double/7kBFu8v1BAsv2OKlKbOnFXy9uXmNp8dSvgNKPKlAwmn.out
26
gap> Print(mdoub, "\n");
MemoisedFunction(
function ( x )
    return x * 2;
end,
rec(funcname := "double") )
gap> ClearMemoisedFunction(mdoub);
true
gap> mdoub(13);
#I  Memo key: [ 13 ]
#I  Key unknown.  Computing result...
#I  Using filename MEMODIR/double/7kBFu8v1BAsv2OKlKbOnFXy9uXmNp8dSvgNKPKlAwmn.out
#I  Result stored in file
26

# Test using some custom options
gap> triple := x -> x*3;;
gap> mtriple := MemoisedFunction(triple, rec(storekey := true,
>                                            key := IdFunc,  # Just use x
>                                            hash := String,
>                                            funcname := "triple_any_number"));;
gap> mtriple(5);
#I  Memo key: 5
#I  Key unknown.  Computing result...
#I  Using filename MEMODIR/triple_any_number/5.out
#I  Result stored in file
#I  Key stored at MEMODIR/triple_any_number/5.key
15
gap> mtriple(5);
#I  Memo key: 5
#I  Key known!  Loading result from cache...
#I  Using filename MEMODIR/triple_any_number/5.out
#I  Key matches MEMODIR/triple_any_number/5.key
15

# MemoisedFunction: bad input
gap> square := MemoisedFunction(x -> x*x);
Error, Memoisation: memoised function <func> has no name,
and no funcname was specified
gap> square := MemoisedFunction(x -> x*x, rec(), true);
Error, Memoisation: MemoisedFunction takes 1 or 2 arguments, not 3
gap> double := x -> x*2;;
gap> mdoub := MemoisedFunction(double, rec(cache := "myprotocol://www.google.com/"));
Error, Memoisation: MemoisedFunction: <cache> cannot start with "myprotocol://"
gap> double := x -> x*2;
function( x ) ... end
gap> mdoub := MemoisedFunction(double, true);
Error, Memoisation: MemoisedFunction: 2nd argument <opts> should be a record

# Specifying a funcname
gap> square := MemoisedFunction(x -> x*x, rec(funcname := "square"));
<memoised function( x ) ... end>
gap> Print(square, "\n");
MemoisedFunction(
function ( x )
    return x * x;
end,
rec(funcname := "square") )

# Attributes
gap> msize := MemoisedFunction(Size, rec(key := GeneratorsOfGroup));
<memoised <Attribute "Size">>
gap> G := Group([(1,2,3,4), (1,2)]);;
gap> HasSize(G);
false
gap> msize(G);
#I  Memo key: [ (1,2,3,4), (1,2) ]
#I  Key unknown.  Computing result...
#I  Using filename MEMODIR/Size/257eVavHQZrY_KWD3b2pNr14QtWH17Gd4wlUYpYUvrV.out
#I  Result stored in file
24
gap> HasSize(G);
true
gap> G := Group([(1,2,3,4), (1,2)]);;
gap> HasSize(G);
false
gap> msize(G);
#I  Memo key: [ (1,2,3,4), (1,2) ]
#I  Key known!  Loading result from cache...
#I  Using filename MEMODIR/Size/257eVavHQZrY_KWD3b2pNr14QtWH17Gd4wlUYpYUvrV.out
24
gap> HasSize(G);
true

# Gabe's bug: IO_Pickle interruption (we clear the IO_Pickle cache manually)
gap> triple := x -> x*3;;
gap> mtriple := MemoisedFunction(triple);;
gap> mtriple(5);;
#I  Memo key: [ 5 ]
#I  Key unknown.  Computing result...
#I  Using filename MEMODIR/triple/ALiKMHk80ySiQOgUZYZrCquI3WcTIC-rCIYshZHEnbH.out
#I  Result stored in file
gap> mtriple(5);;
#I  Memo key: [ 5 ]
#I  Key known!  Loading result from cache...
#I  Using filename MEMODIR/triple/ALiKMHk80ySiQOgUZYZrCquI3WcTIC-rCIYshZHEnbH.out
gap> id := G -> G;;
gap> mid := MemoisedFunction(id);;
gap> mid(FreeGroup(2));
#I  Memo key: [ Group( [ f1, f2 ] ) ]
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `IO_Pickle' on 2 arguments
gap> mtriple(5);
#I  Memo key: [ 5 ]
#I  Key known!  Loading result from cache...
#I  Using filename MEMODIR/triple/ALiKMHk80ySiQOgUZYZrCquI3WcTIC-rCIYshZHEnbH.out
15
gap> mtriple(5);
#I  Memo key: [ 5 ]
#I  Key known!  Loading result from cache...
#I  Using filename MEMODIR/triple/ALiKMHk80ySiQOgUZYZrCquI3WcTIC-rCIYshZHEnbH.out
15
