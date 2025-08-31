#!/usr/bin/env bash

set -e

restart=false

for var in "$@"
do
    cp $var persistent/etc_slurm
    if [ "$var" = "slurmdbd.conf" ] || [ "$var" = "slurm.conf" ]
    then
        restart=true
    fi
done
if $restart; then docker-compose restart; fi
