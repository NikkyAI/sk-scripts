#!/usr/bin/bash
PDIR=$(cwd)
DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

echo $1
pack_path=$1
loader_version='from file in loaders'
pack_version='from.. ?'

pack='forge'

function send () {
    # create session if not started already
    tmux new-session -d -s mc -n ${pack}
    # check if forge is listed
    result=$(tmux list-windows)
    [ -z "$(echo $result | grep ${pack} | head -1 )" ] && tmux new-window -d -a -t mc -n ${pack}
    tmux send -t ${pack} \"$1\" C-m
}





cd $PDIR