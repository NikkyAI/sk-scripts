#!/bin/bash
DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
upload_folder=$DIR/.upload/modpacks
modpacks=( lite_pack penguins_retreat )

cd $DIR
mkdir $upload_folder
for modpack in "${modpacks[@]}"; do
    version=${modpack}_`date +%Y.%m.%d.%H%M%S`
    java -jar $DIR/launcher-builder.jar \
        --version $version \
        --input $DIR/modpacks/$modpack \
        --output $upload_folder \
        --manifest-dest $upload_folder/$modpack.json
        
    retval=$?
    if [ $retval -ne 0 ]; then
        echo "launcher builder failed with error code $retval" 1>&2
        exit $retval
    fi

    mkdir $upload_folder/$modpack

    $DIR/filetree.py \
        --out $upload_folder/$modpack/index.html \
        --pack $modpack

    echo -e "$version" > $upload_folder/$modpack/version.txt
    echo $upload_folder/$modpack/version.txt
    cat $upload_folder/$modpack/version.txt
done

#cd $DIR

echo "\`\`\`" > $upload_folder/_h5ai.header.md
tree modpacks \
    -P "*.jar|*.cfg|*.yml" \
    -I _upload \
    >> $upload_folder/_h5ai.header.md
echo "\`\`\`" >> $upload_folder/_h5ai.header.md

$DIR/upload.sh