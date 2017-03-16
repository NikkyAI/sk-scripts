#!/usr/bin/env bash
until java -jar forge.jar; do
    echo "Server 'java -jar forge.jar' crashed with exit code $?.  Respawning.." >&2
    sleep 1
done