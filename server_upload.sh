#!/bin/bash
DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

source $DIR/config/upload/config.sh

cd $DIR
for modpack in "${MODPACKS[@]}"; do
    if [ ! -f $MODPACK_DIR/$modpack/modpack.json ]; then
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
    
    upload_folder=$DIR/.server/$modpack
    mkdir --parent $upload_folder

    export PACK=$modpack

    # clean build and upload to server
    rm -rf $upload_folder
    mkdir $upload_folder/ --parents
    # build server
    java -cp tools/launcher-builder.jar com.skcraft.launcher.builder.ServerCopyExport \
        --source $MODPACK_DIR/$PACK/src \
        --dest $upload_folder/
    # merge loaders into upload folder
    rsync -a --delete $MODPACK_DIR/$PACK/loaders/ $upload_folder/loaders/
    #upload scripts configs etc7
    rm -rf $upload_folder/src/
    [ -d $DIR/server/global/ ] && rsync -a --update $DIR/server/$PACK/ $upload_folder/src/
    [ -d $DIR/server/$PACK/ ] && rsync -a --update $DIR/server/$PACK/ $upload_folder/src/
    # delete .url.txt files
    find $upload_folder/ -type f -name *.url.txt -delete

    #TODO: create config.sh
    #TODO: upload upgrade.sh
    # create the config file for this modpack
    
    envsubst < "$DIR/scripts/template_config.sh" > "$upload_folder/config.sh"
    cp "$DIR/scripts/dumb_updater.sh"  "$upload_folder/update.sh"
    #upload
    if [ -z $"SERVER" ]; then
        #upload locally
        mkdir -p "$SRC_PATH_RESOLVED/$PACK/"
        rsync -av --delete $upload_folder/ "$SRC_PATH_RESOLVED/$PACK/"
    else
        # remote
        # make sure the folder exists
        ssh $SERVER mkdir -p $SRC_PATH/$PACK/
        rsync -a --delete $upload_folder/ $SERVER:$SRC_PATH/$PACK/
    fi 
    
    case "$1" in
    "-update")
        if [ -z $"SERVER" ]; then
            "$SRC_PATH_RESOLVED/$PACK/update.sh"
        else
            ssh -t $SERVER "$SRC_PATH/$PACK/update.sh"
        fi
        ;;
    *)
        echo "not specified -update"
        
        ;;
    esac
done
