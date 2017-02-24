cd %~dp0

git -C cfpecker pull || git clone https://github.com/NikkyAI/cfpecker.git cfpecker

pip install cfpecker
py -3 cfpecker/bin/cfpecker


::pip install --force-reinstall cfpecker
::cfpecker