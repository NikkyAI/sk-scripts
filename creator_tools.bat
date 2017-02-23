cd %~dp0

git -C Launcher pull || git clone https://github.com/NikkyAI/Launcher.git Launcher

cd Launcher
call gradlew.bat clean build

cd ..

java -jar Launcher\creator-tools\build\libs\creator-tools-2.0.2-SNAPSHOT-all.jar --help

java -jar Launcher\creator-tools\build\libs\creator-tools-2.0.2-SNAPSHOT-all.jar

