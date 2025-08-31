-- Queue mapping configuration
local queue_map = {
    ["core"] = {target = "long", exempt_users = {}},
    ["gpu"] = {target = "long", exempt_users = {"gpuuser"}},
    ["short"] = {target = "long", exempt_users = {}}
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

function slurm_job_submit(job_desc, part_list, submit_uid)
    local username = job_desc.user_name or "unknown"
    local source_partition = job_desc.partition
    
    if source_partition and queue_map[source_partition] then
        local mapping = queue_map[source_partition]
        
        if not is_user_exempt(username, mapping.exempt_users) then
            job_desc.partition = mapping.target
            local comment = string.format("Remapped from %s to %s", source_partition, mapping.target)
            job_desc.comment = job_desc.comment and (job_desc.comment .. "; " .. comment) or comment
            slurm.log_info(string.format("job_submit_plugin: mapped partition '%s' to '%s' for user '%s'", 
                source_partition, mapping.target, username))
        else
            slurm.log_info(string.format("job_submit_plugin: user '%s' is exempt from partition mapping for '%s'", 
                username, source_partition))
        end
    end
    
    return slurm.SUCCESS
end

function slurm_job_modify(job_desc, job_rec, part_list, modify_uid)
    return slurm.SUCCESS
end