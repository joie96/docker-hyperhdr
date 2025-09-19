#!/bin/bash
echo "---Ensuring UID: ${UID} matches user---"
usermod -u ${UID} ${USER}
echo "---Ensuring GID: ${GID} matches user---"
groupmod -g ${GID} ${USER} > /dev/null 2>&1 ||:
usermod -g ${GID} ${USER}
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Adding user to groups: video and spidev---"
create_or_modify_group() {
    local group_name=$1
    local gid=$2
    
    # Wenn die Gruppe nicht existiert, erstelle sie
    if ! getent group "$group_name" > /dev/null; then
        echo "---Creating group $group_name with GID $gid---"
        groupadd -g "$gid" "$group_name"
    else
        # Wenn die Gruppe bereits existiert, ändere die GID
        echo "---Modifying group $group_name to GID $gid---"
        groupmod -g "$gid" "$group_name"
    fi
}
# Gruppen erstellen oder modifizieren
create_or_modify_group "video" ${GID_VIDEO}
create_or_modify_group "spidev" ${GID_SPIDEV}

# Benutzer zur Gruppe hinzufügen
usermod -aG video ${USER}
usermod -aG spidev ${USER}


echo "---Checking for optional scripts---"
cp -f /opt/custom/user.sh /opt/scripts/start-user.sh > /dev/null 2>&1 ||:
cp -f /opt/scripts/user.sh /opt/scripts/start-user.sh > /dev/null 2>&1 ||:

if [ -f /opt/scripts/start-user.sh ]; then
  echo "---Found optional script, executing---"
  chmod -f +x /opt/scripts/start-user.sh ||:
  /opt/scripts/start-user.sh || echo "---Optional Script has thrown an Error---"
else
  echo "---No optional script found, continuing---"
fi

echo "---Taking ownership of data...---"
chown -R root:${GID} /opt/scripts
chmod -R 750 /opt/scripts
chown -R ${UID}:${GID} ${DATA_DIR}

echo "---Starting...---"
term_handler() {
  kill -SIGTERM "$killpid"
  wait "$killpid" -f 2>/dev/null
  exit 143;
}

trap 'kill ${!}; term_handler' SIGTERM
su ${USER} -c "/opt/scripts/start-server.sh" &
killpid="$!"
while true
do
  wait $killpid
  exit 0;
done