source config/server/config.sh

if [ -f $DIR/config/server/$modpack.sh ] ; then
    source config/server/$modpack.sh
else
    echo missing config file $modpack.sh
    return -1
fi

export SERVER SRC_PATH RUN_DIR