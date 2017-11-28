#!/usr/bin/bash
PDIR=$(pwd)
DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

[ -f $DIR/config.sh ] && source $DIR/config.sh

SRC_PATH="${SRC_PATH/#\~/$HOME}"
RUN_DIR="${RUN_DIR/#\~/$HOME}"
SRC_PATH=$( readlink -m "$SRC_PATH/" )
RUN_DIR=$( readlink -m "$RUN_DIR/" )

SRC_PATH="$SRC_PATH"
RUN_DIR="$RUN_DIR"

mkdir $RUN_DIR --parents

cd $RUN_DIR

function install_forge () {
    installer_path=$( readlink -f "$SRC_PATH/$PACK/loaders/*.jar" )
    echo "installer $installer_path  $SRC_PATH/$PACK/loaders/*.jar"
    installer_file=$( basename $installer_path )
    log_file="${installer_file}.log"
    universal_file=$( sed "s/installer/universal/g" <<< "$installer_file" )
    mc_version=$( echo $universal_file | cut -f2 -d- )
    forge_version=$( echo $universal_file | cut -f3 -d- )
    version="${mc_version}-${forge_version}"

    mkdir -p "$RUN_DIR"
    cd $RUN_DIR
    universal_path=$( readlink -f "$universal_file" )

    # install server

    java -jar $installer_path --installServer
    mkdir logs --parent
    mv -v $log_file logs/
    mv -v $universal_file forge.jar
    echo "installed forge $version"

}

function install_modpack () {
    rsync -a --delete $SRC_PATH/$PACK/mods/ $RUN_DIR/mods/
    [ -d $SRC_PATH/$PACK/src/ ] && rsync -a --update $SRC_PATH/$PACK/src/ $RUN_DIR/
    #install scripts and configs
    echo installed $PACK mods
}

function install_script () {
    export SRC_PATH RUN_DIR PACK
    envsubst '$SRC_PATH $RUN_DIR $PACK' < "$SRC_PATH/$PACK/update.sh" > "$RUN_DIR/update.sh"
    chmod +x "$RUN_DIR/update.sh"
}

echo updating $PACK

if [ ! -f eula.txt ] ; then
    read -r -p "Do you accept the Minecraft EULA? [Y/n] " response
    response=${response,,}    # tolower
    if [[ "$response" =~ ^(no|n)$ ]] ; then
        echo 'play something else then'
        exit
    else
        echo 'writing eula.txt'
        echo -e 'eula=true\n' > eula.txt
    fi
fi

install_forge
install_modpack
install_script

cd $PDIR