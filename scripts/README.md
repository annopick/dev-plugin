# 配置注入脚本与指令

本插件有两类"安装后配置"：**ZAI MCP Token**（鉴权 4 个 zai 服务器）和 **Agent Model**（前端 agent 的 `model:` 字段）。

- **ZAI MCP Token** 的推荐路径是插件的 **userConfig**（ZCode 自动替换 `.mcp.json` 里的 `${user_config.zai_api_token}`），无需手动跑脚本。下面的脚本/指令是**兜底手段**，仅在 userConfig 不可用时使用。
- **Agent Model** 没有 userConfig 机制（agent 的 `model:` 字段是动态的、且取决于本机已配置的 provider），必须用脚本/指令注入。

两者都同时提供「斜杠指令」和「命令行脚本」两种触发方式，逻辑等价。

## 触发方式对照

| 配置项 | 斜杠指令（插件内） | 命令行脚本 |
|--------|--------------------|------------|
| ZAI MCP Token（兜底） | `/inject-mcp-token` | `scripts/inject-mcp-token.sh` / `.ps1` |
| Agent Model | `/inject-agent-model` | `scripts/inject-agent-model.sh` / `.ps1` |

斜杠指令是对脚本的薄封装：指令正文指示 agent 调用 `${ZCODE_PLUGIN_ROOT}/scripts/*.sh`，脚本逻辑不变。

---

## 一、ZAI MCP Token

### 推荐：userConfig（自动）

在 **Settings → Plugin Management → Installed → annopick-plugin → Advanced** 填入 `zai_api_token`（智谱 API Key），保存即可。ZCode 会自动把 token 注入 4 个 zai MCP 服务器的 `env`/`headers`，无需运行任何脚本。

### 兜底：脚本 / 指令（当 userConfig 不可用时）

仅当 ZCode 版本不支持 userConfig 模板替换，或需离线注入时使用。脚本读取环境变量 `ZAI_MCP_TOKEN`，用字面量替换 `.mcp.json` 中的 `${user_config.zai_api_token}` 占位符（4 处）。

**macOS / Linux：**

```bash
export ZAI_MCP_TOKEN=<你的智谱 API Key>      # 持久化写入 ~/.zshrc 或 ~/.bashrc
bash scripts/inject-mcp-token.sh             # 自动探测最新已安装版本
bash scripts/inject-mcp-token.sh 1.0.6       # 或指定版本
```

**Windows（PowerShell）：**

```powershell
$env:ZAI_MCP_TOKEN = "<你的智谱 API Key>"
powershell -ExecutionPolicy Bypass -File .\scripts\inject-mcp-token.ps1
```

脚本行为：自动探测插件安装目录最新版本、写前备份 `.mcp.json.bak`、字面量替换（token 含 `/`、`&`、`\` 等特殊字符也安全）、替换后校验无残留、幂等（已替换则跳过）。

---

## 二、Agent Model

把两个前端 agent 文件 frontmatter 的 `model:` 字段写入 `custom:<provider>:<model-id>` 真实值。默认 **Kimi K3**（`provider=623553b2-da8a-4b43-9320-90b1ed62a12b`、`model=k3`）。

**斜杠指令：**

```
/inject-agent-model                                              # 默认 Kimi K3
/inject-agent-model --provider "builtin:bigmodel-coding-plan" --model GLM-5.2
```

**macOS / Linux：**

```bash
bash scripts/inject-agent-model.sh                              # 默认 Kimi K3
bash scripts/inject-agent-model.sh --provider "builtin:bigmodel-coding-plan" --model GLM-5.2
bash scripts/inject-agent-model.sh --version 1.0.6              # 指定版本
```

**Windows：**

```powershell
.\scripts\inject-agent-model.ps1
.\scripts\inject-agent-model.ps1 -Provider "builtin:bigmodel-coding-plan" -Model GLM-5.2
```

脚本行为：从 `~/.zcode/v2/config.json`（Windows 为 `%USERPROFILE%\.zcode\v2\config.json`）校验 provider/model 真实存在；探测插件安装目录最新版本；对两个 agent 文件——已有 `model:` 行则原地替换、没有则在 frontmatter 结束 `---` 前插入；写前备份 `<file>.bak`；幂等。

### 参数

| 参数 | macOS/Linux | Windows | 默认值 |
|------|-------------|---------|--------|
| Provider | `--provider` | `-Provider` | Kimi provider UUID |
| Model | `--model` | `-Model` | `k3` |
| Version | `--version` | `-Version` | 自动探测最新 |

Provider key 中的 `:` 会被自动 URL 编码为 `%3A`（如 `builtin:bigmodel-coding-plan` → `builtin%3Abigmodel-coding-plan`），最终写入形如 `model: "custom:builtin%3Abigmodel-coding-plan:GLM-5.2"`。

---

## 路径说明

| 平台 | 插件安装目录 |
|------|--------------|
| macOS / Linux | `~/.zcode/cli/plugins/cache/annopick-plugin/annopick-plugin/<version>/` |
| Windows | `%USERPROFILE%\.zcode\cli\plugins\cache\annopick-plugin\annopick-plugin\<version>\` |

| 平台 | config.json（agent model 校验用） |
|------|------------------------------------|
| macOS / Linux | `~/.zcode/v2/config.json` |
| Windows | `%USERPROFILE%\.zcode\v2\config.json` |

## 回滚

每个脚本写前都生成 `<file>.bak`。回滚即用备份覆盖：

```bash
cp .mcp.json.bak .mcp.json                      # macOS/Linux
cp agents/frontend-developer.md.bak agents/frontend-developer.md
```
```powershell
Move-Item .\.mcp.json.bak .\.mcp.json -Force    # Windows
```
