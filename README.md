# scher

scher (pronounced 'escher') is an experimental library for doing [concolic](https://en.wikipedia.org/wiki/Concolic_testing), property-based testing of Haskell programs by leveraging
the Klee execution engine. This work is being developed in the context of my Master's Thesis under Matthew Hague, at
the Royal Holloway University of London.
It's under heavy development and should be considered experimental software for all intents and purposes. Any and
all feedback will be greatly appreciated, including bug reports, feature or documentation requests, or simply
comments.

## Getting started

First of all, you will need:

* The [Klee](https://klee.github.io) symbolic execution engine. This, in turn, requires the LLVM. I'm successfully using LLVM 2.9, but if you really want to it should be possible to get it working with 3.4.
* llvm-gcc, which you can get from the [LLVM releases page](http://llvm.org/releases/download.html#2.9).
* The [klee-uclibc](https://github.com/klee/klee-uclibc) standard library.
* My modified [jhc](https://github.com/m-alvarez/jhc) compiler. Unfortunately, scher will not work with GHC.
* The scher library itself (i.e. this library).
* The [scher-run](https://github.com/m-alvarez/scher-run) test runner.

Once you have all the binaries that you need, just ensure they are in your path and put this library somewhere jhc
can find it (a quick and dirty approach to this is to simply copy the Test folder to your application directory) and
write some tests!

A test is an element of a type that satisfies Test.Scher.Property, i.e. either a Bool or a function (a -> b) where a
is an instance of Test.Scher.Symbolic (scher's analogue of QuickCheck's Arbitrary) and b is an instance of
Test.Scher.Property again. The module Test.Scher.Property provides the convenience function `forAll` if you want
to give a name to the symbolic parameters to your test, or you can just use plain old functions and Klee will 
generate variable names for you (just don't expect them to be descriptive!)

When you have written some tests, you just need to run `scher-run verify MyModule.myTestFunction`. This will:

1. Generate a main module for the test executable named `TestModule`.
2. Compile your Haskell code into C code using jhc. The C code will be stored in a folder called `tdir` in the root directory.
3. Compile the C code into a single llvm bytecode file named `bytecode.bc`.
4. Run Klee on the resulting bytecode file, storing klee's raw results into a folder named `klee-output`, and show you a list of all the values tested, and those who resulted in your property being false.

For the moment being, this process is a bit slow since it recompiles all your code from scratch. This is due to how
jhc handles caches (some of the options that you can pass to `scher-run` will change the preprocessor flags that
should be used in the compilation of the Haskell code, but jhc will not recompile the affected code if it's already
in its cache).

It's also worth noting that, while the scher library uses exclusively Klee, there's no reason why it should be
limited to it. If there are any other C verifiers with a similar API (such as, for example, CBMC or Smack), there's 
in  principle no reason why they couldn't be added as additional backends.
