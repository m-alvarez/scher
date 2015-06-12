{-# INCLUDE "klee/klee.h" #-}
{-# LANGUAGE ForeignFunctionInterface, MagicHash, BangPatterns #-}
module Test.Scher.Klee.Impure
  ( range
  , int
  , M
  , run
  ) where

import Foreign.C
import Foreign.C.String
import Foreign.C.Types

foreign import capi "klee/klee.h klee_range" c_klee_range :: Int -> Int -> CString -> IO Int
foreign import capi "klee/klee.h klee_int" c_klee_int :: CString -> IO Int

range :: Int -> Int -> String -> IO Int
range !lo !hi name = withCString name $ \name ->
  c_klee_range lo hi name

int :: String -> IO Int
int name = withCString name c_klee_int

type M = IO

run :: M a -> IO a
run = identity
