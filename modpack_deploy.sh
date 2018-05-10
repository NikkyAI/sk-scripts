#!/bin/bash
DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
upload_folder=$DIR/.upload/modpacks

source $DIR/config/upload/config.sh

cd $DIR

mkdir --parent $upload_folder
[ ! -f $DIR/tools/launcher-builder.jar ] && ./deploy_launcher.sh
for modpack in "${MODPACKS[@]}"; do
    echo "processing $modpack"
    if [ ! -f $MODPACK_DIR/$modpack/modpack.json ]; then
        echo "modpack json file not found!"
        continue
    fi
    version=${modpack}_`date +%Y.%m.%d.%H%M%S`
    
    java -jar $DIR/tools/launcher-builder.jar \
        --version "$version" \
        --input "$MODPACK_DIR/$modpack" \
        --output "$upload_folder" \
        --manifest-dest "$upload_folder/$modpack.json"
        
    retval=$?
    if [ $retval -ne 0 ]; then
        echo "launcher builder failed with error code $retval" 1>&2
        exit $retval
    fi

    mkdir $upload_folder/$modpack

    echo $DIR/scripts/filetree.py \
        --root $MODPACK_DIR \
        --out $upload_folder/$modpack/index.html \
        --pack $modpack \
        --url $URLBASE

    $DIR/scripts/filetree.py \
        --root $MODPACK_DIR \
        --out $upload_folder/$modpack/index.html \
        --pack $modpack \
        --url $URLBASE

    echo -e "$version" > $upload_folder/$modpack/version.txt
    echo $upload_folder/$modpack/version.txt
    cat $upload_folder/$modpack/version.txt
done

#TODO: generate packages.json

python $DIR/scripts/packages.py --dir $DIR/.upload/modpacks "${MODPACKS[@]}"
#cd $DIR

$DIR/upload.sh