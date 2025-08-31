#!/usr/bin/env lua

-- Mock slurm module
slurm = {
    SUCCESS = 0,
    log_info = function(msg) print("LOG: " .. msg) end
}

-- Load the plugin
dofile("../../etc/job_submit.lua")

-- Test cases
local function test_core_partition_mapping()
    local job_desc = {partition = "core", user_name = "testuser"}
    local result = slurm_job_submit(job_desc, {}, 1000)
    
    assert(job_desc.partition == "long", "Core partition should map to long")
    assert(result == slurm.SUCCESS, "Function should return SUCCESS")
    print("✓ Core partition mapping test passed")
end

local function test_exempt_user()
    local job_desc = {partition = "gpu", user_name = "gpuuser"}
    local result = slurm_job_submit(job_desc, {}, 1000)
    
    assert(job_desc.partition == "gpu", "Exempt user should keep original partition")
    assert(result == slurm.SUCCESS, "Function should return SUCCESS")
    print("✓ Exempt user test passed")
end

local function test_unmapped_partition()
    local job_desc = {partition = "unmapped", user_name = "testuser"}
    local result = slurm_job_submit(job_desc, {}, 1000)
    
    assert(job_desc.partition == "unmapped", "Unmapped partition should remain unchanged")
    assert(result == slurm.SUCCESS, "Function should return SUCCESS")
    print("✓ Unmapped partition test passed")
end

local function test_user_specific_mapping()
    local job_desc = {partition = "gpu", user_name = "user1"}
    local result = slurm_job_submit(job_desc, {}, 1000)
    
    assert(job_desc.partition == "long", "User1 should be mapped from gpu to long")
    assert(result == slurm.SUCCESS, "Function should return SUCCESS")
    print("✓ User-specific mapping test passed")
end

local function test_user_not_in_map_list()
    local job_desc = {partition = "gpu", user_name = "user3"}
    local result = slurm_job_submit(job_desc, {}, 1000)
    
    assert(job_desc.partition == "gpu", "User3 not in map_users should keep original partition")
    assert(result == slurm.SUCCESS, "Function should return SUCCESS")
    print("✓ User not in map list test passed")
end

local function test_empty_map_users_maps_everyone()
    local job_desc = {partition = "core", user_name = "anyuser"}
    local result = slurm_job_submit(job_desc, {}, 1000)
    
    assert(job_desc.partition == "long", "Empty map_users should map everyone")
    assert(result == slurm.SUCCESS, "Function should return SUCCESS")
    print("✓ Empty map_users maps everyone test passed")
end

-- Run tests
print("Running Lua plugin unit tests...")
test_core_partition_mapping()
test_exempt_user()
test_unmapped_partition()
test_user_specific_mapping()
test_user_not_in_map_list()
test_empty_map_users_maps_everyone()
print("All unit tests passed!")
