---
description: 为前端 agent 注入 model 字段（custom:provider:modelid，默认 Kimi K3）
argument-hint: [--provider <key>] [--model <id>] [--version <ver>]
allowed-tools: Bash
---

# 注入前端 Agent 的 Model 字段

## 背景

插件内四个前端 agent（`frontend-developer`、`frontend-acceptance`、`antd-developer`、`antd-acceptance`）的 frontmatter `model:` 字段是占位符，需在安装后写入真实的 `custom:<provider>:<model-id>` 值才能按指定模型运行。其中前两个基于 Vue3 + Element Plus 技术栈，后两个基于 React + Ant Design 技术栈。

- **默认**：Kimi K3（provider=`623553b2-da8a-4b43-9320-90b1ed62a12b`，model=`k3`）。
- 改用其他模型：通过 `$ARGUMENTS` 传 `--provider` / `--model` / `--version`。

## 执行步骤

1. 执行脚本，传入用户参数 `$ARGUMENTS`（留空则用默认 Kimi K3）：

```bash
bash "${ZCODE_PLUGIN_ROOT}/scripts/inject-agent-model.sh" $ARGUMENTS
```

2. 脚本会自动：从 `~/.zcode/v2/config.json` 校验 provider/model 真实存在（不存在则报错并列出可用项）；探测插件安装目录最新版本；对四个 agent 文件——已有 `model:` 行则原地替换、没有则在 frontmatter 结束 `---` 前插入；写前备份为 `<file>.bak`；幂等（已是目标值则跳过）。
3. provider key 中的 `:` 会被自动 URL 编码为 `%3A`（如 `builtin:bigmodel-coding-plan` → `builtin%3Abigmodel-coding-plan`），最终写入形如 `model: "custom:<provider-encoded>:<model-id>"`。

## 参数说明

| 参数 | 作用 | 默认值 |
|------|------|--------|
| `--provider <key>` | config.json 中的 provider key | Kimi provider UUID |
| `--model <id>` | 该 provider 下的 model key | `k3` |
| `--version <ver>` | 指定已安装版本（默认自动探测最新） | 自动探测 |

## 结果汇报

把脚本的 stdout 原样转达给用户，明确：四个 agent 各自更新成了什么 model 值、备份文件路径、以及如果想换模型如何再次执行。

## 平台说明

- macOS/Linux：上面 `bash` 命令直接可用。
- Windows：请改用 PowerShell 脚本 `powershell -ExecutionPolicy Bypass -File "${ZCODE_PLUGIN_ROOT}/scripts/inject-agent-model.ps1"`（参数名改为 `-Provider` / `-Model` / `-Version`）。
