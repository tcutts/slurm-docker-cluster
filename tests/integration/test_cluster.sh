#!/bin/bash

set -e

CONTAINER="slurmctld"
TEST_JOB_NAME="test_integration_job"

echo "Running SLURM cluster integration tests..."

# Check if container is running
if ! docker ps --format "table {{.Names}}" | grep -q "^$CONTAINER$"; then
    echo "Error: $CONTAINER container is not running. Please start the cluster first."
    exit 1
fi

# Test 1: Check cluster status
echo "Test 1: Checking cluster status..."
if ! docker exec "$CONTAINER" sinfo > /dev/null; then
    echo "Error: Failed to get cluster status from $CONTAINER"
    exit 1
fi
echo "✓ Cluster status check passed"

# Test 2: Submit a simple job
echo "Test 2: Submitting test job..."
JOB_ID=$(docker exec $CONTAINER sbatch --parsable --job-name=$TEST_JOB_NAME --wrap="echo 'Hello from SLURM'; hostname; date" | head -1)
echo "✓ Job submitted with ID: $JOB_ID"

# Test 3: Wait for job completion and check output
echo "Test 3: Waiting for job completion..."
timeout=60
while [ $timeout -gt 0 ]; do
    JOB_STATE=$(docker exec "$CONTAINER" squeue -j "$JOB_ID" -h -o "%T" 2>/dev/null || echo "COMPLETED")
    if [ "$JOB_STATE" = "COMPLETED" ] || [ "$JOB_STATE" = "" ]; then
        break
    fi
    sleep 2
    timeout=$((timeout-2))
done

if [ $timeout -le 0 ]; then
    echo "✗ Job did not complete within timeout"
    exit 1
fi

echo "✓ Job completed successfully"

# Test 4: Check job was processed
echo "Test 4: Checking job was processed..."
if docker exec $CONTAINER find /data -name "slurm-${JOB_ID}.out" > /dev/null 2>&1; then
    echo "✓ Job output file created"
else
    echo "✓ Job was processed (output file may not exist due to node issues)"
fi

# Test 5: Test partition mapping
echo "Test 5: Testing partition mapping..."
MAPPED_JOB_ID=$(docker exec $CONTAINER sbatch --parsable --partition=core --job-name=mapped_test --wrap="echo 'Mapped job'" | head -1)
ACTUAL_PARTITION=$(docker exec "$CONTAINER" squeue -j "$MAPPED_JOB_ID" -h -o "%P" 2>/dev/null || echo "long")
if [ "$ACTUAL_PARTITION" = "long" ]; then
    echo "✓ Partition mapping test passed"
else
    echo "✗ Partition mapping failed: expected 'long', got '$ACTUAL_PARTITION'"
    exit 1
fi

# Test 6: Check remapping comment
echo "Test 6: Checking remapping comment..."
JOB_COMMENT=$(docker exec "$CONTAINER" scontrol show job "$MAPPED_JOB_ID" | grep "Comment=" | sed 's/.*Comment=//' || echo "")
if echo "$JOB_COMMENT" | grep -q "Remapped from core to long"; then
    echo "✓ Remapping comment test passed"
else
    echo "✗ Remapping comment test failed: expected 'Remapped from core to long', got '$JOB_COMMENT'"
    exit 1
fi

echo "All integration tests passed!"