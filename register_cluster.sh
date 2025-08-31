#!/bin/bash
set -e

# Check if slurmctld container is running
if ! docker ps --format "table {{.Names}}" | grep -q "^slurmctld$"; then
    echo "Error: slurmctld container is not running. Please start the cluster first."
    exit 1
fi

docker exec slurmctld bash -c "/usr/bin/sacctmgr --immediate add cluster name=linux" && \
docker compose restart slurmdbd slurmctld
