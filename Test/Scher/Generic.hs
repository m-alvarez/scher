module Test.Scher.Generic
  ( M
  , int
  , range
  , run
  , assert
  , assume
  )
  where

import Test.Scher.Klee.Common

#ifdef KLEE_IMPURE
import qualified Test.Scher.Klee.Impure as K
#endif

#ifdef KLEE_PURE
import qualified Test.Scher.Klee.Pure as K
#endif

#ifndef KLEE_PURE
#ifndef KLEE_IMPURE
import qualified Test.Scher.Klee.Void as K
#endif
#endif

type M a = K.M a

run :: M a -> IO a
run = K.run

int :: String -> M Int
int = K.int

range :: Int -> Int -> String -> M Int
range = K.range
