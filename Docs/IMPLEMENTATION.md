# 移动版实现记录

## 已实现的流程

角色面板上提供批量炼宝、批量幽淬、批量灵淬入口。点选一个入口后，玩家逐个点目标物品，再回到该角色面板提交。

- 炼宝目标进入角色专属待办队列。只有当角色没有正在执行的炼宝命令，且灵气达到物品品阶对应的原版门槛时，才加入下一条原版命令。
- 幽淬和灵淬分别使用游戏中原有的神通定义与命令类型。每个命令锁定一颗对应的幽珀或灵珀；成功率与处理结果交由原版命令逻辑。
- 尚未开始的炼宝任务可取消；已派发的原版命令继续由游戏处理。

## API 与实现依据

官方移动版 Mod 示例展示了 Lua 模块、OnEnter/OnStep/OnSave/OnLoad 回调、神通脚本以及目标 ID 列表。官方 API 文档归档在 [acs1_mods/Docs](https://github.com/GSQStudio/acs1_mods/tree/master/Docs)。

原版批量操作的公开实现使用以下炼宝调用：

```lua
npc:AddCommand("RefiningFabao", g_emItemLable.FightFabao, item, XLua.Cast.Int32(0))
```

幽淬的原版命令通过物品目标、神通定义 CMD、命令参数和幽珀锁定派发。移动版原型沿用游戏命令机制，增加灵淬时按其原版命令与灵珀执行。

参考源码：[Amazing-Mods/MultiOperationHelper](https://github.com/XuJunxu/Amazing-Mods/blob/fbb3b2ac6921b4b226fa9266cfda90b82c63fc97/MultiOperationHelper/Scripts/MultiOperationHelper.lua)。

## 手机界面

入口通过官方 API 的物品/NPC按钮数据放入角色面板。触屏流程不要求长按快捷键：点一个批量操作按钮，逐个点选目标，再回到角色面板提交。

## 验证状态与剩余工作

- 已按官方公开 API 和既有批量操作源码实现命令调用。
- 尚未在目标手游设备实机验证面板按钮、事件触发、灵珀派发及存档恢复。
- 本预览版用于实际功能试用；若按钮或命令行为与目标手游版本不符，需要根据游戏日志修正。
