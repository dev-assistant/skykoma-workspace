#!/usr/bin/env bash
echo -e "\n\n------------------Staring custom_startup.sh ------------------"
set -ex
# TODO replace START_COMMAND depends on env settings on startup
# if xxx
START_COMMAND="/projector/projector_entrypoint.sh"
PGREP="com.intellij.idea.Main"
export MAXIMIZE="false"
export MAXIMIZE_NAME="Idea"
# TODO support maximize by windowid (pid -> windowid)
# wmctrl -ir $(wmctrl -lp |grep $(pgrep -f $PGREP)|awk '{print $1}') -b add,maximized_vert,maximized_horz
# TODO support maximize by WM_CLASS
# wmctrl -xr jetbrains-idea-ce.jetbrains-idea-ce -b add,maximized_vert,maximized_horz
export NODE_ENV=production
MAXIMIZE_SCRIPT=$STARTUPDIR/maximize_window.sh
DEFAULT_ARGS=""
ARGS=${APP_ARGS:-$DEFAULT_ARGS}
echo -n 1 > /tmp/autorestart
echo -n "noprojector" > /tmp/ideamode
echo "-----------Staring change default ui"
# xfconf-query -c xfce4-panel -p /panels/panel-1/mode -s 1
# make panel bar vertical
xfconf-query -c xfce4-panel -p /panels/panel-1/mode -n -t int -s 1
# make panel bar unlock and hide intelligently
xfconf-query -c xfce4-panel -p /panels/panel-1/position-locked -s false
xfconf-query -c xfce4-panel -p /panels/panel-1/autohide-behavior -n -t int -s 1
echo "-----------Staring Clear conflict_keys"
xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/default/<Primary><Alt>l' -s ''
xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/custom/<Primary><Alt>l' -s ''
xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/default/<Alt>Insert' -s ''
xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Alt>Insert' -s ''
xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Alt>Insert' -r
xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/default/<Alt>F7' -s ''
xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Alt>F7' -s ''
xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Alt>F7' -r
xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/default/<Primary><Alt>Left' -s ''
xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Primary><Alt>Left' -s ''
xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Primary><Alt>Left' -r
xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/default/<Primary><Alt>Right' -s ''
xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Primary><Alt>Right' -s ''
xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Primary><Alt>Right' -r
echo "-----------Starting ibus-daemon"
ibus-daemon -dxr
gsettings set org.freedesktop.ibus.general preload-engines "['xkb:us::eng', 'libpinyin']"
gsettings set org.freedesktop.ibus.general.hotkey triggers "['<Control>1']"

options=$(getopt -o gau: -l go,assign,url: -n "$0" -- "$@") || exit
eval set -- "$options"

while [[ $1 != -- ]]; do
    case $1 in
        -g|--go) GO='true'; shift 1;;
        -a|--assign) ASSIGN='true'; shift 1;;
        -u|--url) OPT_URL=$2; shift 2;;
        *) echo "bad option: $1" >&2; exit 1;;
    esac
done
shift

# Process non-option arguments.
for arg; do
    echo "arg! $arg"
done

FORCE=$2

kasm_exec() {
    if [ -n "$OPT_URL" ] ; then
        URL=$OPT_URL
    elif [ -n "$1" ] ; then
        URL=$1
    fi 
    
    # Since we are execing into a container that already has the browser running from startup, 
    #  when we don't have a URL to open we want to do nothing. Otherwise a second browser instance would open. 
    if [ -n "$URL" ] ; then
        sudo /usr/bin/filter_ready
        sudo /usr/bin/desktop_ready
        bash ${MAXIMIZE_SCRIPT} &
        $START_COMMAND $ARGS $OPT_URL
    else
        echo "No URL specified for exec command. Doing nothing."
    fi
}

kasm_startup() {
    if [ -n "$KASM_URL" ] ; then
        URL=$KASM_URL
    elif [ -z "$URL" ] ; then
        URL=$LAUNCH_URL
    fi

    if [ -z "$DISABLE_CUSTOM_STARTUP" ] ||  [ -n "$FORCE" ] ; then

        echo "Entering process startup loop"
        set +x
        while true
        do
            if ! pgrep -f $PGREP > /dev/null
            then
                sudo /usr/bin/filter_ready
                sudo /usr/bin/desktop_ready
                set +e
                bash ${MAXIMIZE_SCRIPT} &
                if [ x$(cat /tmp/autorestart) == x"0" ]; then
                    echo "autorestart disabled"
                else
                    $START_COMMAND $ARGS $URL
                fi
                set -e
            fi
            sleep 1
        done
        set -x
    
    fi

} 


if [ -n "$GO" ] || [ -n "$ASSIGN" ] ; then
    echo "-----------Starting kasm_exec"
    kasm_exec
    echo "-----------End kasm_exec"
else
    echo "-----------Starting kasm_startup"
    kasm_startup
    echo "-----------End kasm_startup"
fi
echo -e "\n\n------------------End custom_startup.sh ------------------"
