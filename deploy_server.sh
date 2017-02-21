#!/bin/bash
DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

# server='pp-treedi_l2jlj@mc.nikky.moe'
#remote_path='public/mods'
modpacks=( penguins_retreat )

cd $DIR

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

setup=false

while getopts "sh" opt; do
  case $opt in
    s)
      echo "-s was triggered!" >&2
      setup=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

function reset_functions () {
    function upload () {
        echo 'DEFAULT RSYNC IMPLEMENTATION'
        FOLDER=$1
        DESTINATION=${remote_mcpath:-public}/${2}
        
        if [ -z ${server+x} ]; then 
            echo "server is unset"
        else 
            echo "server is set to '$server'"
            port=${remote_port:-"22"}
            echo "rsync -navvz $FOLDER -e \"ssh -p $port\" $server:$DESTINATION"
            rsync -avz $FOLDER -e "ssh -p $port" $server:$DESTINATION \
                --exclude '*.url.txt' \
                --exclude '*.info.json' \
                --update \
                --delete \
                --info=progress2 
        fi
    }
    function ssh_send () {
        ssh $server -p ${remote_port:-"22"} "cd ${remote_mcpath:-public}; $1"
    }
    function send () {
        ssh_send "tmux new-session -d -s mc -n forge"
        result=$(ssh_send "tmux list-windows" 2>&1)
        [ -z "$(echo $result | grep forge | head -1 )" ] && ssh_send "tmux new-window -d -a -t mc -n forge"
        ssh_send "tmux send -t forge \"$1\" C-m"
        # ssh $server -p ${remote_port:-"22"} "cd ${remote_mcpath:-public}; tmux new-session -d -s mc -n forge ; [ -z "$(tmux list-windows | grep forge)" ] && tmux new-window -d -a -t mc -n forge ; tmux send -t forge \"cd cd ~/${remote_mcpath:-public}; $1\" C-m"
    }

    function install() {
        echo 'SETUP NOT YET IMPLEMENTED'
        LOADER=$1
        INSTALLER_FILE=$(basename $LOADER)
        SERVER_FILE=`echo $INSTALLER_FILE | sed -e "s/installer/universal/g"`
        echo $SERVER_FILE
        echo $INSTALLER_FILE
        # send command 
        ssh $server -p ${remote_port:-"22"} "cd ${remote_mcpath:-public}; java -jar $INSTALLER_FILE --installServer; mv -v $SERVER_FILE forge.jar"
    }

    function start() {
        echo 'START DEFAULT TMUX IMPLEMENTATION'
        send "java -jar forge.jar"
        # send "say server startup finished"
        # curl -k -X GET \
        #     -H "X-Access-Server: 8d42fdc4-95be-471b-98d2-55ee586613f2" \
        #     -H "X-Access-Token: 43903004-9a32-48b5-bf09-4e940efa6191"  \
        #     "https://mc.nikky.moe:5656/server/power/on"
    }

    function stop() {
        echo 'STOP DEFAULT TMUX IMPLEMENTATION'
        send "say restarting server"
        send "stop"
        # curl -k -X GET \
        #     -H "X-Access-Server: 8d42fdc4-95be-471b-98d2-55ee586613f2" \
        #     -H "X-Access-Token: 43903004-9a32-48b5-bf09-4e940efa6191"  \
        #     "https://mc.nikky.moe:5656/server/power/off" \
    }
}

for modpack in "${modpacks[@]}"; do
    reset_functions
    temp_folder=/tmp/server_upload/$modpack
    modpack_folder=$DIR/modpacks/$modpack
    mods=$temp_folder/mods
    (
    if [ -f $modpack_folder/deploy.sh ] ; then
        echo 'executing modpack deploy script'
        . $modpack_folder/deploy.sh
    fi
    #cleanup
    rm -R $temp_folder/mods

    # Create server mod upload
    java -cp launcher-builder.jar com.skcraft.launcher.builder.ServerCopyExport \
    --source modpacks/$modpack/src \
    --dest $temp_folder
    
    retval=$?
    if [ $retval -ne 0 ]; then
        echo "launcher builder failed with error code $retval" 1>&2
        exit $retval
    fi

    # stop server
    stop

    if [[ $setup = true ]] ; then
        loader=$( find $modpack_folder/loaders | grep all | sort -n | tail -1 )
        echo $loader
        upload $loader "."
        install $loader
    fi

    # upload files
    
    upload $mods "."

    start
    )
    rm -R $temp_folder
done

rm -R /tmp/server_upload/