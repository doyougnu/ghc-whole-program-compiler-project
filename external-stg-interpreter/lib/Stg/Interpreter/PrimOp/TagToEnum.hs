{-# LANGUAGE RecordWildCards, LambdaCase, OverloadedStrings, PatternSynonyms #-}
module Stg.Interpreter.PrimOp.TagToEnum where

import Data.List (findIndex)
import Stg.Syntax
import Stg.Interpreter.Base

pattern IntV i    = IntAtom i -- Literal (LitNumber LitNumInt i)
pattern WordV i   = WordAtom i -- Literal (LitNumber LitNumWord i)
pattern Word32V i = WordAtom i -- Literal (LitNumber LitNumWord i)

dataToTagOp :: [Atom] -> M [Atom]
dataToTagOp [whnf@HeapPtr{}] = do
  -- NOTE: the GHC dataToTag# primop works for any Data Con regardless its arity
  (Con _ dataCon _) <- readHeapCon whnf

  case findIndex (\d -> dcId d == dcId dataCon) (tcDataCons (uncutTyCon $ dcTyCon dataCon)) of
    Nothing -> stgErrorM $ "Data constructor tag is not found for " ++ show (dcUniqueName dataCon)
    Just i  -> pure [IntV i]
dataToTagOp result = stgErrorM $ "dataToTagOp expected [HeapPtr], got: " ++ show result

primOps :: [(Name, PrimOpFunDef)]
primOps = getPrimOpList $ do

      -- dataToTag# :: a -> Int#  -- Zero-indexed; the first constructor has tag zero
  defOp "dataToTag#" $ \[ho@HeapPtr{}] -> do
    {-
      Q: how should it behave when the heap object is not a constructor?
      A: is should evaluate it to WHNF

      Q: should it raise exception when the heap object is an exception value?
      A: it should raise exception usin the normal eval sematics.

      PROBLEM:
        When an exception is raise during the eval, but the interpreted and native stack must be unwinded somehow
        Q: how to implement this?
        A: implement dataToTag# returning part as a stack continuation, this seems to be the simplest solution to this problem.
    -}

    -- HINT: do the work after getting the WHNF result back
    stackPush DataToTagOp

     -- HINT: force thunks
    stackPush $ Apply []
    pure [ho]

      -- tagToEnum# :: Int# -> a
  defSpecOp "tagToEnum#" $ \[IntV i] _t tc -> do
    Just tyc <- pure tc
    let dc = tcDataCons tyc !! i
    loc <- allocAndStore (Con False dc [])
    pure [HeapPtr loc]
