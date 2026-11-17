#!/usr/bin/env bash
set -e
[ "$EUID" -eq 0 ] || exec sudo bash "$0" "$@"

SRC="$(cd "$(dirname "$0")" && pwd)"
THEMES="${WEIRDLOCK_THEMES:-/usr/share/web-greeter/themes}"
CONF="${WEIRDLOCK_CONF:-/etc/lightdm/web-greeter.yml}"
DROP="${WEIRDLOCK_DROPIN:-/etc/lightdm/lightdm.conf.d/90-weirdlock.conf}"
DEST="$THEMES/weirdlock"

for f in index.html index.yml config.js; do
  [ -f "$SRC/$f" ] || { echo "missing $f, aborting"; exit 1; }
done
grep -q '^secondary_html:' "$SRC/index.yml" || { echo "index.yml needs secondary_html, aborting"; exit 1; }

mkdir -p "$THEMES"
TMP="$(mktemp -d "$THEMES/.weirdlock.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
cp "$SRC"/index.html "$SRC"/index.yml "$SRC"/config.js "$TMP"/
chmod -R a+rX "$TMP"

rm -rf "$DEST.old"
[ -d "$DEST" ] && mv "$DEST" "$DEST.old"
mv "$TMP" "$DEST"
trap - EXIT

if [ -f "$CONF" ]; then
  [ -f "$CONF.weirdlock.bak" ] || cp "$CONF" "$CONF.weirdlock.bak"
  sed -i 's/^\([[:space:]]*theme:\).*/\1 weirdlock/' "$CONF"
else
  echo "$CONF not found, set 'theme: weirdlock' manually"
fi

if [ "$1" = "--enable" ]; then
  mkdir -p "$(dirname "$DROP")"
  printf '[Seat:*]\ngreeter-session=web-greeter\n' > "$DROP"
  echo "web-greeter enabled, restart LightDM to apply it (this closes your session)"
else
  echo "theme installed, run with --enable to also switch LightDM to web-greeter"
fi
echo "preview: web-greeter --debug"
