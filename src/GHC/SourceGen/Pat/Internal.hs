{-# LANGUAGE CPP #-}
module GHC.SourceGen.Pat.Internal where

import GHC.Hs.Pat (Pat(..))
#if MIN_VERSION_ghc(9,0,0)
import GHC.Hs.Type (HsConDetails(..))
import GHC.Types.SrcLoc (unLoc)
#else
import GHC.Hs.Type (HsConDetails(..))
import SrcLoc (unLoc)
#endif

import GHC.SourceGen.Lit.Internal (litNeedsParen, overLitNeedsParen)
import GHC.SourceGen.Syntax.Internal

-- Note: GHC>=8.6 inserts parentheses automatically when pretty-printing patterns.
-- When we stop supporting lower versions, we may be able to simplify this.
parenthesize :: Pat' -> Pat'
parenthesize p
    | needsPar p = parPat p
    | otherwise = p


needsPar :: Pat' -> Bool
#if MIN_VERSION_ghc(8,6,0)
needsPar (LitPat _ l) = litNeedsParen l
needsPar (NPat _ l _ _) = overLitNeedsParen $ unLoc l
#else
needsPar (LitPat l) = litNeedsParen l
needsPar (NPat l _ _ _) = overLitNeedsParen $ unLoc l
#endif
#if MIN_VERSION_ghc(9,2,0)
needsPar (ConPat _ _ (PrefixCon _ xs)) = not $ null xs
#elif MIN_VERSION_ghc(9,0,0)
needsPar (ConPat _ _ (PrefixCon xs)) = not $ null xs
#else
needsPar (ConPatIn _ (PrefixCon xs)) = not $ null xs
#endif
#if MIN_VERSION_ghc(9,0,0)
needsPar (ConPat _ _ (InfixCon _ _)) = True
#else
needsPar (ConPatIn _ (InfixCon _ _)) = True
needsPar ConPatOut{} = True
#endif
#if MIN_VERSION_ghc(8,6,0)
needsPar SigPat{} = True
#else
needsPar SigPatIn{} = True
needsPar SigPatOut{} = True
#endif
needsPar _ = False

parPat :: Pat' -> Pat'
#if MIN_VERSION_ghc(9,4,0)
parPat p = (withEpAnnNotUsed ParPat) (noLoc HsTok) (builtPat p) (noLoc HsTok)
#else
parPat = withEpAnnNotUsed ParPat . builtPat
#endif

