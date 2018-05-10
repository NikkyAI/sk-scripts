#!/bin/bash
upload_folder=.upload/
static_folder=static/
DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

source $DIR/config/upload/config.sh

cd $DIR

rsync -av --update $static_folder $upload_folder
find $upload_folder -type d -empty -delete
rsync -av --update --delete $upload_folder $RSYNC_REMOTE
