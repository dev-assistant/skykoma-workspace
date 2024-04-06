#!/usr/bin/env bash
set -ex
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg
sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list'
apt update
apt install -y pgadmin4-desktop
cp /usr/share/applications/pgadmin4.desktop $HOME/Desktop/
chown 1000:1000 $HOME/Desktop/pgadmin4.desktop
chmod +x $HOME/Desktop/pgadmin4.desktop
