#!/usr/bin/env bash
set -ex

#apt update
#apt install -y /dockerstartup/install/mongodb/mongodb-mongosh_2.2.0_amd64.deb /dockerstartup/install/mongodb/mongodb-compass_1.42.2_amd64.deb
old_pwd=$(pwd)
cd /dockerstartup/install/studio3t
tar -zxvf ./studio-3t-linux-x64.tar.gz
./studio-3t-linux-x64.sh -q
cd $old_pwd
cp /usr/share/applications/*Studio-3T.desktop $HOME/Desktop/Studio-3T.desktop
chown 1000:1000 $HOME/Desktop/Studio-3T.desktop
chmod +x $HOME/Desktop/Studio-3T.desktop
