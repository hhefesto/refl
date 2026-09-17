-- | Layered layout of the world map DAG: longest-path layering (a world sits
-- one layer below its deepest dependency), then barycenter ordering inside a
-- layer to keep edges short. Pure, so the client computes it from the
-- manifest.
module Refl.Protocol.Graph
  ( Layout
  , layout
  , transitiveDeps
  ) where

import           Data.List           (sortOn)
import           Data.Map            (Map)
import qualified Data.Map            as M
import           Data.Maybe          (fromMaybe, mapMaybe)
import qualified Data.Set            as S

-- | Node → (layer, column).
type Layout a = Map a (Int, Int)

-- | @layout deps@ where @deps@ maps every node to its direct dependencies.
layout :: Ord a => Map a [a] -> Layout a
layout deps = M.fromList
  [ (n, (layer, col))
  | (layer, ns) <- zip [0 ..] layers
  , (col, n) <- zip [0 ..] ns
  ]
 where
  layerOf = M.fromList [ (n, depth n) | n <- M.keys deps ]
  depth n = case fromMaybe [] (M.lookup n deps) of
    [] -> 0 :: Int
    ds -> 1 + maximum (map depth ds)
  byLayer = M.fromListWith (flip (++))
    [ (l, [n]) | (n, l) <- M.toList layerOf ]
  maxLayer = if M.null byLayer then (-1) else fst (M.findMax byLayer)
  -- order each layer by the mean column of its dependencies in the layer above
  layers = go 0 M.empty
   where
    go l prev
      | l > maxLayer = []
      | otherwise =
          let ns = fromMaybe [] (M.lookup l byLayer)
              bary n =
                let cols = mapMaybe (`M.lookup` prev) (fromMaybe [] (M.lookup n deps))
                in if null cols then 0 else fromIntegral (sum cols) / fromIntegral (length cols) :: Double
              ordered = sortOn bary ns
              prev' = M.union (M.fromList (zip ordered [0 :: Int ..])) prev
          in ordered : go (l + 1) prev'

-- | All transitive dependencies of a node.
transitiveDeps :: Ord a => Map a [a] -> a -> S.Set a
transitiveDeps deps = go S.empty
 where
  go seen n = foldl step seen (fromMaybe [] (M.lookup n deps))
   where
    step acc d | d `S.member` acc = acc
               | otherwise        = go (S.insert d acc) d
