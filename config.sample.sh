DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd $DIR
cd modpacks

MODPACKS=( * ) # lists all files / folders in the modpack directory

cd $DIR

URLBASE="https://nikky.moe/.voodoo/.launcher"

RSYNC_REMOTE='nikky.moe:~/public_html/.voodoo/'

GIT_LAUNCHER='https://github.com/NikkyAI/Launcher.git'
