#!/usr/bin/env lua

-- Mock slurm module for benchmarking
slurm = {
    SUCCESS = 0,
    log_info = function(msg) end  -- Silent for benchmarking
}

-- Load the plugin
dofile("../../etc/job_submit.lua")

-- Benchmark function
local function benchmark_plugin(iterations)
    local test_cases = {
        {name = "core_mapping", job_desc = {partition = "core", user_name = "testuser"}},
        {name = "gpu_exempt", job_desc = {partition = "gpu", user_name = "gpuuser"}},
        {name = "gpu_mapped", job_desc = {partition = "gpu", user_name = "user1"}},
        {name = "unmapped", job_desc = {partition = "normal", user_name = "testuser"}}
    }
    
    print("Plugin Microbenchmark")
    print("====================")
    print(string.format("Running %d iterations per test case", iterations))
    print("")
    
    for _, test_case in ipairs(test_cases) do
        local start_time = os.clock()
        
        for i = 1, iterations do
            local job_desc = {}
            for k, v in pairs(test_case.job_desc) do
                job_desc[k] = v
            end
            slurm_job_submit(job_desc, {}, 1000)
        end
        
        local end_time = os.clock()
        local duration = end_time - start_time
        local ops_per_sec = iterations / duration
        
        print(string.format("%s: %.4fs total, %.0f ops/sec", 
            test_case.name, duration, ops_per_sec))
    end
end

-- Run benchmark
local iterations = tonumber(arg and arg[1]) or 10000
benchmark_plugin(iterations)