cd %~dp0

py -3 cfpecker/bin/cfpecker.py

cd modpacks\test_pack
robocopy local src\mods /s /e
