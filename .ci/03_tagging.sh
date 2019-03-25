#!/bin/bash
set -e 

STARTMSG="[Tagging]"

[ -z "$1" ] && echo "$STARTMSG No parameter with the Docker registry URL. Exit now." && exit 1
[ "$1" == "true" ] && echo "$STARTMSG False first argument. Abort." && exit 1

REGISTRY_URL="$1"
if [[ "$2" == "true" ]]; then ENVIRONMENT="prod"; fi;

# change directory to the top level:
pushd ..

# Docker Repo e.g. dcso/misp-dockerized-proxy
[ -z "$(git remote get-url origin|grep git@)" ] || GIT_REPO="$(git remote get-url origin|sed 's,.*:,,'|sed 's,....$,,')"
[ -z "$(git remote get-url origin|grep http)" ] || GIT_REPO="$(git remote get-url origin|sed 's,.*github.com/,,'|sed 's,....$,,')"
[ -z "$GITLAB_HOST" ] || [ -z "$(echo "$GIT_REPO"|grep "$GITLAB_HOST")" ] ||  GIT_REPO="$(git remote get-url origin|sed 's,.*'${GITLAB_HOST}'/'${GITLAB_GROUP}'/,,'|sed 's,....$,,')"

# Set Container Name
CONTAINER_NAME="$(echo $GIT_REPO|cut -d / -f 2|tr '[:upper:]' '[:lower:]')"

# Show Images before tagging
echo  "$STARTMSG ### Show images before tagging:"
docker images

# Set Docker Repository
DOCKER_REPO="$REGISTRY_URL/$CONTAINER_NAME"
SOURCE_REPO="redis"

# Lookup to all build versions of the current docker container
ALL_BUILD_DOCKER_VERSIONS=$(docker images --format '{{.Repository}}={{.Tag}}'|grep $SOURCE_REPO |cut -d = -f 2)

# Tag Latest + Version Number
for i in $ALL_BUILD_DOCKER_VERSIONS
do
    VERSION=$(echo "$i"|cut -d: -f 2)                 # for example 1.0

     # if there is a dev tag skip it, because we mirror only production images from hub.docker.com
     [ -z "$(echo "$VERSION"|grep dev)" ] || continue

    # Remove '-dev' tag
    if [ "$ENVIRONMENT" == "prod" ]; then
        #
        #   If prod=true, ~ prodcution ready image
        #

        # Add custom Docker registry tag
        docker tag "$SOURCE_REPO:$i" "$DOCKER_REPO:$VERSION"

    else
        #
        #   Add '-dev' tag
        #   
    
        # Add custom Docker registry tag
        docker tag "$SOURCE_REPO:$i" "$DOCKER_REPO:$VERSION-dev"
    fi
done

echo  "$STARTMSG ### Show images after tagging:"
docker images | grep "$DOCKER_REPO"

echo "$STARTMSG $0 is finished."

