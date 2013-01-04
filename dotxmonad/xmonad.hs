import XMonad
import Data.List
import IO (hPutStrLn)
import XMonad.Util.Run (spawnPipe)
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Layout.Named
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
import qualified Data.Map as M
import XMonad.Actions.WindowNavigation
import XMonad.Actions.SpawnOn
import XMonad.Hooks.FadeInactive

focusTextColor = "#ffffff"
normalTextColor = "#000000"
mainColor = "#2d2d2d"
font = "-*-liberation mono-medium-r-*-*-11-*-*-*-*-*-*-*"

main = do
    workspacebar <- spawnPipe $ "dzen2 -bg '" ++ mainColor ++ "' -ta l -p -y -1 -fn '" ++ font ++ "' -w 886 -title-name 'dzen left'"
    -- spawn right dzen side
    spawn "~/.xmonad/dzen.sh"
    -- set wallpaper
    spawn "eval `cat $HOME/.fehbg`"
    sp <- mkSpawner
    config <- withWindowNavigation (xK_w, xK_a, xK_s, xK_d) $ defaultConfig
        { terminal = "urxvtc"
        , modMask = mod4Mask
        , borderWidth = 0
        , startupHook = myStartupHook sp
        , manageHook = manageSpawn sp <+> myManageHook <+> manageHook defaultConfig
        , layoutHook = myLayoutHook
        , logHook = dynamicLogWithPP $ myDzenPP workspacebar
        , keys = newKeys
        }
    xmonad config

defKeys = keys defaultConfig
delKeys x = foldr M.delete (defKeys x) (toRemove x)
newKeys x = foldr (uncurry M.insert) (delKeys x) (toAdd x)
toRemove XConfig{modMask = modm} =
    [ (modm .|. shiftMask, xK_q)
    , (modm, xK_q)
    , (modm, xK_p)
    ]
toAdd XConfig{modMask = modm} =
    [ ((modm, xK_Return), spawn "urxvtc")
    , ((modm, xK_c), spawn "anamnesis -b")
    , ((modm, xK_k), sendMessage MirrorShrink)
    , ((modm, xK_j), sendMessage MirrorExpand)
    , ((modm, xK_p), spawn $ "dmenu_run -b -i -fn '" ++ font ++ "' -nb '" ++ mainColor ++ "' -sb '" ++ mainColor ++ "'")
    ]

myStartupHook sp = do
    spawnOn sp "2" "firefox"
    -- spawnOn sp "2" "opera"
    spawnOn sp "8" "ossxmix"
    spawnOn sp "8" "pidgin"
    spawnOn sp "9" "gayeogi"

myManageHook = composeAll
    [
        fmap ("" `isInfixOf`) className --> (ask >>= \w -> liftX (setOpacity w 0.85) >> idHook),
        fmap ("mplayer" `isSuffixOf`) className --> (ask >>= \w -> liftX (setOpacity w 1) >> idHook),
        fmap ("MPlayer" `isSuffixOf`) className --> (ask >>= \w -> liftX (setOpacity w 1) >> idHook)
    ]

myLayoutHook = avoidStruts (tiled ||| Mirror tiled ||| noBorders Full) ||| noBorders Full
    where
        tiled = named "Normal" $ ResizableTall 1 (3 / 100) (1 / 2) []

myDzenPP handle = defaultPP
    { ppCurrent = wrap ("^fg(" ++ focusTextColor ++ ")") ""
    , ppUrgent = wrap ("^fg(" ++ normalTextColor ++ ")") ""
    --, ppVisible = wrap "" ""
    --, ppHiddenNoWindows = wrap ("^fg(" ++ normalTextColor ++ ")") ""
    , ppHidden = wrap ("^fg(" ++ normalTextColor ++ ")") ""
    , ppSep = ""
    , ppTitle = dzenColor focusTextColor ""
    , ppOutput = hPutStrLn handle
    , ppLayout = wrap ("^fg(" ++ normalTextColor ++ ") | ^fg(" ++ focusTextColor ++ ")") ("^fg(" ++ normalTextColor ++ ") | ")
    }
