{-# INCLUDE "klee/klee.h" #-}
{-# LANGUAGE ForeignFunctionInterface, MagicHash, BangPatterns #-}
module Test.Scher.Klee.Pure
  ( range
  , int
  , integer
  , M
  , run
  ) where

import Foreign.C
import Foreign.C.String
import Foreign.C.Types
import System.IO.Unsafe

foreign import capi "klee/klee.h klee_range" c_klee_range   :: Int -> Int -> CString -> Int
foreign import capi "klee/klee.h klee_int"   c_klee_int     :: CString -> Int
foreign import capi "extras.h klee_integer"  c_klee_integer :: CString -> Integer

range :: Int -> Int -> String -> M Int
range !lo !hi name = 
  M $ let c_name = unsafePerformIO $ newCString name in c_name `seq` c_klee_range lo hi c_name

int :: String -> M Int
int !name =
  M $ let c_name = unsafePerformIO $ newCString name in c_name `seq` c_klee_int c_name

newtype M a = M { runIdentity :: a }

instance Functor M where
  f `fmap` a = M $ f $ runIdentity a

instance Monad M where
  return  = M
  a >>= f = f $ runIdentity a

run :: M a -> IO a
run = return . runIdentity
