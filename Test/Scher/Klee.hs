module Test.Scher.Klee
  where

import qualified Test.Scher.Klee.Pure as Lazy
import qualified Test.Scher.Klee.Impure as Strict
import Test.Scher.Symbolic

instance Symbolic Int where
  make name = Sym $ \strat ->
    case strat of
      Eager -> Strict.int name
      Lazy -> Lazy.int name
