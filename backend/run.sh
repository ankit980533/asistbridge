#!/bin/bash

# Start MongoDB if not running
if ! docker ps | grep -q assistbridge-mongodb; then
    echo "Starting MongoDB..."
    docker start assistbridge-mongodb 2>/dev/null || \
    docker run -d -p 27017:27017 --name assistbridge-mongodb mongo:7
fi

echo "Starting backend..."
mvn spring-boot:run
