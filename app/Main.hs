{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE Unsafe            #-}

module Main
  ( main
  ) where

import Control.Monad (when)
import Foreign.C.String (CString, peekCString)
import System.Directory (getCurrentDirectory)

import qualified Data.ByteString.Lazy.Char8 as B (putStrLn)
import Options.Applicative (Parser, execParser, fullDesc, header, help, helper,
  info, long, progDesc, short, switch)
import System.Process.Typed (readProcess_)
import Text.PortableLines.ByteString.Lazy (lines8)

foreign import ccall "zlibVersion"
  zlibVersion :: CString

parseOpts :: Parser Bool
parseOpts = switch
              ( long "quiet"
             <> short 'q'
             <> help "Whether to be quiet" )

main :: IO ()
main = do
  isNotQuiet <- not <$> execParser opts
  when isNotQuiet $ do
    pwd <- getCurrentDirectory
    putStrLn $ "Program running in folder: " <> pwd
  (readOut, _) <- readProcess_ "where.exe zlib1.dll"
  let zlibDirs = lines8 readOut
  case length zlibDirs of
    0 -> when isNotQuiet $ putStrLn "No zlib1.dll located."
    n -> do
      when isNotQuiet $ do
        let files = if n > 1 then "s" else "" :: String
        putStrLn $ "Location of zlib1.dll file" <> files <> ":"
        mapM_ B.putStrLn zlibDirs
        putStr "The first zlib1.dll version is: "
      version <- peekCString zlibVersion
      putStrLn version
 where
  opts = info ( helper <*> parseOpts )
              ( fullDesc
             <> progDesc "Get the version from a zlib1.dll. Run the program\
                         \from the folder in which zlib1.dll file is located."
             <> header "zlibVersion - A zlib1.dll version reporter"
              )
