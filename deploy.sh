#!/bin/bash

set -e

echo "Deploying SLURM configuration and plugins..."

# Copy configuration files to persistent directory
cp slurm.conf persistent/etc_slurm/
cp slurmdbd.conf persistent/etc_slurm/
cp cgroup.conf persistent/etc_slurm/
cp plugins/job_submit.lua persistent/etc_slurm/

echo "Configuration files copied to persistent directory"

# Restart containers to apply changes
docker compose restart

echo "Containers restarted successfully"
echo "Deployment complete!"