module Test.Scher.Symbolic
  ( Symbolic (make)
  )
  where

import qualified Test.Scher.Generic as Generic
import Data.Char
import Data.Functor
import Data.Ratio

class Symbolic a where
  make :: String -> Generic.M a

instance Symbolic Int where
  make name = Generic.int (name ++ "%IntVal")

-- Note that JHC's Integer isn't arbitrary precission
instance Symbolic Integer where
  make name = Generic.integer (name ++ "%IntVal")

instance (Symbolic t, Integral t) => Symbolic (Ratio t) where
  make name = do
    num <- make $ name ++ "%Numerator"
    den <- make $ name ++ "%Denominator"
    Generic.assume (den /= 0)
    return $ num % den

instance Symbolic Bool where
  make name = do
    i <- Generic.int (name ++ "%BoolVal") :: Generic.M Int
    return $ i == 1

instance Symbolic Char where
  make name = do
    i <- Generic.int (name ++ "%CharVal")
    return (chr $ i `rem` 256)

instance (Symbolic t) => Symbolic [t] where
  make name = do
    isNil <- make $ name ++ "%IsNil"
    if isNil
      then return []
      else do
        car <- make $ name ++ "%car"
        cdr <- make $ name ++ "%cdr"
        return $ car : cdr

instance (Symbolic t1, Symbolic t2) => Symbolic (t1, t2) where
  make name = do
    x1 <- make (name ++ "%1")
    x2 <- make (name ++ "%2")
    return (x1, x2)

instance (Symbolic t1, Symbolic t2, Symbolic t3) => Symbolic (t1, t2, t3) where
  make name = do
    x1 <- make (name ++ "%1")
    x2 <- make (name ++ "%2")
    x3 <- make (name ++ "%3")
    return (x1, x2, x3)

instance (Symbolic t1, Symbolic t2, Symbolic t3, Symbolic t4) => Symbolic (t1, t2, t3, t4) where
  make name = do
    x1 <- make (name ++ "%1")
    x2 <- make (name ++ "%2")
    x3 <- make (name ++ "%3")
    x4 <- make (name ++ "%4")
    return (x1, x2, x3, x4)

instance (Symbolic t1, Symbolic t2) => Symbolic (Either t1 t2) where
  make name = do
    isLeft <- make (name ++ "#isLeft") 
    if isLeft
      then Left `fmap` make name
      else Right `fmap` make name

instance (Symbolic t) => Symbolic (Maybe t) where
  make name = do
    isNothing <- make $ name ++ "%IsNothing"
    if isNothing
      then return Nothing
      else Just `fmap` make name
