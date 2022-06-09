# The Zarith+web library

The library is a merge of the C-based `zarith` and
its Javascript stubs `zarith_stubs_js`.

Original READMEs are below:

# The Zarith library

## OVERVIEW

This library implements arithmetic and logical operations over
arbitrary-precision integers.

The module is simply named `Z`.  Its interface is similar to that of
the `Int32`, `Int64` and `Nativeint` modules from the OCaml standard
library, with some additional functions.  See the file `z.mlip` for
documentation.

The implementation uses GMP (the GNU Multiple Precision arithmetic
library) to compute over big integers.
However, small integers are represented as unboxed Caml integers, to save
space and improve performance. Big integers are allocated in the Caml heap,
bypassing GMP's memory management and achieving better GC behavior than e.g.
the MLGMP library.
Computations on small integers use a special, faster path (in C or OCaml)
eschewing calls to GMP, while computations on large intergers use the
low-level MPN functions from GMP.

Arbitrary-precision integers can be compared correctly using OCaml's
polymorphic comparison operators (`=`, `<`, `>`, etc.).

Additional features include:
* a module `Q` for rationals, built on top of `Z` (see `q.mli`)
* a compatibility layer `Big_int_Z` that implements the same API as Big_int from the legacy `Num` library, but uses `Z` internally

## REQUIREMENTS

* OCaml, version 4.04.0 or later.
* Either the GMP library or the MPIR library, including development files.
* GCC or Clang or a gcc-compatible C compiler and assembler (other compilers may work).
* The Findlib package manager (optional, recommended).


## INSTALLATION

1) First, run the "configure" script by typing:
```
   ./configure
```
The `configure` script has a few options. Use the `-help` option to get a
list and short description of each option.

2) It creates a Makefile, which can be invoked by:
```
   make
```
This builds native and bytecode versions of the library.

3) The libraries are installed by typing:
```
   make install
```
or, if you install to a system location but are not an administrator
```
   sudo make install
```
If Findlib is detected, it is used to install files.
Otherwise, the files are copied to a `zarith/` subdirectory of the directory
given by `ocamlc -where`.

The libraries are named `zarith.cmxa` and `zarith.cma`, and the Findlib module
is named `zarith`.

Compiling and linking with the library requires passing the `-I +zarith`
option to `ocamlc` / `ocamlopt`, or the `-package zarith` option to `ocamlfind`.

4) (optional, recommended) Test programs are built and run by the additional command
```
  make tests
```
(but these are  not installed).

5) (optional) HTML API documentation is built (using `ocamldoc`) by the additional command
```
  make doc
```

## ONLINE DOCUMENTATION

The documentation for the latest release is hosted on [GitHub Pages](https://antoinemine.github.io/Zarith/doc/latest/index.html).


## LICENSE

This Library is distributed under the terms of the GNU Library General
Public License version 2, with a special exception allowing unconstrained
static linking.
See LICENSE file for details.


## AUTHORS

* Antoine Miné, Sorbonne Université, formerly at ENS Paris.
* Xavier Leroy, Collège de France, formerly at Inria Paris.
* Pascal Cuoq, TrustInSoft.
* Christophe Troestler (toplevel module)


## COPYRIGHT

Copyright (c) 2010-2011 Antoine Miné, Abstraction project.
Abstraction is part of the LIENS (Laboratoire d'Informatique de l'ENS),
a joint laboratory by:
CNRS (Centre national de la recherche scientifique, France),
ENS (École normale supérieure, Paris, France),
INRIA Rocquencourt (Institut national de recherche en informatique, France).


## CONTENTS

Source files        | Description
--------------------|-----------------------------------------
  configure         | configuration script
  z.ml[i]           | Z module and implementation for small integers
  caml_z.c          | C implementation
  big_int_z.ml[i]   | wrapper to provide a Big_int compatible API to Z
  q.ml[i]           | rational library, pure OCaml on top of Z
  zarith_top.ml     | toplevel module to provide pretty-printing
  projet.mak        | builds Z, Q and the tests
  zarith.opam       | package description for opam
  z_mlgmpidl.ml[i]  | conversion between Zarith and MLGMPIDL
  tests/            | simple regression tests and benchmarks
# Zarith Stubs JS

[Zarith](https://github.com/ocaml/Zarith) is an OCaml library that
implements common operations over arbitrary-precision integers and
rationals.  It is implemented via a C api that primarily calls out to
[Gnu Multiple Precision Arithmetic Library](https://gmplib.org).
Because of that C API, Zarith could not be compiled via Js_of_ocaml
until now.

[Zarith Stubs JS](https://github.com/janestreet/zarith_stubs_js) is a
reimplementation of the native C functions in JavaScript.  It makes
extensive use of
[peterolson/BigInteger.js](https://github.com/peterolson/BigInteger.js)
as a shim for browser BigInt functionality and also for the
implementations of many numerical algorithms.


## How to use it ?

In order to use `zarith` with `js_of_ocaml`, just provide the
javascript runtime files to the js_of_ocaml compiler and use `zarith`
as you would normally do.

In practice,
- if you use [dune](https://github.com/ocaml/dune) to build your
  project, just add `zarith_stubs_js` as a library dependency.
- if you don't use dune, you need to find a way to pass both
  [biginteger.js](biginteger.js) and [runtime.js](runtime.js) files to
  the js_of_ocaml compiler command line.
