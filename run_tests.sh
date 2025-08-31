#!/bin/bash

set -e

echo "SLURM Docker Cluster Test Suite"
echo "==============================="

# Run unit tests
echo "Running unit tests..."
cd tests/unit
lua test_job_submit_plugin.lua
cd ../..

echo ""

# Run integration tests
echo "Running integration tests..."
cd tests/integration
chmod +x test_cluster.sh
./test_cluster.sh
cd ../..

echo ""
echo "All tests completed successfully!"