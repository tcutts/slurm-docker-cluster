-- Queue mapping configuration
local queue_map = {
    ["core"] = {target = "long", exempt_users = {}, map_users = {}},
    ["gpu"] = {target = "long-gpu", exempt_users = {"gpuuser"}, map_users = {"user1", "user2"}},
}

-- Helper function to check if user is exempt
local function is_user_exempt(username, exempt_list)
    for _, exempt_user in ipairs(exempt_list) do
        if username == exempt_user then
            return true
        end
    end
    return false
end

-- Helper function to check if user should be mapped
local function should_map_user(username, map_users)
    -- If map_users is empty, map everyone
    if #map_users == 0 then
        return true
    end
    
    -- Otherwise, only map specified users
    for _, map_user in ipairs(map_users) do
        if username == map_user then
            return true
        end
    end
    return false
end

function slurm_job_submit(job_desc, part_list, submit_uid)
    local username = job_desc.user_name or "unknown"
    local source_partition = job_desc.partition
    
    if source_partition and queue_map[source_partition] then
        local mapping = queue_map[source_partition]
        
        if should_map_user(username, mapping.map_users) and not is_user_exempt(username, mapping.exempt_users) then
            job_desc.partition = mapping.target
            local comment = string.format("Remapped from %s to %s", source_partition, mapping.target)
            job_desc.comment = job_desc.comment and (job_desc.comment .. "; " .. comment) or comment
            slurm.log_info(string.format("job_submit_plugin: mapped partition '%s' to '%s' for user '%s'", 
                source_partition, mapping.target, username))
        else
            if not should_map_user(username, mapping.map_users) then
                slurm.log_info(string.format("job_submit_plugin: user '%s' not in map_users list for partition '%s'", 
                    username, source_partition))
            else
                slurm.log_info(string.format("job_submit_plugin: user '%s' is exempt from partition mapping for '%s'", 
                    username, source_partition))
            end
        end
    end
    
    return slurm.SUCCESS
end

function slurm_job_modify(job_desc, job_rec, part_list, modify_uid)
    return slurm.SUCCESS
end
