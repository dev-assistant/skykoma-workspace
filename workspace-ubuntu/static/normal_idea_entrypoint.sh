#!/bin/bash

PGREP="com.intellij.idea.Main"
while true
do
    echo -n 1 > /tmp/autorestart && pkill -f $PGREP
    if [ x$? == x0 ] ;then
        echo "projector idea already exit succ"
        break
    fi
    sleep 1
done
echo "starting idea origin"
# exec $PROJECTOR_DIR/ide/bin/idea.sh