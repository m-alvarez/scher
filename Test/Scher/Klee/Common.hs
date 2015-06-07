{-# INCLUDE "klee/klee.h" #-}
{-# LANGUAGE ForeignFunctionInterface, MagicHash, BangPatterns #-}

module Test.Scher.Klee.Common
  ( reportError
  , assume
  , assert
  ) where

import Foreign.C
import Foreign.C.String
import Foreign.C.Types

foreign import capi "klee/klee.h klee_report_error" c_klee_report_error :: CString -> Int -> CString -> CString -> IO ()
foreign import capi "klee/klee.h klee_assume" c_klee_assume :: CUInt -> IO ()
foreign import capi "klee/klee.h klee_assert" c_klee_assert :: CUInt -> IO ()

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
