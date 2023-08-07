#!/bin/bash

docker pull sonatype/nexus3
docker volume create --name nexus-data
docker run -d -p 8081:8081 -p 8082:8082 -p 8443:8443 --name nexus -v nexus-data:/nexus-data sonatype/nexus3

while ! test -f "/var/lib/docker/volumes/nexus-data/admin.password"; do
  sleep 10
  echo "Waiting for Nexus to start up"
done

echo "temporary admin password:"
cat /var/lib/docker/volumes/nexus-data/admin.password