module Test.Scher.Property
  ( forAll
  , Property (verify)
  )
  where

import Test.Scher.Generic
import Test.Scher.Symbolic
import System.IO.Unsafe
import Data.IORef

class Property b where
  verify :: b -> IO ()

instance Property Bool where
  verify b = assert b

forAll :: (Symbolic a, Property b) => String -> (a -> b) -> App a b
forAll = App

instance (Symbolic a, Property b) => Property (App a b) where
  verify (App name f) = do
    arg <- run $ make name
    verify $ f arg

instance (Symbolic a, Property b) => Property (a -> b) where
  verify f = do
    name <- genSym
    arg <- run $ make name
    verify $ f arg

data App a b = App String (a -> b)

counter :: IORef Int
counter = unsafePerformIO $ newIORef 0

genSym :: IO String
genSym = do
  val <- readIORef counter
  modifyIORef counter (1 +)
  return $ "#AUTO" ++ show val
