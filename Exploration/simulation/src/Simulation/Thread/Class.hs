module Simulation.Thread.Class
    ( LogEntry(..)
    , MonadThread(..)
    ) where

import qualified Control.Concurrent           as C
import qualified Control.Concurrent.STM       as STM
import           Control.Monad.Trans.Identity
import           Data.Time.Clock.POSIX        (getPOSIXTime)
import           Data.Typeable                (Typeable)
import           Simulation.Time
import           System.Random
import           Text.Printf                  (printf)

data LogEntry threadId where
    LogMessage  :: !Seconds -> !threadId -> !String -> LogEntry threadId
    Observation :: Typeable a => !Seconds -> !threadId -> a -> LogEntry threadId

instance Show threadId => Show (LogEntry threadId) where
    show (LogMessage s tid msg) = printf "%12.6fs: %4s: %s" (toDouble s) (show tid) msg
    show (Observation s tid _)  = printf "%12.6fs: %4s: <Observation>" (toDouble s) (show tid)

toDouble :: Seconds -> Double
toDouble = fromRational . toRational

class Monad m => MonadThread m where

    type ThreadIdT m :: *
    type ChannelT m :: * -> *

    getThreadId :: m (ThreadIdT m)
    fork        :: m () -> m (ThreadIdT m)
    kill        :: ThreadIdT m -> m ()
    newChannel  :: Typeable a => m (ChannelT m a)
    send        :: Typeable a => a -> ChannelT m a -> m ()
    expect      :: Typeable a => ChannelT m a -> m a
    getTime     :: m Seconds
    delay       :: Seconds -> m ()
    logEntryT   :: LogEntry (ThreadIdT m) -> m ()
    withStdGen  :: (StdGen -> (a, StdGen)) -> m a

instance MonadThread IO where

    type ThreadIdT IO = C.ThreadId
    type ChannelT IO = STM.TChan

    getThreadId = C.myThreadId
    fork        = C.forkIO
    kill        = C.killThread
    newChannel  = STM.newTChanIO
    send a c    = STM.atomically $ STM.writeTChan c a
    expect      = STM.atomically . STM.readTChan
    getTime     = fromRational . toRational <$> getPOSIXTime
    delay       = C.threadDelay . fromIntegral . toMicroseconds
    logEntryT   = print
    withStdGen  = getStdRandom

instance MonadThread m => MonadThread (IdentityT m) where

    type ThreadIdT (IdentityT m) = ThreadIdT m
    type ChannelT (IdentityT m) = ChannelT m

    getThreadId = IdentityT getThreadId
    fork        = IdentityT . fork . runIdentityT
    kill        = IdentityT . kill
    newChannel  = IdentityT newChannel
    send a c    = IdentityT $ send a c
    expect      = IdentityT . expect
    getTime     = IdentityT getTime
    delay       = IdentityT . delay
    logEntryT   = IdentityT . logEntryT
    withStdGen  = IdentityT . withStdGen
