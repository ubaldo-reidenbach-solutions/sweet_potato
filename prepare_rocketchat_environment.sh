#!/bin/env bash

echo creating local datastore
sudo mkdir -p /opt/pod/rocket/opt/rocketupload /opt/pod/rocket/var/lib/mongo /opt/pod/rocket/var/log/mongodb
sudo chown -R "$(id -u $(whoami)):$(id -g $(whoami))" /opt/pod/rocket

echo building images
podman build -t rocky9 rocky9
podman build -t mongodb mongodb
podman build -t rocketchat rocketchat
podman build -t nginx nginx

echo setting datastore permissions
mongo_id=$(podman run -t --rm localhost/mongodb:latest grep mongod /etc/passwd)
mongo_uid=$(echo $mongo_id | cut -d ":" -f 3)
mongo_gid=$(echo $mongo_id | cut -d ":" -f 4)
podman unshare chown "$mongo_uid:$mongo_gid" /opt/pod/rocket/var/lib/mongo
podman unshare chown "$mongo_uid:$mongo_gid" /opt/pod/rocket/var/log/mongodb
rocket_id=$(podman run -t --rm localhost/rocketchat:latest grep rocketchat /etc/passwd)
rocket_uid=$(echo $rocket_id | cut -d ":" -f 3)
rocket_gid=$(echo $rocket_id | cut -d ":" -f 4)
podman unshare chown "$rocket_uid:$rocket_gid" /opt/pod/rocket/opt/rocketupload
