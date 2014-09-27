#!/bin/sh

# invoked in root's crontab, e.g.
# */2 * * * * /home/sarunas/bin/dotfiles/scripts/battery_poller.sh
# the X session should also have this:
# xhost +si:localuser:root

export DISPLAY=":0.0"

STATUS=$(cat /sys/class/power_supply/BAT0/status)
if ! test "$STATUS" = "Discharging" ; then
    exit 0
fi

NOW=$(cat /sys/class/power_supply/BAT0/energy_now)
FULL=$(cat /sys/class/power_supply/BAT0/energy_full)

PERCENT=$(expr $NOW \* 100 / $FULL)

if test "$PERCENT" -lt 5 ; then
    notify-send -t 60000 "JUICE!!!" "Just $PERCENT% of the battery is left. I'm going to sleep." 
    sleep 10
    /usr/sbin/pm-suspend
else
    if test "$PERCENT" -lt 10 ; then
        notify-send "Battery is getting LOW!" "Just $PERCENT% of the battery is left - hurry up!"
    fi
fi

