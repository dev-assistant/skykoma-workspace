#!/bin/bash
USER_PASS=${LOCAL_USER_PASSWORD:-"skykoma123.@IDE"}
ensure_idea_config_files() {
    IDEA_CONFIG_DIR_NAME=$(cat /projector/ide/product-info.json |grep dataDirectoryName |awk -F'"' '{print $4}')
    echo "IDEA_CONFIG_DIR_NAME:$IDEA_CONFIG_DIR_NAME"
    IDEA_COFNIG_DIR="$HOME/.config/JetBrains/$IDEA_CONFIG_DIR_NAME"
    echo "IDEA_COFNIG_DIR:$IDEA_COFNIG_DIR"
    if [ ! -d "${IDEA_COFNIG_DIR}" ]; then
        mkdir -p "${IDEA_COFNIG_DIR}"
        echo "create config dir $IDEA_COFNIG_DIR"
    fi
    if [ -f "${IDEA_COFNIG_DIR}/.lock" ]; then
        rm -rf ${IDEA_COFNIG_DIR}/.lock
        echo "clean idea lock files"
    fi
    export IDEA_VM_FILE="$IDEA_COFNIG_DIR/idea64.vmoptions"
    echo "IDEA_VM_FILE:$IDEA_VM_FILE"
    if [ ! -f "${IDEA_VM_FILE}" ]; then
        touch "$IDEA_VM_FILE"
        echo "create vm options file $IDEA_VM_FILE"
    fi
    export IDEA_PROPERTIES_FILE="$IDEA_COFNIG_DIR/idea.properties"
    echo "IDEA_PROPERTIES_FILE:$IDEA_PROPERTIES_FILE"
    if [ ! -f "${IDEA_PROPERTIES_FILE}" ]; then
        touch "$IDEA_PROPERTIES_FILE"
        echo "create vm properties file $IDEA_PROPERTIES_FILE"
    fi
    CACHE_DIR=$HOME/.cache/JetBrains/$IDEA_CONFIG_DIR_NAME
    echo "CACHE_DIR:$CACHE_DIR"
    rm -rf $CACHE_DIR/jcef_cache/SingletonCookie
    rm -rf $CACHE_DIR/jcef_cache/SingletonLock 
    rm -rf $CACHE_DIR/jcef_cache/SingletonSocket
    echo "clean idea jcef_cache files"
}
setup_uid_gid(){
    echo "Workspace Starting with USER_UID : $USER_UID"
    echo "Workspace Starting with USER_GID : $USER_GID"
    echo "Workspace Starting with USERNAME : $USERNAME"
    echo "-----workspace------Starting"
    if [ $USER_UID == '0' ]; then
        # root运行容器，容器里面一样root运行
        export HOME=/root
        chown -R root:root /home/project
    else
        # 启动传UID=1000  不需要修改UID，GID值
        if [[ $USER_UID != 1000 ]]; then
            echo "-----workspace---usermod uid start---"$(date "+%Y-%m-%d %H:%M:%S")
            usermod -u $USER_UID $USERNAME
            find / -user 1000 -exec chown -h $USERNAME {} \;
            echo "-----workspace---usermod uid end---"$(date "+%Y-%m-%d %H:%M:%S")
        fi
        #非root运行，通过传入环境变量创建自定义用户的uid,gid，否则默认uid,gid为1000
        if [[ $USER_GID != 1000 ]]; then
            echo "-----workspace---usermod gid start---"$(date "+%Y-%m-%d %H:%M:%S")
            # groupmod -g $USER_GID $USERNAME
            groupmod -g $USER_GID --non-unique $USERNAME
            find / -group 1000 -exec chgrp -h $USERNAME {} \;
            echo "-----workspace---usermod gid end---"$(date "+%Y-%m-%d %H:%M:%S")
        fi
        export HOME=/home/$USERNAME
    fi
    mkdir -p $HOME/.ssh
    if [ "${ENV_PERSISTENT_HOME}" = "1" ]; then
        chown -h $USERNAME:$USERNAME $HOME
        chown $USERNAME:$USERNAME $PERSISTENT_HOME_DIR
    fi
    chown $USERNAME:$USERNAME $HOME
    chown -R $USERNAME:$USERNAME $HOME/.
    export PWD=$HOME
}

change_password() {
    if [ $USER_UID == '0' ]; then
        echo "root:$USER_PASS" | chpasswd
    else
        echo "root:$USER_PASS" | chpasswd
        echo "$USERNAME:$USER_PASS" | chpasswd
    fi
}

disable_consent_options() {
    # https://github.com/JetBrains/intellij-community/blob/65cf881f35eea8a594b9375651a7a03823f09723/platform/platform-impl/src/com/intellij/ide/gdpr/ConsentOptions.java#L37
    CONSENT_OPTION_DIR=~/.local/share/JetBrains/consentOptions
    mkdir -p $CONSENT_OPTION_DIR
    echo -n "rsch.send.usage.stat:1.1:0:$(date +%s000)" > $CONSENT_OPTION_DIR/accepted
    echo "disable rsch.send.usage.stat succ"
}
ENV_PROJECTOR_SERVER_TOKEN=${PROJECTOR_SERVER_TOKEN:-""}
ENV_PROJECTOR_SERVER_RO_TOKEN=${PROJECTOR_SERVER_RO_TOKEN:-"$ENV_PROJECTOR_SERVER_TOKEN"}

set_projector_server_token(){
    if [ x"${ENV_PROJECTOR_SERVER_TOKEN}" = x"" ]; then
        echo "keep projector token empty"
        return
    fi
    TOKEN_LINE1_PREFIX="-DORG_JETBRAINS_PROJECTOR_SERVER_HANDSHAKE_TOKEN="
    TOKEN_LINE2_PREFIX="-DORG_JETBRAINS_PROJECTOR_SERVER_RO_HANDSHAKE_TOKEN="
    TOKEN_LINE1="$TOKEN_LINE1_PREFIX$ENV_PROJECTOR_SERVER_TOKEN"
    TOKEN_LINE2="$TOKEN_LINE2_PREFIX$ENV_PROJECTOR_SERVER_RO_TOKEN"
    # replace existing lines
    sed -i "/^${TOKEN_LINE1_PREFIX}/s#.*#${TOKEN_LINE1}#" "${IDEA_VM_FILE}"
    sed -i "/^${TOKEN_LINE2_PREFIX}/s#.*#${TOKEN_LINE2}#" "${IDEA_VM_FILE}"
    # Check again, if the lines do not exist, add them
    grep -q "^${TOKEN_LINE1_PREFIX}" "${IDEA_VM_FILE}" || echo "${TOKEN_LINE1}" >> "${IDEA_VM_FILE}"
    grep -q "^${TOKEN_LINE2_PREFIX}" "${IDEA_VM_FILE}" || echo "${TOKEN_LINE2}" >> "${IDEA_VM_FILE}"
    echo "set projector server rw token:$ENV_PROJECTOR_SERVER_TOKEN"
    echo "set projector server ro token:$ENV_PROJECTOR_SERVER_RO_TOKEN"
}

disable_jcef_sandbox() {
    if [ $USER_UID == '0' ]; then
        JCEF_SANDBOX_ENABLE_PREFIX="-Dide.browser.jcef.sandbox.enable="
        JCEF_SANDBOX_DISABLE="$JCEF_SANDBOX_ENABLE_PREFIX""false"
        sed -i "/^${JCEF_SANDBOX_ENABLE_PREFIX}/s#.*#${JCEF_SANDBOX_DISABLE}#" "${IDEA_VM_FILE}"
        grep -q "^${JCEF_SANDBOX_ENABLE_PREFIX}" "${IDEA_VM_FILE}" || echo "${JCEF_SANDBOX_DISABLE}" >> "${IDEA_VM_FILE}"
        echo "disable jcef sandbox"
    else
        JCEF_SANDBOX_ENABLE_PREFIX="-Dide.browser.jcef.sandbox.enable="
        JCEF_SANDBOX_DISABLE="$JCEF_SANDBOX_ENABLE_PREFIX""true"
        sed -i "/^${JCEF_SANDBOX_ENABLE_PREFIX}/s#.*#${JCEF_SANDBOX_DISABLE}#" "${IDEA_VM_FILE}"
        grep -q "^${JCEF_SANDBOX_ENABLE_PREFIX}" "${IDEA_VM_FILE}" || echo "${JCEF_SANDBOX_DISABLE}" >> "${IDEA_VM_FILE}"
        echo "disable jcef sandbox"
    fi
}

set_idea_is_internal() {
    LINE_INTERNAL_PREFIX="idea.is.internal="
    LINE_INTERNAL_ENABLED="$LINE_INTERNAL_PREFIX""true"
    # replace existing lines
    sed -i "/^${LINE_INTERNAL_PREFIX}/s#.*#${LINE_INTERNAL_ENABLED}#" "${IDEA_PROPERTIES_FILE}"
    # Check again, if the lines do not exist, add them
    grep -q "^${LINE_INTERNAL_PREFIX}" "${IDEA_PROPERTIES_FILE}" || echo "${LINE_INTERNAL_ENABLED}" >> "${IDEA_PROPERTIES_FILE}"
    echo "set_idea_is_internal"
}

disable_tips_of_the_day() {
    LINE_PREFIX="ide.show.tips.on.startup.default.value="
    LINE_MODIFIED="$LINE_PREFIX""false"
    # replace existing lines
    sed -i "/^${LINE_PREFIX}/s#.*#${LINE_MODIFIED}#" "${IDEA_PROPERTIES_FILE}"
    # Check again, if the lines do not exist, add them
    grep -q "^${LINE_PREFIX}" "${IDEA_PROPERTIES_FILE}" || echo "${LINE_MODIFIED}" >> "${IDEA_PROPERTIES_FILE}"
    echo "disable_tips_of_the_day"
}

disable_update(){
    UPDATE_CONFIG_XML_DIR=$IDEA_COFNIG_DIR/options
    mkdir -p $UPDATE_CONFIG_XML_DIR
    UPDATE_CONFIG_XML=$UPDATE_CONFIG_XML_DIR/updates.xml
    cat <<EOF > $UPDATE_CONFIG_XML
<application>
  <component name="UpdatesConfigurable">
    <option name="CHECK_NEEDED" value="false" />
    <option name="LAST_BUILD_CHECKED" value="IC-231.9392.1" />
    <option name="LAST_TIME_CHECKED" value="1727546488541" />
    <option name="PLUGINS_CHECK_NEEDED" value="false" />
    <option name="SHOW_WHATS_NEW_EDITOR" value="false" />
    <option name="WHATS_NEW_SHOWN_FOR" value="231" />
  </component>
EOF
printf "</application>"  >> $UPDATE_CONFIG_XML
    echo "disable_update"
}

auto_trust_dir(){
    TRUST_CODE_DIR=$1
    CONFIG_XML_DIR=$IDEA_COFNIG_DIR/options
    mkdir -p $CONFIG_XML_DIR
    UPDATE_CONFIG_XML=$CONFIG_XML_DIR/trusted-paths.xml
    cat <<EOF > $UPDATE_CONFIG_XML
<application>
  <component name="Trusted.Paths.Settings">
    <option name="TRUSTED_PATHS">
      <list>
        <option value="$TRUST_CODE_DIR" />
      </list>
    </option>
  </component>
EOF
printf "</application>"  >> $UPDATE_CONFIG_XML
    echo "auto_trust_dir $TRUST_CODE_DIR"
}

if [ -f "$PROJECTOR_DIR/ide/ide.tar.gz" ];then
    echo "-----------Starting unzip ide.tar.gz"
    cd $PROJECTOR_DIR/ide
    tar -zxf ide.tar.gz && \
    /usr/bin/mv -fv idea-IC*/* . && \
    mv $PROJECTOR_DIR/ide-projector-launcher.sh $PROJECTOR_DIR/ide/bin && \
    chmod +x $PROJECTOR_DIR/ide/bin/ide-projector-launcher.sh && \
    rm -rf ide.tar.gz
    cd /
fi
chown -R $USERNAME:$USERNAME $PROJECTOR_DIR
ensure_idea_config_files
echo "-----------Starting change_password"
change_password
echo "-----------Starting disable_consent_options"
disable_consent_options
echo "-----------Starting set_projector_server_token"
set_projector_server_token
echo "-----------Starting disable_jcef_sandbox"
disable_jcef_sandbox
echo "-----------Starting set_idea_internal"
set_idea_is_internal
echo "-----------Starting disable_tips_of_the_day"
disable_tips_of_the_day
echo "-----------Starting disable_update"
disable_update
echo "-----------Starting auto_trust_dir"
auto_trust_dir $ENV_PERSISTENT_HOME_DIR
echo "-----------Starting sshd"
/usr/sbin/sshd -E /var/log/sshd.log
echo "-----------Starting setup_uid_gid"
setup_uid_gid
# next shell command
echo -e "\n\n------------------ EXECUTE COMMAND ------------------"
echo "Executing command: '$@'"
if [ $USER_UID == '0' ]; then
    exec "$@"
else
    exec gosu $USERNAME "$@"
fi
