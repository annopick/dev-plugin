# 安装后配置脚本

ZCode 当前不在 MCP 配置（`.mcp.json`）与 agent 的 `model:` 字段中展开环境变量或动态值，因此插件安装后需运行下面的脚本完成本地化注入。两组脚本逻辑等价，按平台选用其一即可。

## 平台对照

| 平台 | MCP Token 脚本 | Agent Model 脚本 |
|------|----------------|------------------|
| macOS / Linux | `inject-mcp-token.sh` | `inject-agent-model.sh` |
| Windows | `inject-mcp-token.ps1` | `inject-agent-model.ps1` |

## 脚本作用

1. **MCP Token 注入**：读取环境变量 `ZAI_MCP_TOKEN`，替换插件安装目录下 `<version>/.mcp.json` 中的 `${ZAI_MCP_TOKEN}` 占位符（4 处：1 处 stdio env、3 处 http headers）。
2. **Agent Model 注入**：把两个前端 agent 文件 frontmatter 的 `model:` 字段写入 `custom:<provider>:<model-id>` 真实值。默认 Kimi K3。

两个脚本都：自动探测最新已安装版本目录、写前备份为 `.bak`、幂等（重复运行不出错、已注入则跳过）、缺项时报错退出。

## macOS / Linux（bash）

```bash
# 1. 设置 token（持久化可写入 ~/.zshrc 或 ~/.bashrc）
export ZAI_MCP_TOKEN=<你的智谱 API Key>

# 2. 注入 MCP token
bash scripts/inject-mcp-token.sh

# 3. 注入 agent model（默认 Kimi K3）
bash scripts/inject-agent-model.sh
#    指定其他模型：
#    bash scripts/inject-agent-model.sh --provider "builtin:bigmodel-coding-plan" --model GLM-5.2
```

## Windows（PowerShell）

### 前置：执行策略

Windows 默认可能禁止运行 `.ps1`。首次运行若报"无法加载，因为在此系统上禁止运行脚本"，用以下任一方式放开（**仅对当前用户**，不需要管理员）：

```powershell
# 方式 A：仅当前进程放行（关闭终端后失效，最保守）
powershell -ExecutionPolicy Bypass -File .\scripts\inject-mcp-token.ps1

# 方式 B：永久放行当前用户（推荐，一次性）
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

`RemoteSigned`：本地脚本可正常运行，从网络下载的脚本需签名。之后直接 `.\scripts\xxx.ps1` 即可。

### 运行

```powershell
# 1. 设置 token（当前会话）
$env:ZAI_MCP_TOKEN = "<你的智谱 API Key>"
#    持久化（设置后需重开终端生效）：
#    setx ZAI_MCP_TOKEN "<你的智谱 API Key>"

# 2. 注入 MCP token
.\scripts\inject-mcp-token.ps1

# 3. 注入 agent model（默认 Kimi K3）
.\scripts\inject-agent-model.ps1
#    指定其他模型：
#    .\scripts\inject-agent-model.ps1 -Provider "builtin:bigmodel-coding-plan" -Model GLM-5.2
```

## 路径说明

脚本操作的插件安装目录，两平台路径如下（脚本会自动定位，无需手动指定）：

| 平台 | 插件安装目录 |
|------|--------------|
| macOS / Linux | `~/.zcode/cli/plugins/cache/annopick-plugin/annopick-plugin/<version>/` |
| Windows | `%USERPROFILE%\.zcode\cli\plugins\cache\annopick-plugin\annopick-plugin\<version>\` |

配置文件（agent model 脚本校验时读取）：

| 平台 | config.json |
|------|-------------|
| macOS / Linux | `~/.zcode/v2/config.json` |
| Windows | `%USERPROFILE%\.zcode\v2\config.json` |

## 参数

### inject-agent-model（`-Provider` / `-Model` / `-Version`）

| 参数 | macOS/Linux（`--xxx`） | Windows（`-Xxx`） | 默认值 |
|------|------------------------|--------------------|--------|
| Provider | `--provider` | `-Provider` | `623553b2-da8a-4b43-9320-90b1ed62a12b`（Kimi）|
| Model | `--model` | `-Model` | `k3` |
| Version | `--version` | `-Version` | 自动探测最新 |

`Provider` 取自 `config.json` 中 `provider.<key>` 的 `<key>`；`Model` 取自该 provider 下 `models.<key>` 的 `<key>`。脚本会先校验二者真实存在，不存在则报错并列出可选项。

Provider key 中的 `:` 会被自动 URL 编码为 `%3A`（如 `builtin:bigmodel-coding-plan` → `builtin%3Abigmodel-coding-plan`），最终写入值形如 `model: "custom:<provider-encoded>:<model-id>"`。

## 回滚

每个脚本写前都会生成 `<file>.bak` 备份。如需回滚，把 `.bak` 覆盖回原文件即可：

```bash
# macOS/Linux 示例
cp agents/frontend-developer.md.bak agents/frontend-developer.md
```

```powershell
# Windows 示例
Move-Item .\agents\frontend-developer.md.bak .\agents\frontend-developer.md -Force
```
