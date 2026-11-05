-- Queue core for ACS Mobile Batch Operations.
-- Game-specific actor orders and spell dispatch belong in an adapter and must
-- call the original game logic. No game API is assumed here.
local tbMod = GameMain:GetMod("ACS1MobileBatchOperations")
if tbMod == nil then
    tbMod = GameMain:NewMod("ACS1MobileBatchOperations")
end

local Queue = {}
Queue.__index = Queue

function Queue.New()
    return setmetatable({
        tasks = {},
        nextId = 1,
        paused = false,
        running = false,
        lastError = nil
    }, Queue)
end

function Queue:Enqueue(action, actorId, targetIds, repeats)
    if type(action) ~= "string" or action == "" then
        return false, "action is required"
    end
    if type(actorId) ~= "number" then
        return false, "actorId must be a number"
    end
    if type(targetIds) ~= "table" or #targetIds == 0 then
        return false, "at least one target is required"
    end

    local targets = {}
    for i = 1, #targetIds do
        if type(targetIds[i]) ~= "number" then
            return false, "target IDs must be numbers"
        end
        targets[i] = targetIds[i]
    end

    local task = {
        id = self.nextId,
        action = action,
        actorId = actorId,
        targets = targets,
        index = 1,
        repeats = math.max(1, math.floor(tonumber(repeats) or 1))
    }
    self.nextId = self.nextId + 1
    self.tasks[#self.tasks + 1] = task
    self.lastError = nil
    return true, task.id
end

function Queue:Cancel(taskId)
    for i = #self.tasks, 1, -1 do
        if self.tasks[i].id == taskId then
            table.remove(self.tasks, i)
            self.lastError = nil
            return true
        end
    end
    return false
end

function Queue:Clear()
    self.tasks = {}
    self.lastError = nil
end

function Queue:Pause()
    self.paused = true
end

function Queue:Resume()
    self.paused = false
end

function Queue:Count()
    return #self.tasks
end

function Queue:Step(executor)
    if self.paused or self.running or #self.tasks == 0 then
        return false
    end
    if type(executor) ~= "function" then
        self.lastError = "No game-action adapter is installed"
        return false, self.lastError
    end

    local task = self.tasks[1]
    local targetId = task.targets[task.index]
    self.running = true
    local ok, accepted, err = pcall(executor, task.action, task.actorId, targetId, task.repeats)
    self.running = false

    if not ok then
        self.lastError = tostring(accepted)
        return false, self.lastError
    end
    if accepted ~= true then
        self.lastError = tostring(err or "Action was not accepted")
        return false, self.lastError
    end

    self.lastError = nil
    task.index = task.index + 1
    if task.index > #task.targets then
        table.remove(self.tasks, 1)
    end
    return true
end

function Queue:OnGetSaveData()
    return {
        tasks = self.tasks,
        nextId = self.nextId,
        paused = self.paused
    }
end

function Queue:OnLoadData(data)
    data = data or {}
    self.tasks = type(data.tasks) == "table" and data.tasks or {}
    self.nextId = tonumber(data.nextId) or 1
    self.paused = data.paused == true
    self.running = false
    self.lastError = nil
end

tbMod.BatchQueue = Queue

function tbMod:OnInit()
    self.batchQueue = Queue.New()
end

function tbMod:OnGetSaveData()
    if self.batchQueue then
        return self.batchQueue:OnGetSaveData()
    end
    return {}
end

function tbMod:OnLoadData(data)
    if not self.batchQueue then
        self.batchQueue = Queue.New()
    end
    self.batchQueue:OnLoadData(data)
end
