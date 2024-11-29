#!/bin/bash

PGREP="com.intellij.idea.Main"
while true
do
    echo -n 1 > /tmp/autorestart && echo -n "raw" > /tmp/ideamode && pkill -f $PGREP
    if [ x$? == x0 ] ;then
        echo "projector idea already exit succ"
        break
    fi
    sleep 1
done
echo "starting idea origin"
# custom_startup.sh will be execute idea.sh automatic
# exec $PROJECTOR_DIR/ide/bin/idea.sh
