#!/usr/bin/env bash
set -e

url=${1:-none}
pkg=${2%.dmg}.dmg

if [ ! -e "$pkg" ] ; then
  echo "Downloading ..."
  curl -L -o "$pkg" "$url"
fi

mount_point=$(xmlstarlet sel -T -t \
  -c '//key[text()="mount-point"]/following-sibling::*[1]' \
  <(sudo hdiutil attach "$pkg" -plist))

# install *.app
sudo cp -r "$mount_point"/*.app /Applications || true

# install *.pkg
if ls "$mount_point"/*.pkg >/dev/null 2>&1 ; then
  IFS_=$IFS
  IFS=$'\n' pkgs=($(ls -1 "$mount_point"/*.app))
  IFS=$IFS_
  for pkg in "${pkgs[@]}" ; do
    sudo installer -pkg "$pkg" -target /
  done
fi

sudo hdiutil detach "$mount_point"
