# Specify cache
gap> special_dir := Filename(DirectoryTemporary(), "my_favourite_directory");;
gap> f := MemoisedFunction(x -> x[1],
>                          rec(funcname := "first", cache := special_dir));;
gap> MEMO_IsDiskCache(f!.cache);
true
gap> f!.cache!.dir = Filename(Directory(special_dir), "first");
true
