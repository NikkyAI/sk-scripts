#!/bin/bash
DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

# cd ~/src/cfpecker
# git pull

cd $DIR

git -C cfpecker pull || git clone https://github.com/NikkyAI/cfpecker.git cfpecker

sudo pip install ./cfpecker

# cfpecker
python $DIR/cfpecker/run.py
retval=$?
## copy local files into mods folder #TODO make this happen inside cfpecker with better configurability
#for D in `find modpacks/* -maxdepth 0 -type d`
#do
#    [ ! -d $D/local ] || rsync -avz $D/local/* $D/src/mods/
#done

exit $retval