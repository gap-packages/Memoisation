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
#I  Got cached result from file
26
gap> Print(mdoub, "\n");
MemoisedFunction(
function ( x )
    return x * 2;
end,
rec(funcname := "double") )

# Test using some custom options
gap> triple := x -> x*3;;
gap> mtriple := MemoisedFunction(triple, rec(storekey := true,
>                                            key := args -> args[1],
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
#I  Got cached result from file
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
gap> G := Group([(1,2,3,4), (1,2)]);;
gap> msize := MemoisedFunction(Size);
<memoised <Attribute "Size">>
gap> HasSize(G);
false
gap> msize(G);
#I  Memo key: [ Group( [ (1,2,3,4), (1,2) ] ) ]
#I  Key unknown.  Computing result...
#I  Using filename MEMODIR/Size/BtzV8KTVnbcszN7V7JQnarJ3VNqDzUYs_oaporNygqs.out
#I  Result stored in file
24
gap> HasSize(G);
true
