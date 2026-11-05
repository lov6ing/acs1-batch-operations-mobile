# ACS Mobile Batch Operations

《了不起的修仙模拟器》移动版批量操作 Mod 原型。

## 目标功能

- 批量炼制法宝：给选定角色排入多个炼宝目标，显示队列并允许取消尚未开始的任务。
- 批量幽淬、灵淬：选择多个目标物品并逐个施法，保留游戏原有消耗、成功率和失败结果。
- 触屏优先：使用游戏内触屏界面，不依赖 PC 的 Ctrl/Shift 快捷键。

## 当前状态

这是开发原型，尚未发布可安装版本。官方移动版示例确认 Mod 可使用 Lua 模块、神通脚本和自定义窗口；PC「批量操作」的公开说明确认了批量炼宝与批量施展幽淬等功能。

仍需在目标手游版本中验证底层角色命令队列和神通派发 API。未验证前，本项目不会直接改写法宝品阶，也不会绕过原版成功率。

## 版本目标

参考游戏 Mod 数据 `GameVersion: 1.2`。实际兼容范围以手游内加载测试为准。

## 参考

- 官方移动版 Mod 示例：[acs1_example_mod](https://github.com/GSQStudio/acs1_example_mod)
- 官方移动版 Mod 目录：[acs1_mods](https://github.com/GSQStudio/acs1_mods)
- PC 批量操作功能说明：[Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=1866576765)
