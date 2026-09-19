-- | Cancellation is never converted into a prover diagnostic. Closing a
-- process reaps its whole process group, including descendants of wrappers.
module Refl.Process (trySync, stopProcess) where
import Control.Exception
import Control.Monad (void)
import System.Process
import System.Posix.Signals (signalProcessGroup, sigKILL)

trySync :: IO a -> IO (Either SomeException a)
trySync = tryJust $ \e -> case fromException e :: Maybe SomeAsyncException of
  Just _ -> Nothing
  Nothing -> Just e

stopProcess :: ProcessHandle -> IO ()
stopProcess ph = do
  pid <- getPid ph
  mapM_ (\p -> void (trySync (signalProcessGroup sigKILL p))) pid
  void (waitForProcess ph)
