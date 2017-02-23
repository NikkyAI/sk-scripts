cd %~dp0

git -C cfpecker pull || git clone https://github.com/NikkyAI/cfpecker.git cfpecker

py -3 cfpecker/bin/cfpecker.py

