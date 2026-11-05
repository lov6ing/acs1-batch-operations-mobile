# ACS Mobile Batch Operations

《了不起的修仙模拟器》移动版批量操作 Mod。

## 功能预览

- 批量炼宝：选择一个炼器角色，点选多个法宝胚子后提交。Mod 按顺序加入原版炼宝命令，当前命令完成后再派发下一件。
- 批量幽淬、灵淬：选择一个角色，点选多个物品后提交。Mod 为每件物品加入对应原版神通命令，并为命令锁定一颗幽珀或灵珀。
- 触屏操作：在角色面板点批量按钮，逐个点选物品，再回到角色面板提交；不依赖 Ctrl/Shift 快捷键。

## 使用步骤

1. 在手游 Mod 商店添加仓库地址：<https://github.com/lov6ing/acs1-batch-operations-mobile>
2. 进入门派地图并选择一名角色。
3. 在角色面板点“批量炼宝”“批量幽淬”或“批量灵淬”。
4. 逐个点选目标物品。
5. 再次选择该角色，点“提交批量任务”。

炼宝会等待角色当前炼宝命令结束后继续。若角色灵气不足，剩余任务会等待；可以点“取消剩余炼宝”清除尚未开始的任务。已经开始的原版命令不受取消影响。

## 当前版本

GitHub Release v0.2.0-alpha 是功能预览版。批量命令流程已经接入仓库；当前没有在目标手游设备上完成实机验证。若界面按钮没有出现或提交后未派发命令，请提供游戏版本和游戏日志，我会按实际接口修正。

## 实现依据

- 官方移动版 Mod 示例及 API/配置文档：[acs1_example_mod](https://github.com/GSQStudio/acs1_example_mod)、[acs1_mods Docs](https://github.com/GSQStudio/acs1_mods/tree/master/Docs)
- 原版批量操作公开源码中使用的角色命令和炼宝命令参数：[Amazing-Mods](https://github.com/XuJunxu/Amazing-Mods/blob/fbb3b2ac6921b4b226fa9266cfda90b82c63fc97/MultiOperationHelper/Scripts/MultiOperationHelper.lua)
- 原版批量操作功能说明：[Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=1866576765)
