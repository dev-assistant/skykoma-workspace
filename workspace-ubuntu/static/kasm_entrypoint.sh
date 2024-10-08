#!/bin/bash
export USER_UID=${LOCAL_USER_UID:-1000}
export USER_GID=${LOCAL_USER_GID:-1000}
export USERNAME=${PROJECTOR_USER_NAME:-"kasm-user"}
export ENV_PERSISTENT_HOME=${PERSISTENT_HOME:-"0"}
export ENV_PERSISTENT_HOME_DIR=${PERSISTENT_HOME_DIR:-"/data/root"}


persist_home_dir() {
    HOME_DIR="$1"
    PERSIST_DIR="$2"
    if [ "${ENV_PERSISTENT_HOME}" = "1" ]; then
        if [ ! -d "${PERSIST_DIR}" ]; then
            mkdir -p "${PERSIST_DIR}"
            cp -r "${HOME_DIR}/." "${PERSIST_DIR}"
            echo "init $PERSIST_DIR"
        fi
        if [ -e "${HOME_DIR}" ] && [ ! -L "${HOME_DIR}" ]; then
            rm -rf "${HOME_DIR}-bak" && mv "${HOME_DIR}" "${HOME_DIR}-bak"
            echo "backup $HOME_DIR to ${HOME_DIR}-bak"
        fi
        if [ ! -d "${HOME_DIR}" ]; then
            ln -sf "${PERSIST_DIR}" "${HOME_DIR}"
            echo "recover $PERSIST_DIR to $HOME_DIR"
        fi
    fi
    chmod 644 $PERSIST_DIR
}

if [ $USER_UID == '0' ]; then
    export HOME=/root
else
    export HOME=/home/$USERNAME
fi
echo "-----------Starting persist_home_dir"
persist_home_dir $HOME "$ENV_PERSISTENT_HOME_DIR"
# next shell command
echo -e "\n\n------------------ EXECUTE COMMAND ------------------"
echo "Executing command: '$@'"
exec "$@"
