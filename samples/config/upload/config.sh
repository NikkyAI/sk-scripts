DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd $DIR
cd modpacks

MODPACKS=( * ) # lists all files / folders in the modpack directory

cd $DIR

URLBASE="https://nikky.moe/.voodoo/"
LAUNCHER=".launcher"

RSYNC_REMOTE='nikky.moe:~/public_html/.voodoo/'

LAUNCHER_SRC='~/dev/Launcher/'