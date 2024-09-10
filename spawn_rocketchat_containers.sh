#!/bin/env bash

echo creating rocketchat pod
podman pod create --name rocket -p 127.0.0.1:3000:3000 -p 127.0.0.1:27017:27017 -p 8443:443

echo creating mongodb container
podman run -d --pod rocket --rm --name mongodb --user mongod:mongod --env 'MONGODB_CONFIG_OVERRIDE_NOFORK=1' -v /opt/pod/rocket/var/lib/mongo:/var/lib/mongo:Z -v /opt/pod/rocket/var/log/mongodb:/var/log/mongodb:Z localhost/mongodb:latest /usr/bin/mongod -f /etc/mongod.conf
sleep 3
podman exec -it mongodb /bin/mongosh --eval "printjson(rs.initiate())"

echo creating rocketchat container
podman run -d --pod rocket --rm --name rocketchat --user rocketchat:rocketchat --env 'MONGO_URL=mongodb://localhost:27017/rocketchat?replicaSet=rs01' --env 'MONGO_OPLOG_URL=mongodb://localhost:27017/local?replicaSet=rs01' --env 'ROOT_URL=http://localhost/' --env 'PORT=3000' -v /opt/pod/rocket/opt/rocketupload:/opt/rocketupload:Z localhost/rocketchat:latest /opt/rocketchat/.nvm/versions/node/v14.21.3/bin/node /opt/rocketchat/main.js

echo creating nginx container
podman run -d --pod rocket --rm --name nginx localhost/nginx:latest /usr/sbin/nginx -g 'daemon off;'
