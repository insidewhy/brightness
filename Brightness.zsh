#!/bin/zsh

STATE=/tmp/brightness

set_brightness() {
  qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl setBrightnessSilent $1
}

set_brightness_percent() {
  max=$(qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl brightnessMax)
  next=$[$max * $1 / 100]
  qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl setBrightnessSilent $next
}

case $1 in
  push)
    current=$(qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl brightness)
    echo $current >> $STATE
    set_brightness_percent $2
    ;;

  pop)
    last=$(tail -1 $STATE)
    if [ -z $last ] ; then
      echo >/dev/stderr no last brightness
      exit 1
    fi
    set_brightness $last
    truncate -s -$[${#last} + 1] $STATE
    ;;

  *)
    set_brightness_percent $1
esac
