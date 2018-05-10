# sk-scripts

## setuo and getting started

1. install and set up voodoo https://github.com/elytra/Voodoo

2. symlink config and modpacks to your pack development environment \
   this is recommended to avoid loosing gitignored files

    ```bash
    dev=~/dev/Voodoo # this would be your Voodoo working directory
    ln -s $dev/workspace/ worspace/
    ```

3. make sure your fork of sklauncher is ready \
   https://github.com/SKCraft/Launcher \
   at the moment the script expects a specific  \
   fork that adds more targets though \
   https://github.com/NikkyAI/Launcher

4. configure the scripts

    copy the sample configs

    ```bash
    rsync -a --update samples/ .
    ```

    **adapt the configuration to fit your folder structure**

4. run

    ```bash
    ./launcher_deploy.sh
    ./modpack_deploy.sh
    ./server_upload.sh -install
    ```


## gotchas

keep the spaces away, due to bash quoting and general insanity, it WILL BREAK
that means use `~/server/pack_name` instead of `~/server/pack name`


## what the scripts do

### Launcher Deploy `launcher_deploy.sh`

- builds launcher from source
- copies the 2 bootstrappers into the upload folder
- copies the compiled tools (creator-tools and launcher-builder) into the tools directory
- packs the 2 launchers into the upload folder and creates the latest json files
- trigger `upload.sh`

### Modpack Deploy `modpack_deploy.sh`

- if `tools/launcher-builder` does not exist
  - trigger `launcher_deploy.sh`
- for every `$modpack`
  - build `$modpack`
  - generate filetree of `$modpack` 
- generate `packages.json`
- trigger `upload.sh`

### Server Upload `server_upload.sh`

- for every `$modpack`
  - load modpack config
  - build server for `$modpack` (com.skcraft.launcher.builder.ServerCopyExport)
  - copy server/global into upload directory
  - copy server/`$modpack` into upload directory
  - copy update script into upload directory
  - upload to server (outside of the server run directory)
  - if `-update`
    - trigger `update.sh` on server

### Server Update `server_update.sh`

- for every `$modpack`
  - load modpack config
  - trigger `update.sh` on server