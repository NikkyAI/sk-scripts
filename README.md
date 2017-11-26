# voodoo-scripts

## setuo and getting started

1. install and set up voodoo-pack https://github.com/NikkyAI/voodoo-pack

2. symlink config and modpacks to your pack development environment \
   this is recommended to avoid loosing gitignored files

    ```bash
    dev=~/dev/voodoo-pack
    ln -s $dev/modpacks/ modpacks/
    ln -s $dev/config/ config/
    ln -s $(pwd)/tools $dev/tools
    ```

3. make sure your fork of sklauncher is ready \
   https://github.com/SKCraft/Launcher \
   at the moment the script expects a specific  \
   fork that adds more targets though \
   https://github.com/NikkyAI/Launcher

4. configure the scripts

    ```bash
    cp config.sample.sh config.sh
    ```

4. run

    ```bash
    ./deploy_launcher.sh
    ./deploy_modpack.sh
    ```