#!/bin/bash
upload_folder=.upload/
static_folder=static/

cd $(cd -P -- "$(dirname -- "$0")" && pwd -P)

rsync -av --update $static_folder $upload_folder
find $upload_folder -type d -empty -delete
rsync -av --update --delete $upload_folder ~/websites/nikky.moe/mc/
