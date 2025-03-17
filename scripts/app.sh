#!/bin/bash
docker-compose down
echo "******************** lancement *****************"
docker-compose up -d
echo "********************success docker keycloak******************"
