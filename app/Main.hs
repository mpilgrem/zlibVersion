module Main (main) where

import Foreign.C.String (CString, peekCString)
import System.Directory (getCurrentDirectory)

foreign import ccall "zlibVersion"
  zlibVersion :: CString

main :: IO ()
main = do
  pwd <- getCurrentDirectory
  version <- peekCString zlibVersion
  putStrLn $ "Running in folder: " <> pwd
  putStrLn $ "The zlib1.dll version is: " <> version
