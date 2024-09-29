#!/usr/bin/env bash
set -ex

# apt update
apt install  --fix-missing -y rsync gnome-keyring libatkmm-1.6-1v5 libcairomm-1.0-1v5     libglibmm-2.4-1v5     libgtk2.0-0     libgtkmm-3.0-1v5  libmysqlclient21 libopengl0     libpangomm-1.4-1v5     libpcrecpp0v5     libproj22     libpython3.10     libsecret-1-0     libsigc++-2.0-0v5     libssh-4     libvsqlitepp3v5     libzip4  mysql-client /dockerstartup/install/workbench/mysql-workbench.deb
# cp /usr/share/applications/microsoft-edge.desktop $HOME/Desktop/
# sed -i 's/microsoft-edge-stable/microsoft-edge-stable --no-sandbox/g' $HOME/Desktop/microsoft-edge.desktop
# chown 1000:1000 $HOME/Desktop/microsoft-edge.desktop

cp /usr/share/applications/mysql-workbench.desktop $HOME/Desktop/
chown 1000:1000 $HOME/Desktop/mysql-workbench.desktop
chmod +x $HOME/Desktop/mysql-workbench.desktop
