#!/bin/zsh

STATE=/tmp/brightness

brightness_control() {
  qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl $*
}

set_brightness() {
  brightness_control setBrightnessSilent $1
}

set_brightness_percent() {
  max=$(brightness_control brightnessMax)
  next=$[$max * $1 / 100]
  brightness_control setBrightnessSilent $next
}

case $1 in
  push)
    current=$(brightness_control brightness)
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
