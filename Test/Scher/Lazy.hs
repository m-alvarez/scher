{-# LANGUAGE MultiParamTypeClasses #-}
module Test.Scher.Lazy
  (Symbolic (symbolic)
  ,Klee.assert
  ,Klee.assume
  ,Klee.range
  ,Klee.reportError
  ) where

import qualified Test.Scher.Foreign.Klee.Lazy as Klee
import Data.Char

class Symbolic t where
  symbolic :: String -> t

instance Symbolic Int where
  symbolic = Klee.int

instance Symbolic Char where
  symbolic name = chr $ Klee.int name `mod` 256

instance Symbolic Bool where
  symbolic name = Klee.range 0 1 name == 0

-- This syntax dodges a bug in the desugaring
instance (Symbolic t) => Symbolic [t] where
  symbolic name =
    if symbolic (name ++ "%IsCons")
    then symbolic (name ++ "%car") : symbolic (name ++ "%cdr")
    else []

instance (Symbolic t1, Symbolic t2) => Symbolic (t1, t2) where
  symbolic name = (symbolic (name ++ "%Left"), symbolic (name ++ "%Right"))

instance (Symbolic t1, Symbolic t2) => Symbolic (Either t1 t2) where
  symbolic name =
    if symbolic (name ++ "%IsLeft")
      then Left $ symbolic (name ++ "%Value")
      else Right $ symbolic (name ++ "%Value")

instance (Symbolic t) => Symbolic (Maybe t) where
  symbolic name =
    if symbolic (name ++ "%IsJust")
      then Just $ symbolic name
      else Nothing
