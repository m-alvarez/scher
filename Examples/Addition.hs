module Examples.Addition where

import Test.Scher

test = forAll "i" \(i :: Int) ->
       forAll "j" \(j :: Int) ->
       i + j == j + i
