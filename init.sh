#!/bin/bash
ENV_MYSQLWB_CONFIG_DIR=${MYSQLWB_CONFIG_DIR:-"/data/.config/mysqlwb/config"}
ENV_MYSQLWB_KEYRINGS_DIR=${MYSQLWB_KEYRINGS_DIR:-"/data/.config/mysqlwb/keyrings"}
ENV_TINYRDM_CONFIG_DIR=${TINY_RDM_CONFIG_DIR:-"/data/.config/TinyRDM"}
#sed -i "s#Exec=mysql-workbench#Exec=mysql-workbench --configdir ${ENV_MYSQLWB_CONFIG_DIR}#g" /home/kasm-default-profile/Desktop/mysql-workbench.desktop
enable_x=0
perform_rsync() {
    SRC=$1
    DST=$2
    if [ -d $SRC ]; then
        mkdir -p $DST
        rsync -vzrtopg --progress --delete $SRC $DST
    else
        mkdir -p $SRC
        rsync -vzrtopg --progress --delete $DST $SRC
    fi
}

sync_mysqlwb_configs(){
    set +e
    if [[ $- =~ x ]] ;
    then
        set +x
        enable_x=1
    fi
    while true; do
        perform_rsync ~/.mysql/workbench/ $ENV_MYSQLWB_CONFIG_DIR/
        perform_rsync ~/.local/share/keyrings/ $ENV_MYSQLWB_KEYRINGS_DIR/
        perform_rsync ~/.config/TinyRDM/ $ENV_TINYRDM_CONFIG_DIR/
        sleep 60
        # 每 60s 执行一次 rsync
    done
    if [[ ${enable_x} -eq 1 ]];
    then
        set -x
    fi
    set -e
}
sync_mysqlwb_configs &
exec "$@"
