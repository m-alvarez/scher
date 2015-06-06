module Test.Scher.Klee.Eager where

import qualified Test.Scher.Klee.Foreign.Impure as Klee.Foreign
import qualified Test.Scher.Klee as Klee
import Test.Scher.Symbolic (Symbolic)

instance Symbolic Klee.Lazy Int where
  make = Sym . Klee.int

instance Assert Klee.Lazy where
  assert = Sym . Klee.Foreign.assert

instance Assume Klee.Lazy where
  assume = Sym . Klee.Foreign.assume

instance Fail Klee.Lazy where
  failWith str = Sym $ Klee.Foreign.reportError "" 0 str ""
