`git -C sktools pull || git clone https://github.com/NikkyAI/sktools.git sktools`

local testing and modpack editing:
- open creator-tools and open the folder `modpacks`
- edit the corresponding modpack `.conf` file
- run cfpecker

### TODO
- local file handling
- usng gradle to build mods from git ?
- improve maven handling (get version list and match to get latest)
- jitpack ?
- Launcher
    - improve file copying to read from config
    - extract zips