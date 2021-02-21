#!/bin/sh
# this file is run in the process of startx chewing through various things in
# /etc/X11:
#   startx -> /etc/X11/xinit/xinitrc
#   xinitrc -> ../Xsession
#   Xsession sources /etc/X11/Xsession.d/* and has options in Xsession.options
#   /etc/X11/Xsession.d/50x11-common_determine-startup sets STARTUP as this file
#   /etc/X11/Xsession.d/99x11-common_start runs $STARTUP

# physical device settings
setxkbmap -option caps:super               # make caps lock key a super key
setxkbmap -option terminate:ctrl_alt_bksp  # make <C-A-BSpace> kill X
xset r rate 250 30                         # set keyboard repeat
/usr/local/bin/trackpoint-setup            # set up the mouse
xsetroot -cursor_name left_ptr             # set the root cursor
sxhkd &                                    # set up the X keyboard bindings

# software settings
xrandr --dpi 192                             # the DPI
xsetroot -solid "#1f1f1f"                    # set background dark grey
lxpolkit &                                   # policykit agent
unclutter-xfixes &                           # hide the pointer after a key is pressed
start-pulseaudio-x11                         # audio, backrounding makes it defunct
mpd                                          # music player, backgrounding makes it defunct
xscreensaver -no-splash -no-capture-stderr & # the screensaver daemon
nm-applet &                                  # network manager applet
blueman-applet &                             # bluetooth applet
xmobar -x 1 &                                # the status bar
export _JAVA_AWT_WM_NONREPARENTING=1         # Java programs don't run nicely without this

# run xmonad
exec xmonad
