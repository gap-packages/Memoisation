The GAP 4 package `Memoisation'
===============================

[![Build Status](https://travis-ci.org/gap-packages/Memoisation.svg?branch=master)](https://travis-ci.org/gap-packages/Memoisation)
[![Code Coverage](https://codecov.io/github/gap-packages/Memoisation/coverage.svg?branch=master&token=)](https://codecov.io/gh/gap-packages/Memoisation)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/gap-packages/Memoisation/master?filepath=demo.ipynb)

A persistent memoisation framework for the GAP computational algebra system.
Persistent memoisation is the practice of storing the output of a function
permanently to a disk or a server so that the result can be looked up
automatically in the future, avoiding any known results being recomputed
unnecessarily.

Installation
------------
GAP now has a package manager, which can be used to install any GAP package.  To
get the latest development version of the Memoisation package, run:

    gap> LoadPackage("PackageManager");
    gap> InstallPackage("https://github.com/gap-packages/Memoisation.git");

Examples
--------
Use `MemoisedFunction` to wrap a function and start saving its outputs to disk:

```gap
gap> double := x -> x * 2;;
gap> memo_double := MemoisedFunction(double);
<memoised function( x ) ... end>
gap> memo_double(3);
6
gap> memo_double(6.4);
12.8
```

This will store the outputs of the `double` function in a directory called
`memo/double/`, in a machine-readable format.  Subsequent calls of
`memo_double(3)` will be looked up on disk instead of being recomputed.

One can specify various arguments to `MemoisedFunction`.  For example:

```gap
gap> power := MemoisedFunction({x, y} -> x ^ y,
>                rec(funcname := "power_number",
>                    cache := "file://arithmetic_results",
>                    hash := k -> StringFormatted("{}_to_the_{}", k[1], k[2]),
>                    pickle := String,
>                    unpickle := Int));;
gap> power(2, 4);
16
gap> power(10, 5);
10000
```

will store the outputs of `power` in human-readable files with descriptive
filenames.

Many more options are available.  See the package documentation for a full
description.

License
-------

Memoisation is free software; you can redistribute it and/or modify it under
the terms of the BSD 3-clause license.

For details see the files COPYRIGHT.md and LICENSE.

Citing
------
Please cite this package as:

[TP19]
M. Torpey & M. Pfeiffer,
Memoisation (GAP package),
Persistent memoisation in GAP,
Version X.Y (20XX),
https://github.com/gap-packages/Memoisation.

Acknowledgement
---------------

<table class="none">
<tr>
<td>
  <img src="http://opendreamkit.org/public/logos/Flag_of_Europe.svg" width="128">
</td>
<td>
  This infrastructure is part of a project that has received funding from the
  European Union's Horizon 2020 research and innovation programme under grant
  agreement No 676541.
</td>
</tr>
