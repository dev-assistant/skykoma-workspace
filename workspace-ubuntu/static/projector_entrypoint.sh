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
    echo "enable jcef"
}

agree_policy_auto(){
    AGREE_POLICY_SCRIPT=/tmp/skip.jsh
    cat <<EOF > $AGREE_POLICY_SCRIPT
import java.util.Locale;
import java.util.StringTokenizer;
import java.util.prefs.Preferences;

private static String getNodeKey(String key) {
  int dotIndex = key.lastIndexOf('.');
  return (dotIndex >= 0 ? key.substring(dotIndex + 1) : key).toLowerCase(Locale.ENGLISH);
}

private static Preferences getPreferences(String key) {
  Preferences prefs = Preferences.userRoot();
  final int dotIndex = key.lastIndexOf('.');
  if (dotIndex > 0) {
    StringTokenizer tokenizer = new StringTokenizer(key.substring(0, dotIndex), ".", false);
    while (tokenizer.hasMoreElements()) {
      String str = tokenizer.nextToken();
      prefs = prefs.node(str == null ? null : str.toLowerCase(Locale.ENGLISH));
    }
  }
  return prefs;
}

var key = "JetBrains.privacy_policy.euaCommunity_accepted_version";
var version = "1.0"
var prefs = getPreferences(key);
var nk = getNodeKey(key);
var current = prefs.get(nk, null)
if(current == null || !current.equals(version)) {
  prefs.put(nk, version);
  System.out.println("skip succ");
}
/exit
EOF
    jshell $AGREE_POLICY_SCRIPT 2>&1
}

echo "Idea Starting with USER_UID : $USER_UID"
echo "Idea Starting with USER_GID : $USER_GID"
echo "Idea Starting with USERNAME : $USERNAME"
echo "Idea Starting with HOME : $HOME"
echo "-----------agree_policy_auto begin"
agree_policy_auto
echo "-----------agree_policy_auto end"

if [ x$1 == xprojector ]; then
    echo -n "projector" > /tmp/ideamode
fi
if [ x$(cat /tmp/ideamode) == x"projector" ]; then
    disable_jcef
    echo "starting projector service"
    exec $PROJECTOR_DIR/run.sh "$@"
else
    enable_jcef
    echo "starting raw idea"
    exec $PROJECTOR_DIR/ide/bin/idea.sh "$@"
fi

