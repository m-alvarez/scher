{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Test.Scher.Symbolic
  (Symbolic, Sym
  ) where

import Data.Char
import Control.Applicative

newtype Sym s t = Sym { runSym :: IO t }

class Symbolic s t where
  make :: String -> Sym s t

class Assert s where
  assert :: Bool -> Sym s ()

class Fail s where
  failWith :: String -> Sym s ()
  failWith = failWhen True
  failWhen :: Bool -> String -> Sym s ()
  failWhen b message = if b then failWith message else Sym (return ())

class Assume s where
  assume :: Bool -> Sym s ()

instance Functor (Sym s) where
  f `fmap` a = Sym $ f `fmap` runSym a

instance Applicative (Sym s) where
  pure = Sym . pure
  (Sym f) <*> (Sym a) = Sym $ f <*> a

instance (Assert s) => Monad (Sym s) where
  return  = Sym . return
  a >>= f = Sym $ runSym a >>= (runSym . f)

instance (Symbolic m Int) => Symbolic m Char where
  make name = do
    i <- make (name ++ "%CharVal")
    return (chr $ i `mod` 256)

instance (Symbolic m Int) => Symbolic m Bool where
  make name = do
    i <- make (name ++ "%BoolVal") :: Sym m Int
    return $ i `mod` 2 == 0

-- This syntax dodges a bug in the desugaring
instance (Symbolic m Bool, Symbolic m t) => Symbolic m [t] where
  make name =
    make (name ++ "%IsCons")
    >>= \end ->
    if end
    then return []
    else make (name ++ "%car")
         >>= \hd ->
         make (name ++ "%cdr")
         >>= \tl ->
         return $ hd : tl

instance (Symbolic m t1, Symbolic m t2) => Symbolic m (t1, t2) where
  make name = do
    x1 <- make (name ++ "%1")
    x2 <- make (name ++ "%2")
    return (x1, x2)

instance (Symbolic m t1, Symbolic m t2, Symbolic m t3) => Symbolic m (t1, t2, t3) where
  make name = do
    x1 <- make (name ++ "%1")
    x2 <- make (name ++ "%2")
    x3 <- make (name ++ "%3")
    return (x1, x2, x3)

instance (Symbolic m t1, Symbolic m t2, Symbolic m t3, Symbolic m t4) => Symbolic m (t1, t2, t3, t4) where
  make name = do
    x1 <- make (name ++ "%1")
    x2 <- make (name ++ "%2")
    x3 <- make (name ++ "%3")
    x4 <- make (name ++ "%4")
    return (x1, x2, x3, x4)

instance (Symbolic m Bool, Symbolic m t1, Symbolic m t2) => Symbolic m (Either t1 t2) where
  make name =
    make (name ++ "#isLeft") 
    >>= \choice ->
    if choice
    then Left `fmap` make name
    else Right `fmap` make name

instance (Symbolic m Bool, Symbolic m t) => Symbolic m (Maybe t) where
  make name =
    make (name ++ "%IsJust")
    >>= \isJust ->
    if isJust
    then Just `fmap` make name
    else return Nothing
