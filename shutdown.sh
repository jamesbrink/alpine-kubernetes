#!/bin/bash
echo $@

if [[ "$@" == "-r now" ]]; then
  echo "Rebooting"
  # /sbin/reboot
elif [[ "$@" == "-h now" ]]; then
  echo "Shutting down"
  # /sbin/poweroff
fi
