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
echo "Idea Starting with USER_UID : $USER_UID"
echo "Idea Starting with USER_GID : $USER_GID"
if [ x$1 == xprojector ]; then
    echo -n "projector" > /tmp/ideamode
fi
if [ x$(cat /tmp/ideamode) == x"projector" ]; then
    disable_jcef
    echo "starting projector service"
    if [ $USER_UID == '0' ]; then
        exec $PROJECTOR_DIR/run.sh "$@"
    else
        exec gosu $USERNAME $PROJECTOR_DIR/run.sh "$@"
    fi
else
    enable_jcef
    if [ $USER_UID == '0' ]; then
        exec $PROJECTOR_DIR/ide/bin/idea.sh "$@"
    else
        exec gosu $USERNAME $PROJECTOR_DIR/ide/bin/idea.sh "$@"
    fi
fi

