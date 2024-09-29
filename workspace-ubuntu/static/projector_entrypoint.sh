#!/bin/bash
disable_jcef(){
    JCEF_ENABLE_PREFIX="-Dide.browser.jcef.enabled="
    JCEF_DISABLE="$JCEF_ENABLE_PREFIX""false"
    sed -i "/^${JCEF_ENABLE_PREFIX}/s#.*#${JCEF_DISABLE}#" "${IDEA_VM_FILE}"
    grep -q "^${JCEF_ENABLE_PREFIX}" "${IDEA_VM_FILE}" || echo "${JCEF_DISABLE}" >> "${IDEA_VM_FILE}"
    echo "disable jcef"
}
enable_jcef(){
    JCEF_ENABLE_PREFIX="-Dide.browser.jcef.enabled="
    JCEF_ENABLED="$JCEF_ENABLE_PREFIX""true"
    sed -i "/^${JCEF_ENABLE_PREFIX}/s#.*#${JCEF_ENABLED}#" "${IDEA_VM_FILE}"
    grep -q "^${JCEF_ENABLE_PREFIX}" "${IDEA_VM_FILE}" || echo "${JCEF_ENABLED}" >> "${IDEA_VM_FILE}"
    echo "disable jcef"
}
echo "Projector Starting with USER_UID : $USER_UID"
echo "Projector Starting with USER_GID : $USER_GID"
disable_jcef
# disable autorestart by custom_startup.sh
# TODO write switch command for convenience
PGREP="com.intellij.idea.Main"
while true
do
    echo -n 0 > /tmp/autorestart && pkill -f $PGREP
    if [ x$? == x0 ] ;then
        echo "windowd idea already exit succ"
        break
    fi
    sleep 1
done
echo "starting projector service"
if [ $USER_UID == '0' ]; then
    exec $PROJECTOR_DIR/run.sh "$@"
else
    exec gosu $USERNAME $PROJECTOR_DIR/run.sh "$@"
fi
