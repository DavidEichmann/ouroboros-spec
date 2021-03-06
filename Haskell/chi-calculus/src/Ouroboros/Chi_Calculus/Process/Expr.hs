module Ouroboros.Chi_Calculus.Process.Expr (

    expr

) where

import Prelude hiding (map, drop, zipWith)

import Control.Monad.Trans.Reader (runReader, ask)

import Data.Functor.Const (Const (Const, getConst))
import Data.List.FixedLength as List (map, zipWith, firstNaturals)
import Data.Text as Text (Text, pack, drop)

import Numeric.Natural (Natural)

import Ouroboros.Chi_Calculus.Process (Process (..), Interpretation)

expr :: Interpretation (Const Natural) (Const Text) Text
expr dataInter prc = worker prc `runReader` VarIndexes 0 0 0

    where

    worker Stop = do
        return "Stop"
    worker (Send chan val) = do
        return $ channelVar chan <> " ◁ " <> getConst (dataInter val)
    worker (Receive chan cont) = do
        varIndexes <- ask
        let valIx = valueIndex varIndexes
        let valVar = "x_" <> pack (show valIx)
        let varIndexes' = varIndexes { valueIndex = succ valIx }
        let prcMeaning = worker (cont (Const valVar)) `runReader` varIndexes'
        return $ channelVar chan <> " ▷ " <> valVar <> ". " <> prcMeaning
    worker (Parallel prc1 prc2) = do
        prcMeaning1 <- worker prc1
        prcMeaning2 <- worker prc2
        return $ "(" <> prcMeaning1 <> " ‖ " <> prcMeaning2 <> ")"
    worker (NewChannel cont) = do
        varIndexes <- ask
        let chanIx = channelIndex varIndexes
        let chan = Const chanIx
        let varIndexes' = varIndexes { channelIndex = succ chanIx }
        let prcMeaning = worker (cont chan) `runReader` varIndexes'
        return $ "ν" <> channelVar chan <> ". " <> prcMeaning
    worker (Var meaning) = do
        return meaning
    worker (Letrec defs res) = do
        varIndexes <- ask
        let prcIx = processIndex varIndexes
        let prcVarPrefix = "p_" <> pack (show prcIx) <> "_"
        let prcVars = map ((prcVarPrefix  <>) . pack . show)
                          (firstNaturals @_ @Natural)
        let defPrcs = defs prcVars
        let varIndexes' = varIndexes { processIndex = succ prcIx }
        let defPrcMeanings = mapM worker defPrcs `runReader` varIndexes'
        let defTexts = zipWith (\ prcVar defPrcMeaning -> prcVar        <> 
                                                          " = "         <>
                                                          defPrcMeaning)
                               prcVars
                               defPrcMeanings
        let defsText = "{" <> drop 1 (foldMap ("; " <>) defTexts) <> " }"
        resMeaning <- worker (res prcVars)
        return $ "let " <> defsText <> " in " <> resMeaning

data VarIndexes = VarIndexes {
    channelIndex, valueIndex, processIndex :: Natural
}

channelVar :: Const Natural a -> Text
channelVar chan = "c_" <> pack (show (getConst chan))
