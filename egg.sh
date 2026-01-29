#!/bin/bash

FILE=eula.txt

function display {
    echo -e "\033c"
    echo "
$(tput setaf 6)██╗░░██╗░█████╗░██╗░░░░░██╗██╗░░██╗
$(tput setaf 6)██║░░██║██╔══██╗██║░░░░░██║╚██╗██╔╝
$(tput setaf 6)███████║███████║██║░░░░░██║░╚███╔╝░
$(tput setaf 6)██╔══██║██╔══██║██║░░░░░██║░██╔██╗░
$(tput setaf 6)██║░░██║██║░░██║███████╗██║██╔╝╚██╗
$(tput setaf 6)╚═╝░░╚═╝╚═╝░░╚═╝╚══════╝╚═╝╚═╝░░╚═╝

"
}

function forceStuffs {
  echo "motd=Powered by 
HalixCloud | Change this motd in server.properties" >> server.properties
}

function optimizeJavaServer {
  echo "view-distance=6" >> server.properties
}

function launchJavaServer {
  java -Xms1024M -Xmx1024M \
  -XX:+UseG1GC \
  -XX:+ParallelRefProcEnabled \
  -XX:MaxGCPauseMillis=200 \
  -XX:+UnlockExperimentalVMOptions \
  -XX:+DisableExplicitGC \
  -XX:G1NewSizePercent=30 \
  -XX:G1MaxNewSizePercent=40 \
  -XX:G1HeapRegionSize=8M \
  -XX:G1ReservePercent=20 \
  -XX:G1HeapWastePercent=5 \
  -XX:G1MixedGCCountTarget=4 \
  -XX:InitiatingHeapOccupancyPercent=15 \
  -XX:G1MixedGCLiveThresholdPercent=90 \
  -XX:G1RSetUpdatingPauseTimePercent=5 \
  -XX:SurvivorRatio=32 \
  -XX:+PerfDisableSharedMem \
  -XX:MaxTenuringThreshold=1 \
  -Dusing.aikars.flags=https://mcflags.emc.gs \
  -Daikars.new.flags=true \
  -jar paper-server.jar nogui
}

if [ ! -f "$FILE" ]; then
  mkdir -p plugins
  display

echo "
$(tput setaf 3)Select Minecraft Version (Paper)

1)  1.8.8
2)  1.12.2
3)  1.15.2
4)  1.16.5
5)  1.17.1
6)  1.18.2
7)  1.19.2
8)  1.19.4
9)  1.20.1
10) 1.20.4
11) 1.21
12) 1.21.1
13) 1.21.2
14) 1.21.3
"

read -r n

case $n in
  1) curl -O https://api.papermc.io/v2/projects/paper/versions/1.8.8/builds/445/downloads/paper-1.8.8-445.jar ;;
  2) curl -O https://api.papermc.io/v2/projects/paper/versions/1.12.2/builds/1620/downloads/paper-1.12.2-1620.jar ;;
  3) curl -O https://api.papermc.io/v2/projects/paper/versions/1.15.2/builds/393/downloads/paper-1.15.2-393.jar ;;
  4) curl -O https://api.papermc.io/v2/projects/paper/versions/1.16.5/builds/794/downloads/paper-1.16.5-794.jar ;;
  5) curl -O https://api.papermc.io/v2/projects/paper/versions/1.17.1/builds/411/downloads/paper-1.17.1-411.jar ;;
  6) curl -O https://api.papermc.io/v2/projects/paper/versions/1.18.2/builds/388/downloads/paper-1.18.2-388.jar ;;
  7) curl -O https://api.papermc.io/v2/projects/paper/versions/1.19.2/builds/190/downloads/paper-1.19.2-190.jar ;;
  8) curl -O https://api.papermc.io/v2/projects/paper/versions/1.19.4/builds/550/downloads/paper-1.19.4-550.jar ;;
  9) curl -O https://api.papermc.io/v2/projects/paper/versions/1.20.1/builds/196/downloads/paper-1.20.1-196.jar ;;
 10) curl -O https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/497/downloads/paper-1.20.4-497.jar ;;
 11) curl -O https://api.papermc.io/v2/projects/paper/versions/1.21/builds/82/downloads/paper-1.21-82.jar ;;
 12) curl -O https://api.papermc.io/v2/projects/paper/versions/1.21.1/builds/31/downloads/paper-1.21.1-31.jar ;;
 13) curl -O https://api.papermc.io/v2/projects/paper/versions/1.21.2/builds/15/downloads/paper-1.21.2-15.jar ;;
 14) curl -O https://api.papermc.io/v2/projects/paper/versions/1.21.3/builds/8/downloads/paper-1.21.3-8.jar ;;
  *) echo "Invalid option"; exit ;;
esac

mv paper-*.jar paper-server.jar
forceStuffs
optimizeJavaServer
display
launchJavaServer

else
  display
  launchJavaServer
fi
