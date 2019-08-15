# Specify cache
gap> special_dir := Filename(DirectoryTemporary(), "my_favourite_directory");;
gap> f := MemoisedFunction(x -> x[1],
>                          rec(funcname := "first", cache := special_dir));;
gap> MEMO_IsDiskCache(f!.cache);
true
gap> f!.cache!.dir = Filename(Directory(special_dir), "first");
true

# Failure to write
gap> f := MemoisedFunction(x -> x[1],
>                          rec(funcname := "first", cache := "/dir_in_root/"));;
gap> f([1,2,3]);
#I  Memo key: [ [ 1, 2, 3 ] ]
#I  Key unknown.  Computing result...
#I  Using filename /dir_in_root/first/27MTx-8xjHtIH0z5DFqsOMj3JkoMRA1r20Aug8QoC_e.out
Error, Memoisation: could not write result to /dir_in_root/first/27MTx-8xjHtIH0z5DFqsOMj3JkoMRA1r20Aug8QoC_e.out

# (Mis)using dictionary directly
gap> mdoub := MemoisedFunction(x -> x*2, rec(funcname := "hackeddouble"));;
gap> KnowsDictionary(mdoub!.cache, [1234]);
false
gap> LookupDictionary(mdoub!.cache, [1234]);
#I  Using filename MEMODIR/hackeddouble/9FiO4cBS1C61Ws0uL51sWpAstnrPLz4gz1A8D5ce3Ii.out
#I  File MEMODIR/hackeddouble/9FiO4cBS1C61Ws0uL51sWpAstnrPLz4gz1A8D5ce3Ii.out not readable
fail

# Metadata
gap> time_string := {} -> Concatenation("Result cached at ",
>                                       String(IO_gettimeofday().tv_sec));;
gap> deg_to_rad := MemoisedFunction(deg -> deg * 3.14 / 180,
>                                   rec(funcname := "deg_to_rad",
>                                       hash := L -> String(L[1]),
>                                       metadata := time_string));;
gap> right_angle := deg_to_rad(90);;
#I  Memo key: [ 90 ]
#I  Key unknown.  Computing result...
#I  Using filename MEMODIR/deg_to_rad/90.out
#I  Result stored in file
#I  Metadata stored at MEMODIR/deg_to_rad/90.meta
gap> AbsoluteValue(right_angle - 3.14159 / 2) < 0.001;
true
gap> fname := Filename(Directory(deg_to_rad!.cache!.dir), "90.meta");
"MEMODIR/deg_to_rad/90.meta"
gap> IsReadableFile(fname);
true
gap> meta := StringFile(fname);;
gap> StartsWith(meta, "Result cached at 1");  # fails in 2033
true
gap> Length(meta) = Length("Result cached at 1565877929");  # fails in 2286
true
gap> fname := Concatenation(fname, ".donotdelete");
"MEMODIR/deg_to_rad/90.meta.donotdelete"
gap> FileString(fname, "hello world");
11
gap> ClearMemoisedFunction(deg_to_rad);
false
gap> RemoveFile(fname);
true
gap> ClearMemoisedFunction(deg_to_rad);
true
gap> ClearMemoisedFunction(deg_to_rad);
true
gap> IsReadableFile(fname);
false

# unhash
gap> exp := MemoisedFunction(x -> 2.71828 ^ x,
>                            rec(funcname := "exp",
>                                key := x -> String(Float(x)),
>                                hash := k -> Concatenation("e_to_the_", k),
>                                unhash := s -> s{[10..Length(s)]}));;
gap> ClearMemoisedFunction(exp);
true
gap> exp(2);;
#I  Memo key: 2.
#I  Key unknown.  Computing result...
#I  Using filename MEMODIR/exp/e_to_the_2..out
#I  Result stored in file
gap> exp(2.0);;  # same key as last
#I  Memo key: 2.
#I  Key known!  Loading result from cache...
#I  Using filename MEMODIR/exp/e_to_the_2..out
#I  Got cached result from file
gap> exp(-1);;
#I  Memo key: -1.
#I  Key unknown.  Computing result...
#I  Using filename MEMODIR/exp/e_to_the_-1..out
#I  Result stored in file

# unhash collision
gap> square := MemoisedFunction(x -> x * x,
>                               rec(funcname := "square",
>                                   key := x -> x,
>                                   hash := l -> "16",
>                                   unhash := Int));;  # only correct for x=16
gap> square(16);
#I  Memo key: 16
#I  Key unknown.  Computing result...
#I  Using filename MEMODIR/square/16.out
#I  Result stored in file
256
gap> square(16);
#I  Memo key: 16
#I  Key known!  Loading result from cache...
#I  Using filename MEMODIR/square/16.out
#I  Got cached result from file
256
gap> square(12);
#I  Memo key: 12
#I  Key known!  Loading result from cache...
#I  Using filename MEMODIR/square/16.out
Error, Hash collision: <key> does not match <storedkey>
