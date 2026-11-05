# ACS Mobile Batch Operations

《了不起的修仙模拟器》移动版批量操作 Mod 原型。

## 目标功能

- 批量炼制法宝：给选定角色排入多个炼宝目标，显示队列并允许取消尚未开始的任务。
- 批量幽淬、灵淬：选择多个目标物品并逐个施法，保留游戏原有消耗、成功率和失败结果。
- 触屏优先：使用游戏内触屏界面，不依赖 PC 的 Ctrl/Shift 快捷键。

## 当前状态

已提交 Lua 队列核心，支持排队、取消、暂停、继续和存档恢复，并预留游戏动作适配器入口。当前还没有接入炼宝或神通的真实游戏 API，也没有触屏界面；因此这是开发原型，**不是可用的安装版本**。

手游 Mod 的目录约定参考官方移动版示例。PC「批量操作」的公开说明可用于确认功能需求，但不能说明手游端存在相同的底层接口。未在手游实机验证前，不会直接改写法宝品阶，也不会绕过原版成功率与消耗。

接口调查、适配器约定和剩余事项见 [Docs/IMPLEMENTATION.md](Docs/IMPLEMENTATION.md)。

## 版本目标

参考游戏 Mod 数据 `GameVersion: 1.2`。实际兼容范围以手游内加载测试为准。

## 参考

- 官方移动版 Mod 示例：[acs1_example_mod](https://github.com/GSQStudio/acs1_example_mod)
- 官方移动版 Mod 目录：[acs1_mods](https://github.com/GSQStudio/acs1_mods)
- PC 批量操作功能说明：[Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=1866576765)
