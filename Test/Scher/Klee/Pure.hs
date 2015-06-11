{-# INCLUDE "klee/klee.h" #-}
{-# LANGUAGE ForeignFunctionInterface, MagicHash, BangPatterns #-}
module Test.Scher.Klee.Pure
  ( range
  , int
  ) where

import Foreign.C
import Foreign.C.String
import Foreign.C.Types
import System.IO.Unsafe

foreign import capi "klee/klee.h klee_range" c_klee_range :: Int -> Int -> CString -> Int
foreign import capi "klee/klee.h klee_int" c_klee_int :: CString -> Int

{- Old pure code:

range :: Int -> Int -> String -> Int
range !lo !hi name = do
  let c_name = unsafePerformIO $ newCString name in
  c_name `seq` c_klee_range lo hi c_name

int :: String -> Int
int !name = 
  let c_name = unsafePerformIO $ newCString name in
  c_name `seq` c_klee_int c_name

reportError :: String -> Int -> String -> String -> IO ()
reportError file line message suffix = do
  c_file <- newCString file
  c_message <- newCString message
  c_suffix <- newCString suffix
  c_klee_report_error c_file line c_message c_suffix 

assume :: Bool -> IO ()
assume True = c_klee_assume 1
assume False = c_klee_assume 0

assert :: Bool -> IO ()
assert True = c_klee_assert 1
assert False = c_klee_assert 0
-}

range :: Int -> Int -> String -> Int
range !lo !hi name = 
  let c_name = unsafePerformIO $ newCString name
  in c_name `seq` c_klee_range lo hi c_name

int :: String -> Int
int !name =
  let c_name = unsafePerformIO $ newCString name
  in c_name `seq` c_klee_int c_name
