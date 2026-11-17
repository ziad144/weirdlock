#!/usr/bin/env bash
set -e
[ "$EUID" -eq 0 ] || exec sudo bash "$0" "$@"

THEMES="${WEIRDLOCK_THEMES:-/usr/share/web-greeter/themes}"
CONF="${WEIRDLOCK_CONF:-/etc/lightdm/web-greeter.yml}"
DROP="${WEIRDLOCK_DROPIN:-/etc/lightdm/lightdm.conf.d/90-weirdlock.conf}"

rm -f "$DROP"
rm -rf "$THEMES/weirdlock" "$THEMES/weirdlock.old"
if [ -f "$CONF.weirdlock.bak" ]; then
  cp "$CONF.weirdlock.bak" "$CONF"
  rm -f "$CONF.weirdlock.bak"
else
  echo "no config backup found, check 'theme:' in $CONF yourself"
fi
echo "removed, restart LightDM to go back to your previous greeter (this closes your session)"
