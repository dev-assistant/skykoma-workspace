#!/usr/bin/env bash
set -ex

apt update
apt install -y redis-tools libgtk-3-dev libwebkit2gtk-4.0-dev libfuse-dev libfuse2 /dockerstartup/install/tiny-rdm/tiny-rdm*.deb
cp /usr/share/applications/tiny-rdm.desktop $HOME/Desktop/
chown 1000:1000 $HOME/Desktop/tiny-rdm.desktop
chmod +x $HOME/Desktop/tiny-rdm.desktop
