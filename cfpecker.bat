cd %~dp0

git -C cfpecker pull || git clone https://github.com/NikkyAI/cfpecker.git cfpecker

py -3 cfpecker/bin/cfpecker.py

:: TODO make local files work and avoid this copying

cd modpacks\test_pack
robocopy local src\mods /s /e
