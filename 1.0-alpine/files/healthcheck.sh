#!/bin/sh

[ "$(redis-cli ping)" = "PONG" ] || exit 1
exit 0