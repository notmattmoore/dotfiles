-- Imports {{{
import System.Exit
import Data.Char
import Data.List
import qualified Data.Map as M
import Data.Tuple
import XMonad hiding ( (|||) )
import qualified XMonad.StackSet as W
import XMonad.Actions.CopyWindow
import XMonad.Actions.CycleWS
import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.FloatSnap
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers hiding (CW)
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.BoringWindows hiding (Replace)
import XMonad.Layout.Grid
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.LimitWindows
import XMonad.Layout.Master
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.Tabbed
import XMonad.Layout.TrackFloating
-- import XMonad.Layout.FocusTracking use instead of TrackFloating, but not available in debian stable yet
import XMonad.Prompt
import XMonad.Prompt.ConfirmPrompt
import XMonad.Util.EZConfig
import qualified XMonad.Util.Hacks as Hacks
import XMonad.Util.NamedScratchpad
import XMonad.Util.WorkspaceCompare
-----------------------------------------------------------------------------}}}

main = xmonad $ withUrgencyHook NoUrgencyHook $ withSB mySB $ ewmh $ docks xmonadConfig

-- Keyboard bindings {{{
-- emacs-style key specifications. "M-" = mod, "C-" = control, "S-" = shift, and
-- "M#-" = mod1-mod5. Note that "M1-" = alt.
-- M- is for common actions,
-- M-M1- is for actions on windows
-- M-a activates secondary mappings
-- M-z is for one-handed operations, and should duplicate primary actions
myKeys conf =
  -- scratchpad terminal
  [ ("M-\\",   namedScratchpadAction scratchpads "term")
  , ("M-z \\", namedScratchpadAction scratchpads "term")
  -- scratchpad vim
  , ("M-]",   namedScratchpadAction scratchpads "vim")
  , ("M-z ]", namedScratchpadAction scratchpads "vim")
  -- program launcher
  , ("M-p",   namedScratchpadAction scratchpads "launcher")
  , ("M-z p", namedScratchpadAction scratchpads "launcher")
  -- search
  , ("M-/",   namedScratchpadAction scratchpads "search")
  , ("M-z /", namedScratchpadAction scratchpads "search")
  -- custom scratchpad layer
  , ("M-[",   allNamedScratchpadAction scratchpads "etc")
  , ("M-z [", allNamedScratchpadAction scratchpads "etc")
  -- add/remove focused window from scratchpad layer
  , ("M-M1-[",   withFocused toggleScratchStatus)
  , ("M-z M1-[", withFocused toggleScratchStatus)

  -- toggle last two layouts
  , ("M-y",   swapLastLayouts)
  , ("M-z y", swapLastLayouts)
  -- select tabbed layout
  , ("M-t",   setPrimLayout "Tabbed")
  , ("M-z t", setPrimLayout "Tabbed")
  -- select grid layout
  , ("M-g",   setPrimLayout "Grid")
  , ("M-z g", setPrimLayout "Grid")
  -- add or switch to a workspace (remove the current workspace if empty)
  , ("M-n",   removeEmptyWorkspaceAfter $ addWorkspacePrompt myXPConfigWSNew)
  , ("M-z n", removeEmptyWorkspaceAfter $ addWorkspacePrompt myXPConfigWSNew)
  , ("M-l",   removeEmptyWorkspaceAfter $ namedScratchpadAction scratchpads "desktop-goto")
  , ("M-z l", removeEmptyWorkspaceAfter $ namedScratchpadAction scratchpads "desktop-goto")
  -- send a window to a workspace
  , ("M-M1-l",   withWorkspace myXPConfigWSSelect (windows . W.shift))
  , ("M-z M1-l", withWorkspace myXPConfigWSSelect (windows . W.shift))
  -- rename a workspace
  , ("M-r",   renameWorkspace myXPConfigWSSelect)
  , ("M-z r", renameWorkspace myXPConfigWSSelect)
  -- switch to zz workspace (remove the current workspace if empty)
  , ("M-<Backspace>",   removeEmptyWorkspaceAfter $ addWorkspace "zz")
  , ("M-z <Backspace>", removeEmptyWorkspaceAfter $ addWorkspace "zz")
  -- move to prev and next nonempty WS (remove the current workspace if empty)
  , ("M-i",   removeEmptyWorkspaceAfter $ moveTo Prev notNSPWS)
  , ("M-z i", removeEmptyWorkspaceAfter $ moveTo Prev notNSPWS)
  , ("M-o",   removeEmptyWorkspaceAfter $ moveTo Next notNSPWS)
  , ("M-z o", removeEmptyWorkspaceAfter $ moveTo Next notNSPWS)
  -- toggle between active workspaces (remove the current workspace if empty)
  , ("M-<Space>",   removeEmptyWorkspaceAfter $ toggleWS' ["NSP"])
  , ("M-z <Space>", removeEmptyWorkspaceAfter $ toggleWS' ["NSP"])

  -- shrink and expand the master area
  , ("M-<Left>",    sendMessage Shrink)
  , ("M-z <Left>",  sendMessage Shrink)
  , ("M-<Right>",   sendMessage Expand)
  , ("M-z <Right>", sendMessage Expand)
  -- increase/decrease the number of windows in the master area
  , ("M-M1-<Left>",    sendMessage $ IncMasterN 1)
  , ("M-z M1-<Left>",  sendMessage $ IncMasterN 1)
  , ("M-M1-<Right>",   sendMessage $ IncMasterN (-1))
  , ("M-z M1-<Right>", sendMessage $ IncMasterN (-1))
  -- increase/decrease windows in limited layout
  , ("M-M1-<Down>",   smartDecreaseLimit)
  , ("M-z M1-<Down>", smartDecreaseLimit)
  , ("M-M1-<Up>",     increaseLimit )
  , ("M-z M1-<Up>",   increaseLimit )

  -- move focus to the next/prev *displayed* window
  , ("M-j", focusDown)
  , ("M-k", focusUp)
  -- move focus to the next/prev window
  , ("M-S-j", windows W.focusDown)
  , ("M-S-k", windows W.focusUp)
  -- swap focused window with next/prev window
  , ("M-M1-j", windows W.swapDown)
  , ("M-M1-k", windows W.swapUp)
  -- move focus to the master window
  , ("M-m",   focusMaster)
  , ("M-z m", focusMaster)
  -- swap focused window and master window, or master and the next
  , ("M-<Return>",   windows shiftMaster)
  , ("M-z <Return>", windows shiftMaster)

  -- close focused window
  , ("M-c",   kill)
  , ("M-z c", kill)
  -- float/unfloat a window and put it on all workspaces
  , ("M-f",   withFocused toggleFloatAllWS)
  , ("M-z f", withFocused toggleFloatAllWS)

  -- recompile and restart xmonad (confirm first)
  , ("M-C-M1-r", confirmPrompt myXPConfig{position=CenteredAt (1/2) 0.265} "recompile XMonad?" $ io $ spawn "xmonad --recompile; xmonad --restart")
  -- quit xmonad (confirm first)
  , ("M-C-M1-q", confirmPrompt myXPConfig{position=CenteredAt (1/2) 0.233} "exit XMonad?" $ io $ exitWith ExitSuccess)

  -- SECONDARY MAPPINGS
  -- fullscreen layout
  , ("M-a f", sendMessage $ JumpToLayout "Full")
  -- toggle the statusbar (the upper strut)
  , ("M-a b", sendMessage $ ToggleStrut U)
  -- toggle the system tray
  , ("M-a t", spawn "~/.xmonad/toggle-trayer")
  ]

-- these keys don't play nice with the recursion when using checkKeymap in the
-- startuphook
myBrokenKeys conf =
  -- reset the layout
  [ ("M-C-M1-y", setLayout $ layoutHook conf) ]

-- mouse bindings: snap windows when dragging and resizing
myMouseKeys (XConfig {XMonad.modMask = modm}) = M.fromList $
  -- M-<left drag> to move window
  [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w >> afterDrag (snapMagicMove snapDist snapDist w)))
  -- M-<right drag> to resize window from the right lower corner
  , ((modm, button3), (\w -> focus w >> mouseResizeWindow w >> afterDrag (snapMagicResize [R,D] snapDist snapDist w)))
  ]
  where
    -- snap within 100 pixels of a window border or screen edge
    snapDist = Just 100
-----------------------------------------------------------------------------}}}
-- Custom commands {{{
-- toggle "is a scratchpad"
toggleScratchStatus windowId = do
  hasScratch <- runQuery isScratch windowId
  if hasScratch
  then do
    spawn "~/.xmonad/scratchpad off"
    windows . W.sink $ windowId
  else do
    spawn "~/.xmonad/scratchpad on"
    windows $ W.float windowId (W.RationalRect 0.025 0.025 0.5 0.5)

-- layout machinery
getPrimSecLayout = do
  ld <- gets ( description . W.layout . W.workspace . W.current . windowset )
  let (prim, sec') = break ( == '(' ) ld
  let sec = if null sec' || length sec' < 2
            then ""
            else tail . init $ sec'
  return (prim, sec)
getNextLayout cur layouts = head $ tail $ dropWhile ( /= cur ) $ cycle $ layouts
setPrimSecLayout prim sec = sendMessage $ JumpToLayout $ case (prim, sec) of
  (p, s) | p == "" || s == "" -> "Grid(Tabbed)"
         | otherwise          -> p ++ "(" ++ s ++ ")"
swapLastLayouts = do
  (prim, sec) <- getPrimSecLayout
  setPrimSecLayout sec prim
setPrimLayout s = do
  (prim, sec) <- getPrimSecLayout
  if prim /= s then do
    if not $ null sec then setPrimSecLayout s prim
    else                   setPrimSecLayout s (getNextLayout s ["Grid", "Limit"])
  else return ()
smartDecreaseLimit = do
  (prim, sec) <- getPrimSecLayout
  if prim == "Limit" then decreaseLimit
  else if prim == "Grid" then do
    if sec /= "Limit" then setPrimSecLayout "Limit" sec
    else                   setPrimSecLayout "Limit" "Grid"
    w <- gets windowset
    setLimit $ pred . length . W.index $ w
  else return ()

-- nicer shift master function than default
shiftMaster = W.modify' $ \c -> case c of
  W.Stack _ [] []     -> c
  W.Stack t [] (x:rs) -> W.Stack x [] (t:rs)
  W.Stack t ls rs     -> W.Stack t [] (x:(xs ++ rs)) where (x:xs) = reverse ls

-- this excludes the NSP (scratchpad) workspace
notNSPWS = WSIs (return $ not . (=="NSP") . W.tag)

-- toggle "float and put on all workspaces"
toggleFloatAllWS windowId = do
  floats <- gets (W.floating . windowset)
  if windowId `M.member` floats
  then do
    killAllOtherCopies
    windows . W.sink $ windowId
  else do
    windows $ W.float windowId (W.RationalRect 0.025 0.025 0.75 0.75)
    windows copyToAll

-- do float and put on all workspaces
doCopyToAll = ask >>= doF . \w -> (\ws -> copyToAll ws)
doCenterFloatToAll = doCenterFloat <+> doCopyToAll

-- floating presets ( left, top, wide, tall (all in %) )
centerFloat = (customFloating $ W.RationalRect 0.333 0.333 0.333 0.333)
upperRightFloat = (customFloating $ W.RationalRect 0.475 0.025 0.5 0.5)
botRightFloat = (customFloating $ W.RationalRect 0.475 0.475 0.5 0.5)
-----------------------------------------------------------------------------}}}
-- Layouts {{{
myLayout =     gridTabbed  ||| tabbedGrid
           ||| limitTabbed ||| tabbedLimit
           ||| gridLimit   ||| limitGrid
           ||| myFull

-- avoidStruts: avoid the top bar
-- boringWindows: allow for some windows to be marked as 'boring' and hidden
-- smartBorders: draw borders only if there are multiple windows
-- trackFloating: better focus tracking between floating layer and regular

-- A master pane with slaves that go in the grid layout. Resize master in 2%
-- intervals, and give master pane 1/2 the screen. Grid layout in 3:2 ratio.
myGrid = renamed [Replace "Grid"]
  $ trackFloating
  $ avoidStruts
  $ smartBorders
  $ boringWindows
  $ mastered (2/100) (1/2)
  $ GridRatio (3/2)
-- Mastered grid layout with limited windows
myLimit = renamed [Replace "Limit"]
  $ trackFloating
  $ avoidStruts
  $ smartBorders
  $ boringAuto
  $ limitSelect 1 1
  $ mastered (2/100) (1/2)
  $ GridRatio (3/2)
-- tabbed layout with decorators
myTabbed = renamed [Replace "Tabbed"]
  $ trackFloating
  $ avoidStruts
  $ noBorders
  $ boringWindows
  $ tabbedBottom shrinkText myTabTheme
-- fullscreen layout
myFull = renamed [Replace "Full"]
  $ trackFloating
  $ noBorders
  $ boringWindows
  $ Full
-- primary/secondary layout setup
gridLimit   = renamed [Append "(Limit)"]  $ myGrid
gridTabbed  = renamed [Append "(Tabbed)"] $ myGrid
limitGrid   = renamed [Append "(Grid)"]   $ myLimit
limitTabbed = renamed [Append "(Tabbed)"] $ myLimit
tabbedLimit = renamed [Append "(Limit)"]  $ myTabbed
tabbedGrid  = renamed [Append "(Grid)"]   $ myTabbed
-----------------------------------------------------------------------------}}}
-- Themes {{{
-- colors (from zenburn)
dark      = "#1f1f1f"
darker    = "#0f0f0f"
gray      = "#8f8f8f"
light     = "#dcdccc"
white     = "#ffffff"
yellow    = "#ccdc90"
ltred     = "#cc9393"
red       = "#bc6c4c"
ltblue    = "#8cd0d3"
darkgreen = "#556B2F"

-- status bar pretty printer
myPP = def
  -- invert current workpsace and pad with spaces
  { ppCurrent = xmobarColor darker light . pad
  -- put extra spaces around non-visible workspaces
  , ppHidden = pad
  -- don't use any separation character between workspace tags
  , ppWsSep = ""
  -- wrap visible but not focused workspaces in ()
  , ppVisible = xmobarColor yellow "" . wrap "(" ")"
  -- color urgent workspaces red and wrap in **
  , ppUrgent = xmobarColor red "" . wrap "*" "*"
  -- make the layout dark grey and separate it from everything with " • "
  , ppLayout = xmobarColor white "" . wrap " • " " • " . xmobarColor gray ""
  -- dont separate workspaces from layout from window titles (we do it manually)
  , ppSep = ""
  -- don't show scratchpad workspace, and sort alphabetically
  , ppSort = fmap ( . filterOutWs ["NSP"] ) getSortByTag }

-- a theme for decorations (used in tabbed layout)
myTabTheme = def
  { fontName = "xft:FiraCode:size=8"
  -- active
  , activeColor = light
  , activeTextColor = darker
  , activeBorderColor = darker
  -- inactive
  , inactiveColor = dark
  , inactiveTextColor = light
  , inactiveBorderColor = darker
  -- make the fg color and borders of urgent windows red
  , urgentColor = dark
  , urgentTextColor = red
  , urgentBorderColor = red
  , decoHeight = 35 }

-- prompt configuration
myXPConfig = def
  { font = "xft:FiraCode:size=10"
  , fgColor = light
  , bgColor = dark
  -- highlight by inverting
  , fgHLight = darker
  , bgHLight = light
  , borderColor = light
  , promptBorderWidth = 5
  , height = 100
  , position = CenteredAt (1/2) (1/3) }
myXPConfigWSSelect = myXPConfig  -- prompt for workspace selection
  { autoComplete = Just 0 }
myXPConfigWSNew = myXPConfig     -- prompt for new/rename workspace
  { autoComplete = Nothing }
-----------------------------------------------------------------------------}}}
-- Misc. config {{{
-- xmonad configuration settings, overriding fields in the default config
xmonadConfig = def
  { borderWidth        = 8
  , normalBorderColor  = dark
  , focusedBorderColor = darkgreen
  , modMask            = mod4Mask   -- Meta (Win) key
  , workspaces         = ["zz"]
  , keys               = \c -> mkKeymap c ((myKeys c) ++ (myBrokenKeys c))
  , mouseBindings      = myMouseKeys
  , focusFollowsMouse  = True
  , startupHook        = myStartupHook
  , layoutHook         = myLayout
  , manageHook         = myManageHook
  , handleEventHook    = myEventHook
  -- , logHook            = myLogHook
  }

myStartupHook = do
  return ()  -- prevent infinite recursion in checkKeymap
  checkKeymap xmonadConfig (myKeys xmonadConfig)

myManageHook = myFloats <+> namedScratchpadManageHook scratchpads

myFloats = composeOne [ isDialog -?> doFloat
                      , appName =? "xmessage" -?> centerFloat
                      , appName =? "zenity" -?> centerFloat
                      , appName =? "float-term" -?> doCenterFloat
                      , appName =? "float-term-all" -?> doCenterFloatToAll
                      , appName =? "transient-term" -?> doCenterFloat ]

-- Use a hack to make windowed fullscreen content work right
myEventHook = handleEventHook def <> Hacks.windowedFullscreenFixEventHook

-- set up the statusbar
mySB = statusBarProp "xmobar" (pure myPP)

-- scratchpads (applications that pop-up after a keypress)
isScratch = (stringProperty "SCRATCH" =? "True")
scratchpads =
  [ NS "term" "~/.xmonad/SP-tmux" (appName =? "SP-tmux") upperRightFloat
  , NS "vim" "~/.xmonad/SP-vim" (appName =? "SP-vim") botRightFloat
  , NS "desktop-goto" "transient-term desktop-goto" (title =? "desktop-goto") doCenterFloat
  , NS "launcher" "transient-term fzf-launcher" (title =? "fzf-launcher") doCenterFloat
  , NS "search" "transient-term fzf-command" (title =? "fzf-command") doCenterFloat
  , NS "etc" "" isScratch doCenterFloat ]
-----------------------------------------------------------------------------}}}
