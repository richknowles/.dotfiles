#!/usr/bin/env bash
profile=$(powerprofilesctl get)
case "$profile" in
    performance) powerprofilesctl set balanced ;;
    balanced)    powerprofilesctl set power-saver ;;
    power-saver) powerprofilesctl set performance ;;
esac
