import System.Taffybar

import System.Taffybar.Systray
import System.Taffybar.TaffyPager
import System.Taffybar.SimpleClock
import System.Taffybar.FreedesktopNotifications
import System.Taffybar.Battery
import System.Taffybar.MPRIS

import System.Taffybar.Widgets.PollingBar
import System.Taffybar.Widgets.PollingGraph

import System.Information.Memory
import System.Information.CPU

import Data.Monoid ( mconcat )
import qualified Data.Text as T

memCallback = do
  mi <- parseMeminfo
  return [memoryUsedRatio mi]

cpuCallback = do
  (userLoad, systemLoad, totalLoad) <- cpuLoad
  return [totalLoad, systemLoad]

main = do
  let memCfg = defaultGraphConfig { graphDataColors = [(1, 0, 0, 1)]
                                  , graphLabel = Just "mem"
                                  }
      cpuCfg = defaultGraphConfig { graphDataColors = [ (0, 1, 0, 1)
                                                      , (1, 0, 1, 0.5)
                                                      ]
                                  , graphLabel = Just "cpu"
                                  }
{-
      notesCfg = defaultNotificationConfig { notificationFormatter = noteFormatter
                                           , notificationMaxLength = 150
                                           }
-}
      batCfg = defaultBarConfig (\b -> (1-0.4*b, 0.3+0.7*b, 0.1+0.5*b))
  let clock = textClockNew Nothing "<span fgcolor='orange'>%a %b %_d %H:%M</span>" 1
      pager = taffyPagerNew defaultPagerConfig
--      note = notifyAreaNew notesCfg
      mem = pollingGraphNew memCfg 4 memCallback
      cpu = pollingGraphNew cpuCfg 8 cpuCallback
      bat = batteryBarNew batCfg 60
      tray = systrayNew
  defaultTaffybar defaultTaffybarConfig { startWidgets = [ pager ]
                                        , endWidgets = [ tray, clock, bat, mem, cpu ]
                                        }
{-
noteFormatter :: Notification -> String
noteFormatter note = msg
  where
    msg = case T.null (noteBody note) of
      True ->  mconcat [ "<span fgcolor='yellow'>Note:</span>"
                       , "<span bgcolor='#555555' fgcolor='#aaff99'> ", T.unpack $ noteSummary note, " </span> " ]
      False -> mconcat [ "<span fgcolor='yellow'>Note:</span>"
                       , "<span bgcolor='#555555' fgcolor='#aaff99'> ", T.unpack $ noteSummary note, " :</span> ", T.unpack $ noteBody note ]
-}

