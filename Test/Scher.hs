{-# LANGUAGE MultiParamTypeClasses #-}
module Test.Scher
  (Symbolic (symbolic)
  ,Klee.assert
  ,Klee.assume
  ,Klee.range
  ,Klee.reportError
  ) where

import qualified Test.Scher.Foreign.Klee as Klee
import Data.Char

class Symbolic t where
  symbolic :: String -> IO t

instance Symbolic Int where
  symbolic = Klee.int

instance Symbolic Char where
  symbolic name = do
    i <- Klee.int name
    return (chr $ i `mod` 255)

instance Symbolic Bool where
  symbolic name = do
    r <- Klee.range 0 2 name
    return $ r == 0

-- This syntax dodges a bug in the desugaring
instance (Symbolic t) => Symbolic [t] where
  symbolic name =
    symbolic (name ++ "#end")
    >>= \end ->
    if not end
    then return []
    else symbolic (name ++ "#hd")
         >>= \hd ->
         symbolic (name ++ "#tl")
         >>= \tl ->
         return $ hd : tl

instance (Symbolic t1, Symbolic t2) => Symbolic (t1, t2) where
  symbolic name = do
    l <- symbolic (name ++ "#left")
    r <- symbolic (name ++ "#right")
    return (l, r)

instance (Symbolic t1, Symbolic t2) => Symbolic (Either t1 t2) where
  symbolic name =
    symbolic (name ++ "#isLeft") 
    >>= \choice ->
    if choice
    then Left `fmap` symbolic name
    else Right `fmap` symbolic name

instance (Symbolic t) => Symbolic (Maybe t) where
  symbolic name =
    symbolic (name ++ "#isNothing")
    >>= \isNothing ->
    if isNothing
    then return Nothing
    else Just `fmap` symbolic name
