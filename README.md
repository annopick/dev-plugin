# annopick-plugin

[CHANGELOG](./CHANGELOG.md) · [scripts/README](./scripts/README.md)

Annopick 的 ZCode 插件，集成 WeKnora 知识库技能、Ant Design 组件知识技能、前端开发/验收智能体（Vue3 与 React 两套技术栈）、ZAI MCP 服务器与配置注入指令。面向前端工程化开发与端到端验收场景。

## 目录结构

```text
annopick-plugin/
├── .zcode-plugin/
│   └── plugin.json              # 推荐清单主位置（含 userConfig 声明）
├── .claude-plugin/
│   ├── plugin.json              # 兼容镜像（内容与 .zcode-plugin 一致）
│   └── marketplace.json         # 市场注册信息
├── .mcp.json                    # MCP 服务声明（6 个 server）
├── commands/                    # 斜杠指令
│   ├── inject-mcp-token.md
│   └── inject-agent-model.md
├── agents/                      # 子智能体（Vue3 与 antd 两套技术栈）
│   ├── frontend-developer.md
│   ├── frontend-acceptance.md
│   ├── antd-developer.md
│   └── antd-acceptance.md
├── skills/
│   ├── weknora/                 # WeKnora 知识库技能（供 Vue 智能体用）
│   │   ├── SKILL.md
│   │   └── API_REFERENCE.md
│   ├── antd/                    # Ant Design 组件知识技能（供 antd 智能体用）
│   │   └── SKILL.md
│   └── antd-x/                  # Ant Design X（AI 原生组件）知识技能
│       └── SKILL.md
├── scripts/                     # 配置注入脚本（macOS/Linux + Windows）
│   ├── inject-mcp-token.sh / .ps1
│   └── inject-agent-model.sh / .ps1
├── CHANGELOG.md
└── LICENSE
```

按 ZCode 推荐范式：清单优先放在 `.zcode-plugin/plugin.json`，`.claude-plugin/plugin.json` 为兼容镜像保持内容一致；`skills` / `agents` / `commands` / `mcpServers` 使用标准路径自动发现，不在清单中显式声明。

## 组件清单

| 组件 | 文件 | 说明 |
|------|------|------|
| **Skill** | `skills/weknora` | 通过 WeKnora REST API 导入文档、检索知识库、发起 RAG/Agent 问答（供 Vue 智能体用） |
| **Skill** | `skills/antd` | 通过 antd CLI MCP/CLI 离线查询组件 API、文档、Demo、Token 等（供 antd 智能体用） |
| **Skill** | `skills/antd-x` | Ant Design X（@ant-design/x）AI 原生组件知识——组件选型、开发规则、SDK 数据流指引 |
| **Agent** | `agents/frontend-developer.md` | 前端开发智能体（Vue3 + TS + Element Plus），承担编码/详细设计/单测文档 |
| **Agent** | `agents/frontend-acceptance.md` | 前端 E2E 验收智能体（Vue3 + Element Plus），基于 Playwright 做功能验证与截图取证 |
| **Agent** | `agents/antd-developer.md` | 前端开发智能体（React + TS + Ant Design），承担编码/详细设计/单测文档 |
| **Agent** | `agents/antd-acceptance.md` | 前端 E2E 验收智能体（React + Ant Design），基于 Playwright 做功能验证与截图取证 |
| **Command** | `commands/inject-mcp-token.md` | 兜底：把 ZAI MCP token 注入 `.mcp.json` |
| **Command** | `commands/inject-agent-model.md` | 为全部 4 个前端 agent 注入 `model:` 字段（默认 Kimi K3） |
| **MCP** | `.mcp.json` | 6 个 MCP 服务器（见下表） |

## MCP 服务器

| 服务器 | 类型 | 用途 | 鉴权 |
|--------|------|------|------|
| `zai-visual-understanding` | stdio | 图像/视频/图表/文档理解 | `env.Z_AI_API_KEY` = `${user_config.zai_api_token}` |
| `zai-web-search` | http | 联网搜索 | `Authorization: Bearer ${user_config.zai_api_token}` |
| `zai-web-page-reading-mcp` | http | 网页读取 | `Authorization: Bearer ${user_config.zai_api_token}` |
| `zai-open-source-repository-mcp` | http | GitHub 仓库检索 | `Authorization: Bearer ${user_config.zai_api_token}` |
| `playwright` | stdio | 浏览器自动化（供验收智能体用） | 无 |
| `antd` | stdio | Ant Design 组件知识（离线 API/文档/Demo/Token，7 个工具） | 无 |

4 个 `zai-*` 服务器的鉴权统一由插件清单声明的 **userConfig** 字段 `zai_api_token` 驱动，ZCode 加载插件时自动把 `.mcp.json` 里的 `${user_config.zai_api_token}` 替换为用户配置的真实值并注入 `env`/`headers`。`playwright` 与 `antd` 无需鉴权，开箱即用。

## 快速上手

### 1. 安装插件

在 ZCode 客户端 **Settings → Plugin Management → Discover** 添加本仓库的 marketplace，找到 `annopick-plugin` 点击 **Get** 安装（默认启用）。

### 2. 配置 ZAI MCP Token（必做）

安装后在 **Installed → annopick-plugin → Advanced** 里填入 **`zai_api_token`**（智谱 API Key，从 https://open.bigmodel.cn 获取），保存后 4 个 ZAI MCP 服务器即自动获得鉴权。

> 该字段在清单里 `required: true`。出于"可在 UI 填入并被自动替换"的需要，**未标记 `sensitive`**——值会以明文存于 `~/.zcode/cli/config.json`。若你的 ZCode 版本不支持 userConfig 模板替换，可改用兜底指令 `/inject-mcp-token`（见下）。

### 3. 注入前端 Agent 的 Model（可选）

四个前端 agent（Vue3 与 antd 两套技术栈各一对）的 `model:` 字段是占位符，需注入真实模型值。默认 Kimi K3，执行指令：

```
/inject-agent-model
```

或改用其他模型：

```
/inject-agent-model --provider "builtin:bigmodel-coding-plan" --model GLM-5.2
```

Windows 用户直接运行 PowerShell 脚本，详见 [scripts/README.md](./scripts/README.md)。

## 指令（斜杠命令）

| 指令 | 作用 |
|------|------|
| `/inject-mcp-token` | 兜底手段：当 userConfig 不可用时，把 token 直接写进 `.mcp.json`（读取 `$ZAI_MCP_TOKEN` 环境变量） |
| `/inject-agent-model` | 为全部 4 个前端 agent（`frontend-developer` / `frontend-acceptance` / `antd-developer` / `antd-acceptance`）注入 `model:` 字段 |

> 指令是对 `scripts/` 下脚本的薄封装。脚本的完整参数与平台差异见 [scripts/README.md](./scripts/README.md)。

## 版本管理

版本变更记录见 [CHANGELOG.md](./CHANGELOG.md)。发版时遵循：`.zcode-plugin/plugin.json`、`.claude-plugin/plugin.json`、`.claude-plugin/marketplace.json` 三处 `version` 保持一致，CHANGELOG 同步更新，按 SemVer 打 tag。
