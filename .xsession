#!/bin/sh
# this file is run in the process of startx chewing through various things in
# /etc/X11:
#   startx -> /etc/X11/xinit/xinitrc
#   xinitrc -> ../Xsession
#   Xsession sources /etc/X11/Xsession.d/* and has options in Xsession.options
#   /etc/X11/Xsession.d/50x11-common_determine-startup sets STARTUP as this file
#   /etc/X11/Xsession.d/99x11-common_start runs $STARTUP

# physical device settings
setxkbmap -option caps:super                # make caps lock key a super key
setxkbmap -option terminate:ctrl_alt_bksp   # make <C-A-BSpace> kill X
inputplug -0c ~/.bin/_inputplug-dispatcher  # set up XInput devices (and watch for new ones)
sxhkd &                                     # set up the X keyboard bindings

# software settings
xrandr --dpi 192                      # P1, X1C DPI
# xrandr --dpi 144                      # T14 DPI
xsetroot -solid "#1f1f1f"             # set background color (doesn't work with picom)
hsetroot -solid "#1f1f1f"             # set background color (works with picom)
lxpolkit &                            # policykit agent
export XCURSOR_THEME="ComixCursors-Opaque-Black"  # set the mouse cursor theme
export XCURSOR_SIZE=55                # set mouse cursor size (P1, X1C)
# export XCURSOR_SIZE=40                # set mouse cursor size (T14)
xsetroot -cursor_name left_ptr        # set the root window mouse cursor
unclutter-xfixes &                    # hide the pointer after a key is pressed
mpd                                   # music player, backgrounding makes it defunct
nm-applet &                           # network manager applet
blueman-applet &                      # bluetooth applet
picom -b                              # compositor
xmobar -x 1 &                         # the status bar
export _JAVA_AWT_WM_NONREPARENTING=1  # Java programs don't run nicely without this

# run xmonad
exec xmonad
