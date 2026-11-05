-- Touch-friendly batch command flow.
-- Choose an action, tap target items, then return to the cultivator and submit.
local tbMod = GameMain:GetMod("ACS1MobileBatchOperations")
if tbMod == nil then
    tbMod = GameMain:NewMod("ACS1MobileBatchOperations")
end

local BUTTON_CRAFT = "批量炼宝"
local BUTTON_YOU = "批量幽淬"
local BUTTON_LING = "批量灵淬"
local BUTTON_SUBMIT = "提交批量任务"
local BUTTON_CANCEL_CRAFT = "取消剩余炼宝"

local ACTIONS = {
    craft = { desc = "选择法宝胚子后逐件加入原版炼宝命令。" },
    you = { magic = "SoulCrystalYouPowerUp", crystal = "Item_SoulCrystalYou" },
    ling = { magic = "SoulCrystalLingPowerUp", crystal = "Item_SoulCrystalLing" }
}

local function buttonLua(method)
    return "GameMain:GetMod('ACS1MobileBatchOperations'):" .. method .. "(bind);"
end

local function removeButtons(thing)
    if thing == nil then return end
    thing:RemoveBtnData(BUTTON_CRAFT)
    thing:RemoveBtnData(BUTTON_YOU)
    thing:RemoveBtnData(BUTTON_LING)
    thing:RemoveBtnData(BUTTON_SUBMIT)
    thing:RemoveBtnData(BUTTON_CANCEL_CRAFT)
end

function tbMod:AddBatchButtons(npc)
    if npc == nil or not npc.IsValid or not npc.IsPlayerThing then return end
    if self.pendingCraft == nil then self.pendingCraft = {} end

    removeButtons(npc)
    if self.selection ~= nil and self.selection.actorId == npc.ID then
        npc:AddBtnData(BUTTON_SUBMIT, "res/Sprs/ui/icon_lingxi01",
            buttonLua("SubmitTargets"),
            "结束选取并提交已经选中的目标（" .. tostring(#self.selection.targets) .. "）。", nil)
    else
        npc:AddBtnData(BUTTON_CRAFT, "res/Sprs/ui/icon_lianbao01",
            buttonLua("StartCraftSelection"), ACTIONS.craft.desc, nil)
        npc:AddBtnData(BUTTON_YOU, "res/Sprs/ui/icon_youcui01",
            buttonLua("StartYouSelection"), "选择多个物品，逐个施展原版幽淬之法。", nil)
        npc:AddBtnData(BUTTON_LING, "res/Sprs/ui/icon_lingcui01",
            buttonLua("StartLingSelection"), "选择多个物品，逐个施展原版灵淬之法。", nil)
        local pending = self.pendingCraft[npc.ID]
        if pending ~= nil and #pending > 0 then
            npc:AddBtnData(BUTTON_CANCEL_CRAFT, "res/Sprs/ui/icon_lianbao01",
                buttonLua("CancelCraft"), "取消尚未开始的批量炼宝任务。", nil)
        end
    end
end

function tbMod:OnNpcSelected(evt, npc, objs)
    self:AddBatchButtons(npc)
end

function tbMod:StartCraftSelection(npc)
    self:BeginSelection(npc, "craft")
end

function tbMod:StartYouSelection(npc)
    self:BeginSelection(npc, "you")
end

function tbMod:StartLingSelection(npc)
    self:BeginSelection(npc, "ling")
end

function tbMod:BeginSelection(npc, action)
    if npc == nil or not npc.IsValid or not npc.IsPlayerThing then return end
    self.selection = { actorId = npc.ID, action = action, targets = {}, seen = {} }
    self:AddBatchButtons(npc)
    world:ShowStoryBox("现在逐个点选要处理的物品。选完后重新点选施法角色，再点“提交批量任务”。",
        "批量操作", {"知道了"})
end

function tbMod:OnItemSelected(evt, item, objs)
    local selection = self.selection
    if selection == nil or item == nil or not item.IsValid then return end
    if item.ThingType ~= CS.XiaWorld.g_emThingType.Item then return end
    if item.FreeCount == nil or item.FreeCount <= 0 then return end
    if not item.AtG or item.InWhoseBag > 0 or item.InWhoseHand > 0 then return end
    if selection.seen[item.ID] then return end

    selection.seen[item.ID] = true
    selection.targets[#selection.targets + 1] = item.ID
end

function tbMod:SubmitTargets(npc)
    local selection = self.selection
    if selection == nil or npc == nil or npc.ID ~= selection.actorId then return end
    self.selection = nil

    if selection.action == "craft" then
        if self.pendingCraft == nil then self.pendingCraft = {} end
        local pending = self.pendingCraft[npc.ID] or {}
        for i = 1, #selection.targets do
            pending[#pending + 1] = selection.targets[i]
        end
        self.pendingCraft[npc.ID] = pending
        self:AddBatchButtons(npc)
        world:ShowStoryBox(string.format("已排入 %d 个炼宝目标。角色会按顺序使用原版炼宝命令。", #selection.targets),
            "批量操作", {"知道了"})
        return
    end

    local accepted, skipped = 0, 0
    for i = 1, #selection.targets do
        local item = CS.XiaWorld.ThingMgr.Instance:FindThingByID(selection.targets[i])
        if self:QueueRefinementCommand(npc, item, selection.action) then
            accepted = accepted + 1
        else
            skipped = skipped + 1
        end
    end

    self:AddBatchButtons(npc)
    world:ShowStoryBox(string.format("已加入 %d 个原版神通命令；跳过 %d 个无效或缺少灵珀/幽珀的目标。",
        accepted, skipped), "批量操作", {"知道了"})
end

function tbMod:QueueCraftCommand(npc, item)
    if item == nil or not item.IsValid or item.FreeCount <= 0 or
        not item.AtG or item.InWhoseBag > 0 or item.InWhoseHand > 0 then
        return false
    end
    if npc:CheckCommandSingle("RefiningFabao", false) ~= nil then
        return false
    end
    if npc.LingV < item.Rate * item.Rate * 500 then
        return false
    end

    local command = npc:AddCommand("RefiningFabao",
        CS.XiaWorld.g_emItemLable.FightFabao,
        item, CS.XLua.Cast.Int32(0))
    return command ~= nil
end

function tbMod:QueueRefinementCommand(npc, item, action)
    local actionDef = ACTIONS[action]
    if actionDef == nil or item == nil or not item.IsValid or item.FreeCount <= 0 then
        return false
    end
    if not npc.PropertyMgr.Practice.Magics:Contains(actionDef.magic) then
        return false
    end

    local magicDef = CS.XiaWorld.PracticeMgr.Instance:GetMagicDef(actionDef.magic)
    if magicDef == nil or magicDef.CMD == nil then return false end

    -- The vanilla command is normally single-instance. Allow one command per
    -- selected target; each command still runs through the game's own handler.
    local commandDef = CS.XiaWorld.CommandMgr.Instance:GetDef(magicDef.CMD)
    if commandDef ~= nil then commandDef.Single = 0 end

    local map = CS.XiaWorld.World.Instance.map
    local crystal = map.Things:FindItem(nil, 9999, actionDef.crystal, 0,
        false, nil, 0, 9999, nil, false)
    if crystal == nil or crystal.FreeCount <= 0 then return false end

    local command = npc:AddCommand(magicDef.CMD, item)
    if command == nil then return false end

    crystal.Lock:Lock(command, 1)
    command.WorkParam2 = CS.XLua.Cast.Int32(crystal.ID)
    command.WorkParam3 = magicDef.Name
    return true
end

function tbMod:CancelCraft(npc)
    if npc == nil or self.pendingCraft == nil then return end
    self.pendingCraft[npc.ID] = nil
    self:AddBatchButtons(npc)
end

function tbMod:OnStep(dt)
    if self.pendingCraft == nil then return end
    for npcId, targets in pairs(self.pendingCraft) do
        local npc = CS.XiaWorld.ThingMgr.Instance:FindThingByID(npcId)
        if npc == nil or not npc.IsValid then
            self.pendingCraft[npcId] = nil
        elseif #targets == 0 then
            self.pendingCraft[npcId] = nil
        elseif npc:CheckCommandSingle("RefiningFabao", false) == nil then
            local item = CS.XiaWorld.ThingMgr.Instance:FindThingByID(targets[1])
            if item == nil or not item.IsValid or item.FreeCount <= 0 or
                not item.AtG or item.InWhoseBag > 0 or item.InWhoseHand > 0 then
                table.remove(targets, 1)
            elseif npc.LingV >= item.Rate * item.Rate * 500 then
                if self:QueueCraftCommand(npc, item) then
                    table.remove(targets, 1)
                end
            end
        end
    end
end

function tbMod:OnEnter()
    self.selection = nil
    if self.pendingCraft == nil then self.pendingCraft = {} end
    local Event = GameMain:GetMod("_Event")
    local g_emEvent = CS.XiaWorld.g_emEvent
    Event:RegisterEvent(g_emEvent.SelectNpc, function(evt, npc, objs)
        self:OnNpcSelected(evt, npc, objs)
    end, "ACS1MobileBatchOperations_AddButtons")
    Event:RegisterEvent(g_emEvent.SelectItem, function(evt, item, objs)
        self:OnItemSelected(evt, item, objs)
    end, "ACS1MobileBatchOperations_CollectTargets")
end

function tbMod:OnLeave()
    local Event = GameMain:GetMod("_Event")
    local g_emEvent = CS.XiaWorld.g_emEvent
    Event:UnRegisterEvent(g_emEvent.SelectNpc, "ACS1MobileBatchOperations_AddButtons")
    Event:UnRegisterEvent(g_emEvent.SelectItem, "ACS1MobileBatchOperations_CollectTargets")
    self.selection = nil
end

function tbMod:OnSave()
    return { pendingCraft = self.pendingCraft or {} }
end

function tbMod:OnLoad(data)
    data = data or {}
    self.pendingCraft = data.pendingCraft or {}
end
