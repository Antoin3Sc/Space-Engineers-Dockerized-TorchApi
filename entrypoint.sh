#!/bin/bash
# VARIABLES
GAME_DIR="/appdata/space-engineers/SpaceEngineersDedicated"
INSTANCES_DIR="/appdata/space-engineers/instances"
PLUGIN_DIR="/appdata/space-engineers/plugins"
CONFIG_PATH="${INSTANCES_DIR}/${INSTANCE_NAME}/SpaceEngineers-Dedicated.cfg"
INSTANCE_IP=$(hostname -I | sed "s= ==g")

TORCH_DIR="/appdata/space-engineers/Torch"
# Ensure Torch can find the DedicatedServer64 next to itself as expected
# Torch looks for Z:\\appdata\\space-engineers\\Torch\\DedicatedServer64\\steam_api64.dll
# Create a symlink if it does not exist
if [ ! -e "${TORCH_DIR}/DedicatedServer64" ]; then
  ln -s "${GAME_DIR}/DedicatedServer64" "${TORCH_DIR}/DedicatedServer64"
fi


echo "-------------------------------INSTALL & UPDATE------------------------------"
/usr/games/steamcmd +force_install_dir ${GAME_DIR} +login anonymous +@sSteamCmdForcePlatformType windows +app_update 298740 validate +quit

echo "---------------------------------UPDATE CONFIG-------------------------------"
# update IP to host external ip
CURRENT_IP=$(grep -oEi '<IP>(.*)</IP>' ${CONFIG_PATH} | sed -E "s=<IP>|</IP>==g")
sed -i "s=<IP>.*</IP>=<IP>${INSTANCE_IP}</IP>=g" ${CONFIG_PATH}

# update world save path
CURRENT_WORLDNAME=$(grep -oEi '<WorldName>(.*)</WorldName>' ${CONFIG_PATH} | sed -E "s=<WorldName>|</WorldName>==g")
SAVE_PATH="Z:\\\\appdata\\\\space-engineers\\\\instances\\\\${INSTANCE_NAME}\\\\Saves\\\\${CURRENT_WORLDNAME}";
sed -E -i "s=<LoadWorld />|<LoadWorld.*LoadWorld>=<LoadWorld>${SAVE_PATH}</LoadWorld>=g" ${CONFIG_PATH}

echo "---------------------------------UPDATE PLUGINS------------------------------"
PLUGIN_COUNT=$(ls -1 ${PLUGIN_DIR}/*.dll | wc -l)
echo "Found ${PLUGIN_COUNT} plugins in ${PLUGIN_DIR}"

if [ "${PLUGIN_COUNT}" -gt "0" ]; then 
  PLUGINS_STRING="<Plugins>$(ls -1 /appdata/space-engineers/plugins/*.dll |\
  sed -E "s=(.+\.dll)=<string>\1</string>=g" |\
  tr -d "\n" )</Plugins>"
else
  PLUGINS_STRING="<Plugins />"
fi

sed -E -i "s=<Plugins />|<Plugins.*Plugins>=${PLUGINS_STRING}=g" ${CONFIG_PATH}

echo "-----------------------------CURRENT CONFIGURATION---------------------------"
echo "GAME_DIR=$GAME_DIR"
echo "CONFIG_PATH=$CONFIG_PATH"
echo "INSTANCE_IP=$INSTANCE_IP"
echo "CURRENT_IP=$CURRENT_IP"
echo "CURRENT_WORLDNAME=$CURRENT_WORLDNAME"
echo "SAVE_PATH=$SAVE_PATH"
## END UPDATES ##
wine --version
echo "----------------------------------START GAME---------------------------------"






# Ensure Torch sees game directories where it expects them
TORCH_DIR="/appdata/space-engineers/Torch"
if [ ! -e "${TORCH_DIR}/DedicatedServer64" ]; then
  ln -s "${GAME_DIR}/DedicatedServer64" "${TORCH_DIR}/DedicatedServer64"
fi
if [ ! -e "${TORCH_DIR}/Content" ]; then
  ln -s "${GAME_DIR}/Content" "${TORCH_DIR}/Content"
fi





# mkdir first to fix possible no such file or directory on rm
mkdir -p ${INSTANCES_DIR}/${INSTANCE_NAME}
cd ${GAME_DIR}/DedicatedServer64/
xvfb-run -a wine64 Z:\\appdata\\space-engineers\\Torch\\Torch.Server.exe -autostart 
echo "-----------------------------------END GAME----------------------------------"
sleep 1
echo "-----------------------------------BYE !!!!----------------------------------"
