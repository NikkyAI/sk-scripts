#!/usr/bin/bash
PDIR=$(pwd)
DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

[ -f $DIR/config.sh ] && source $DIR/config.sh

loader_version='from file in loaders'
pack_version='from.. ?' # to check if update / restart is required

# SRC_PATH='server/export'
# START_COMMAND='java -jar forge.jar'
# RUN_DIR='server/run-dir/'
# PACK='example_pack'

SRC_PATH="${SRC_PATH/#\~/$HOME}"
RUN_DIR="${RUN_DIR/#\~/$HOME}"
SRC_PATH=$( readlink -m "$SRC_PATH/" )
RUN_DIR=$( readlink -m "$RUN_DIR/" )

SRC_PATH="$SRC_PATH"
RUN_DIR="$RUN_DIR"

mkdir $RUN_DIR --parents

function send () {
    # create session if not started already
    result=$( tmux ls -F "#{session_name}" | grep mc )
    [ -z $result ] && tmux new-session -d -s mc -n $PACK
    # check if $PACK is listed or create pane
    result=$( tmux list-windows -F '#{window_name}' )
    [ -z "$(echo $result | grep $PACK | head -1 )" ] && tmux new-window -d -a -t mc -n $PACK
    cmd="$@"
    tmux send-keys -t $PACK -l "$cmd"
    tmux send-keys -t $PACK C-m
    echo "[$PACK] >> $cmd"
}

function get_pid () {
    STR=$( tmux list-panes -a -t mc -F '#{pane_pid}# #{window_name}' | grep "$PACK$" | head -1 )
    pid=$( echo $STR | cut -f1 '-d#' )
    # get all children, grandchildren etc pids
    pids=$(pstree -p $pid | grep -o '([0-9]\+)' | grep -o '[0-9]\+')
    for pid in $pids ; do
        cmd=$( ps -o cmd -p $pid --no-headers )
        # check if the commandname ends with the start command
        if [[ "$cmd" == *"$START_COMMAND" ]]; then
            echo $pid
            return
        fi
    done
    return -1
}

function read_pid () {
    [ ! -f $RUN_DIR/pid ] && return -1
    pid=$(< $RUN_DIR/pid)
    (( $pid < 0 )) && rm "$RUN_DIR/pid" ; return -1
    echo $pid
    return 0
}

function is_running () {
    pid=$(read_pid) || pid=$( get_pid ) || return -1
    kill -0 $pid
    return $?
}

function start () {
    if ! is_running ; then
        echo starting server
        send 'cd' "$RUN_DIR"
        send $SHELL -c $START_COMMAND
        while ! pid=$( get_pid ) 2>&1
        do
            sleep 1
            echo 'waiting for server to start'
        done
        echo $pid > "$RUN_DIR/pid"
    else
        echo server was already running
    fi
}

function stop () {
    if is_running ; then
        # send say restarting server
        pid=$(read_pid) || pid=$(get_pid) || echo "cannot get pid"; return 0
        while kill -0 $pid >/dev/null 2>&1
        do
            send "stop"
            sleep 1
            echo 'waiting for server to stop'
        done
        echo stopped server
        rm "$RUN_DIR/pid"
    else
        echo server is not running
    fi
}

function kill_server () {
    send 'stop'
    pid=$(read_pid) || pid=$(get_pid) || return 0
    kill $pid $1
    rm "$RUN_DIR/pid"
}

function install_forge () {
    is_running
    running=$?
    stop
    # TODO: stop server save state
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
    echo installed $version

    echo 'starting forge server to generate eula'

    if [ ! -f eula.txt ] ; then
        start
        pid=$( get_pid )
        while kill -0 $pid >/dev/null 2>&1
        do
            sleep 1 ; echo 'waiting for server to stop'
        done
        sed -i 's/eula=false/eula=true/' eula.txt
    fi

    #TODO: restart server if it ran before
    if [ "$running" -eq "0" ] ; then
        start
    fi
}

function install_modpack () {
    rsync -a --delete $SRC_PATH/$PACK/mods/ $RUN_DIR/mods/
    #install scripts and configs
    echo installed $PACK mods
}

function install_script () {
    export SRC_PATH START_COMMAND RUN_DIR PACK
    envsubst '$SRC_PATH $START_COMMAND $RUN_DIR $PACK' < "$SRC_PATH/$PACK/server.sh" > "$RUN_DIR/server.sh"
    chmod +x "$RUN_DIR/server.sh"
}

function update () {

    [ -d $SRC_PATH/$PACK/src/ ] && rsync -a --update $SRC_PATH/$PACK/src/ $RUN_DIR/
    # TODO: compare versions and stop ?

    install_forge

    install_modpack

    install_script

    if ! is_running ; then
        echo starting server
        send cd $RUN_DIR
        send $START_COMMAND
    else
        echo server was already running
    fi
}

case "$1" in
  "start")
    start
    ;;
  "stop")
    stop
    ;;
  "kill")
    kill_server
    ;;
  "update")
    update
    ;;
  "install_forge")
    install_forge
    ;;
  "install_modpack")
    install_modpack
    ;;
  "install_script")
    install_script
    ;;
  *)
    echo "You have failed to specify what to do correctly."
    # exit 1
    ;;
esac
cd $PDIR