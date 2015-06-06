module Test.Scher.Klee
  (module Test.Scher.Klee.Lazy, module Test.Scher.Klee.Eager, Klee(..))
  where

import Test.Scher.Klee.Lazy
import Test.Scher.Klee.Eager

data Klee = Lazy | Eager
--import Test.Scher.Klee.Impure
