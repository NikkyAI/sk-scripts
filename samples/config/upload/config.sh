cd $DIR

MODPACK_DIR="$DIR/workspace"
cd $MODPACK_DIR

ls -la

MODPACKS=( * ) # lists all files / folders in the modpack directory
for modpack in "${MODPACKS[@]}"; do
  if [ ! -f $MODPACK_DIR/$modpack/modpack.json ]; then
    continue;
  else
    new_array+=( "$modpack" )
  fi
done

MODPACKS=("${new_array[@]}")
unset new_array

# echo modpacks: ${MODPACKS[@]}
# for modpack in "${MODPACKS[@]}"; do
#   echo modpack: $modpack
# done

cd $DIR

URLBASE="https://nikky.moe/.sk/"
LAUNCHER=".launcher"

RSYNC_REMOTE='nikky.moe:~/public_html/.sk/'

LAUNCHER_SRC='/home/nikky/dev/Launcher'
