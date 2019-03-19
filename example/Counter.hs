{-# language FlexibleContexts, TypeFamilies #-}
module Main where

import Reflex
import Reflex.Host.Basic

import Control.Concurrent (threadDelay)
import Control.Monad.Fix (MonadFix)
import Control.Monad.IO.Class (liftIO)

myNetwork :: (Reflex t, MonadHold t m, MonadFix m) => Event t () -> m (Dynamic t Int)
myNetwork eTick = count eTick

myGuest :: BasicGuestConstraints t m => BasicGuest t m ((), Event t ())
myGuest = do
  (eTick, sendTick) <- newTriggerEvent
  dCount <- myNetwork eTick
  let
    eCountUpdated = updated dCount
    eQuit = () <$ ffilter (==5) eCountUpdated
  repeatUntilQuit (threadDelay 1000000 *> sendTick ()) eQuit
  performEvent_ $ liftIO . print <$> eCountUpdated
  pure ((), eQuit)

main :: IO ()
main = basicHostWithQuit myGuest