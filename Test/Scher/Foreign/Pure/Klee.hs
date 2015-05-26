{-# INCLUDE "klee/klee.h" #-}
{-# LANGUAGE ForeignFunctionInterface, MagicHash, BangPatterns #-}
module Test.Scher.Foreign.Klee
  (range
  ,int
  ,reportError
  ,assume
  ,assert
  ) where

import Foreign.C
import Foreign.C.String
import Foreign.C.Types
import System.Unsafe

foreign import ccall "klee/klee.h klee_range" c_klee_range :: Int -> Int -> CString -> Int
foreign import ccall "klee/klee.h klee_int" c_klee_int :: CString -> Int
foreign import ccall "klee/klee.h klee_report_error" c_klee_report_error :: CString -> Int -> CString -> CString -> ()
foreign import ccall "klee/klee.h klee_assume" c_klee_assume :: CUInt -> ()
foreign import capi "klee/klee.h klee_assert" c_klee_assert :: CUInt -> ()

range :: Int -> Int -> String -> Int
range !lo !hi name = unsafePerformIO $ do
  c_name <- newCString name
  c_klee_range lo hi c_name

int :: String -> Int
int name = unsafePerformIO $ do
  c_name <- newCString name
  c_klee_int c_name

reportError :: String -> Int -> String -> String -> ()
reportError file line message suffix = unsafePerformIO $ do
  c_file <- newCString file
  c_message <- newCString message
  c_suffix <- newCString suffix
  c_klee_report_error c_file line c_message c_suffix 

assume :: Bool -> ()
assume True = c_klee_assume 1
assume False = c_klee_assume 0

assert :: Bool -> ()
assert True = c_klee_assert 1
assert False = c_klee_assert 0
