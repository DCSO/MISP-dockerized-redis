#!/bin/sh

STARTMSG="[BUILD]"

[ -z "$1" ] && echo "$STARTMSG No parameter with the version. Exit now." && exit 1
VERSION="$1"

docker pull "library/redis:$VERSION"
