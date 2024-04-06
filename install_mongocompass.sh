#!/usr/bin/env bash
set -ex

apt update
apt install -y /dockerstartup/install/mongodb/mongodb-mongosh_2.2.0_amd64.deb /dockerstartup/install/mongodb/mongodb-compass_1.42.2_amd64.deb
cp /usr/share/applications/mongodb-compass.desktop $HOME/Desktop/
chown 1000:1000 $HOME/Desktop/mongodb-compass.desktop
chmod +x $HOME/Desktop/mongodb-compass.desktop
