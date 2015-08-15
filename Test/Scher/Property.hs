module Test.Scher.Property
  ( forAll
  , Property (verify)
  )
  where

import Test.Scher.Generic
import Test.Scher.Symbolic
import System.IO.Unsafe
import System.Random
import Data.IORef

class Property b where
  verify :: b -> IO ()

instance Property Bool where
  verify b = assert b

forAll :: (Symbolic a, Property b) => String -> (a -> b) -> All a b
forAll = All

instance (Symbolic a, Property b) => Property (All a b) where
  verify (All name f) = do
    arg <- run $ make name
    verify $ f arg

instance (Symbolic a, Property b) => Property (a -> b) where
  verify f = do
    name <- genSym
    arg <- run $ make name
    verify $ f arg

data All a b = All String (a -> b)

counter :: IORef Int
counter = unsafePerformIO $ newIORef 0

genSym :: IO String
genSym = do
  num <- getStdRandom (random) :: IO Int
  return $ "#AUTO-" ++ show (abs num)
