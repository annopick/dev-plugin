---
description: 将 ZAI MCP Token 注入插件安装目录的 .mcp.json（userConfig 不可用时的兜底手段）
argument-hint: [版本号，可选，默认自动探测最新]
allowed-tools: Bash
---

# 注入 ZAI MCP Token（兜底脚本）

## 背景：何时需要这个指令

正常情况下，ZAI MCP token 通过插件的 **userConfig** 配置：在 **Settings → Plugin Management → Installed → annopick-plugin → Advanced** 里填入 `zai_api_token`，ZCode 会自动把 `.mcp.json` 里的 `${user_config.zai_api_token}` 替换成真实值并注入 4 个 ZAI MCP 服务器（无需手动跑脚本）。

**本指令是兜底手段**，仅在以下场景使用：
- ZCode 版本不支持 userConfig 模板替换；
- 或出于离线/特殊部署原因，需要直接把 token 写进 `.mcp.json` 文件。

## 执行步骤

1. 确认环境变量 `ZAI_MCP_TOKEN` 已设置（即智谱 API Key）。若未设置，向用户询问后执行 `export ZAI_MCP_TOKEN=<用户提供的 key>`（仅当前会话）。
2. 执行脚本，把 `$ARGUMENTS` 作为版本号参数传入（留空则自动探测最新已安装版本）：

```bash
bash "${ZCODE_PLUGIN_ROOT}/scripts/inject-mcp-token.sh" $ARGUMENTS
```

3. 脚本会自动：探测插件安装目录（`~/.zcode/cli/plugins/cache/annopick-plugin/annopick-plugin/<version>/`）、备份原文件为 `.mcp.json.bak`、用字面量替换 `${user_config.zai_api_token}` 占位符（与 userConfig 自动替换的是同一个占位符，故本脚本与 userConfig 二选一）、替换后校验无残留、幂等（已替换则跳过）。

## 结果汇报

把脚本的 stdout/stderr 原样转达给用户，并明确告知：替换了几处、备份文件路径、如需回滚如何操作（`cp .mcp.json.bak .mcp.json`）。

## 平台说明

- macOS/Linux：上面 `bash` 命令直接可用。
- Windows：请改用 PowerShell 脚本 `powershell -ExecutionPolicy Bypass -File "${ZCODE_PLUGIN_ROOT}/scripts/inject-mcp-token.ps1"`。
