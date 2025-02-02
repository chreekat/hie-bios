{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ViewPatterns #-}
module HIE.Bios.Config(
    readConfig,
    Config(..),
    CradleConfig(..)
    ) where

import qualified Data.Text as T
import qualified Data.HashMap.Strict as Map
import Data.Yaml


data CradleConfig = Cabal { component :: Maybe String }
                  | Stack
                  | Bazel
                  | Obelisk
                  | Bios { prog :: FilePath }
                  | Default
                  deriving (Show)

instance FromJSON CradleConfig where
    parseJSON (Object (Map.toList -> [(key, val)]))
        | key == "cabal" = case val of
            Object x | Just (String v) <- Map.lookup "component" x -> return $ Cabal $ Just $ T.unpack v
            _ -> return $ Cabal Nothing
        | key == "stack" = return Stack
        | key == "bazel" = return Bazel
        | key == "obelisk" = return Obelisk
        | key == "bios", Object x <- val, Just (String v) <- Map.lookup "program" x = return $ Bios $ T.unpack v
        | key == "default" = return Default
    parseJSON _ = fail "Not a known configuration"

data Config = Config { cradle :: CradleConfig }
    deriving (Show)

instance FromJSON Config where
    parseJSON x = Config <$> parseJSON x

readConfig :: FilePath -> IO Config
readConfig fp = decodeFileThrow fp
