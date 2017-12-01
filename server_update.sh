#!/bin/bash
DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

cd $DIR/modpacks
MODPACKS=( * ) #TODO: load from config
#modpacks=( fuckitbrokeagain cpack )

cd $DIR
for modpack in "${MODPACKS[@]}"; do
    if [ ! -f $DIR/modpacks/$modpack/modpack.json ]; then
        echo "modpack json file not found!"
        continue
    fi
    export SRC_PATH_RESOLVED="${SRC_PATH/#\~/$HOME}"

    source $DIR/scripts/load_server_config.sh
    if [ $? -eq 0 ] ; then
        echo loaded config
    else
        echo skipping $modpack
        continue
    fi
    
    
    if [ -z $"SERVER" ]; then
        "$SRC_PATH_RESOLVED/$PACK/update.sh"
    else
        ssh -t $SERVER "$SRC_PATH/$PACK/update.sh"
    fi
        
    
done
