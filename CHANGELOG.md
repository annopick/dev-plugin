# Changelog

本项目的所有重要变更均会记录于此文件。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，
版本号遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)。

## [1.2.0] - 2026-08-12

新增 Ant Design（React + TypeScript + antd）技术栈智能体对，与原有 Vue 智能体并行共存。知识来源脱离 weknora，改用 `@ant-design/cli`（MCP/CLI 离线组件知识）与 ant-design-x 技能（AI 原生组件知识）。按 SemVer 升 minor。

### 新增

- **antd MCP 服务器** (`.mcp.json`)：新增 `antd` stdio 服务器，以 `npx -y @ant-design/cli mcp` 启动（npm 包 [@ant-design/cli](https://github.com/ant-design/ant-design-cli)）。完全离线，无需 API Key 或网络，提供 7 个工具：`antd_list`（组件列表）、`antd_info`（Props/API）、`antd_doc`（完整文档）、`antd_demo`（Demo 源码）、`antd_token`（设计令牌）、`antd_semantic`（语义化 className）、`antd_changelog`（版本变更/差异），覆盖 antd v4/v5/v6。
- **antd 组件知识技能** (`skills/antd/SKILL.md`)：类比 weknora 技能的角色，教智能体在编码前通过 MCP 工具或 CLI 命令查询组件 API（不凭记忆猜测），含场景指南（编写组件/调试/迁移/分析用量）、核心规则（匹配项目版本、结构化输出优先、改后 lint）、降级策略（CLI/MCP 不可用时凭自身知识兜底）。
- **antd-x AI 原生组件知识技能** (`skills/antd-x/SKILL.md`)：覆盖 `@ant-design/x` 全部组件（Bubble、Sender、Conversations、Prompts、ThoughtChain、Actions、Welcome、Attachments、Sources、Suggestion、Think、FileCard、CodeHighlighter、Mermaid、Folder、XProvider、Notification）+ SDK 数据流（useXChat、XRequest、XChatProvider、XMarkdown、XCard）。基于 RICH 交互范式分组，含开发规则防踩坑与详细技能路由（引用已安装的 `x-components` 等技能获取逐组件 API 详参）。
- **antd 开发智能体** (`agents/antd-developer.md`)：React 18+ + TypeScript + Ant Design v5/v6 技术栈，完整镜像 `frontend-developer.md` 结构——任务派发协议、知识优先原则（antd/antd-x 技能替代 weknora）、三个工作流（编码开发/详细设计文档/单元测试文档）、React+TS+antd+x 编码规范（函数组件+Hooks、ConfigProvider 主题定制、Form.useForm 表单校验、XProvider/Bubble.List/Sender 等 AI 组件用法）。
- **antd 验收智能体** (`agents/antd-acceptance.md`)：React + Ant Design 技术栈 E2E 验收专家，镜像 `frontend-acceptance.md` 结构——Playwright 浏览器验证流程、知识优先用 antd 技能替代 weknora、antd 组件验收要点（Select/Modal/DatePicker/Table/Form 的 DOM portal 渲染特征）。

### 变更

- **inject 脚本与指令扩展** (`scripts/inject-agent-model.sh`、`scripts/inject-agent-model.ps1`、`commands/inject-agent-model.md`)：`AGENT_FILES` / `$AgentFiles` 数组从 2 个扩展到 4 个（新增 `antd-developer.md`、`antd-acceptance.md`），注释与指令描述从"两个前端 agent"更新为"四个前端 agent（Vue 与 antd 两套技术栈）"。`/inject-agent-model` 命令一次注入全部四个 agent 的 `model:` 字段。
- **插件版本号**：`.zcode-plugin/plugin.json`、`.claude-plugin/plugin.json`、`.claude-plugin/marketplace.json` 的 `version` 统一升至 `1.2.0`。

### 已知限制

- antd MCP 服务器（`npx -y @ant-design/cli mcp`）要求运行环境可执行 npx 且能从 npm registry 拉取 `@ant-design/cli`；离线环境首次启动可能失败，降级为凭智能体自身 antd 知识兜底。
- antd-x 技能的逐组件详细 API（如 `x-components`、`use-x-chat` 等）依赖 `x-agent-skills` 插件提供；未安装时 `antd-x` 技能仍提供组件选型与开发规则总览，但不包含逐 Prop 详参。

## [1.1.0] - 2026-07-28

集成官方 WeKnora MCP 服务器（PyPI 包 `weknora-mcp`），作为 weknora 技能的主接口；凭据通过 userConfig 自动注入。这是相对 1.0.6 的功能新增，按 SemVer 升 minor。

### 新增

- **WeKnora MCP 服务器** (`.mcp.json`)：新增 `weknora` stdio 服务器，以 `uvx --from weknora-mcp==1.0.1 weknora-mcp-server` 启动（PyPI 包 [weknora-mcp](https://pypi.org/project/weknora-mcp/)，源码 [Tencent/WeKnora/mcp-server](https://github.com/Tencent/WeKnora/tree/main/mcp-server)）。它把 WeKnora REST + SSE 流封装成 28 个结构化工具（知识库 CRUD、文件/URL 导入、`hybrid_search`、会话、`chat`/`agent_chat`、`list/get_agent`、`list_models`、chunk 管理、wiki 查询等）；**问答的 SSE 流已在服务端消费并拼装**，工具直接返回 `{ answer, references, ... }`，无需自行解析流。已对真实实例（`http://192.168.50.26/api/v1`）实测：initialize 握手、tools/list（28 项）、list_knowledge_bases、hybrid_search 全部通过。
- **WeKnora 凭据 userConfig** (`.zcode-plugin/plugin.json`、`.claude-plugin/plugin.json`)：清单新增 `weknora_base_url`、`weknora_api_key` 两个字段（`type:string`、`required:true`，**未标 sensitive** 以便在 UI 填入并被自动替换）。ZCode 加载插件时自动把二者替换进 `.mcp.json` 的 `env.WEKNORA_BASE_URL` / `env.WEKNORA_API_KEY`。安装后在 **Plugin Management → Advanced** 填入即可。

### 变更

- **weknora 技能重写为 MCP 服务器主接口** (`skills/weknora/SKILL.md`)：意图决策表从「REST endpoint」改为「MCP 工具 → 意图」映射；明确 MCP 服务器替你做的事（SSE 流已拼装、名称即 ID、文件上传走服务端本机路径）；REST 降级为兜底，仅覆盖 MCP 未暴露的能力（写/编辑 Markdown、reparse/cancel-parse、跨库 `knowledge-search`、stop/continue-stream、KB 拷贝/迁移、创建/复制 agent），保留 curl 模板。工作流示例全部改为 MCP 工具调用风格。
- **API 参考定位调整** (`skills/weknora/API_REFERENCE.md`)：开头说明 MCP 服务器为主接口、本文件为 REST 兜底与字段级 schema 参考。
- **插件版本号**：`.zcode-plugin/plugin.json`、`.claude-plugin/plugin.json`、`.claude-plugin/marketplace.json` 的 `version` 统一升至 `1.1.0`。

### 已知限制

- `weknora_api_key` 未标记 `sensitive`（与 `zai_api_token` 同理：ZCode 当前对 sensitive 的 userConfig 值无法在 UI 填入且不持久化，故为保证可用性以明文存于配置）。`X-API-Key` 等同账户密码，请妥善保管。
- weknora MCP 服务器要求运行环境有 `uv`/`uvx`（用于拉起 PyPI 包）。

## [1.0.6] - 2026-07-23

引入 userConfig 自动注入 ZAI MCP Token，脚本转为斜杠指令（command），并对齐 ZCode 推荐清单范式、补齐文档。

### 新增

- **userConfig 自动注入 MCP Token** (`.zcode-plugin/plugin.json`、`.claude-plugin/plugin.json`)：清单新增 `userConfig.zai_api_token` 字段（`type:string`、`required:true`，**未标 sensitive** 以保证可在 UI 填入并被自动替换）。`.mcp.json` 中 4 处占位符由 `${ZAI_MCP_TOKEN}` 改为 `${user_config.zai_api_token}`，ZCode 加载插件时自动把用户配置的真实 token 替换进 4 个 zai MCP 服务器的 `env`/`headers`。安装后在 **Plugin Management → Advanced** 填入 `zai_api_token` 即可，无需再手动跑脚本。
- **斜杠指令** (`commands/`)：把两个安装后配置脚本封装为插件 command（薄封装，正文指示 agent 调用 `${ZCODE_PLUGIN_ROOT}/scripts/*.sh`）。
  - `commands/inject-mcp-token.md`（`/inject-mcp-token`）：MCP token 兜底注入，当 userConfig 不可用时使用。
  - `commands/inject-agent-model.md`（`/inject-agent-model`）：为前端 agent 注入 `model:` 字段（默认 Kimi K3，支持 `--provider`/`--model`/`--version` 参数）。
- **插件说明文档** (`README.md`)：根目录新增完整的 README，含目录结构、组件清单、MCP 服务器表、快速上手（安装→配 token→注入 model）、指令说明。

### 变更

- **清单范式对齐** (`.zcode-plugin/`)：按 ZCode 推荐范式，新建 `.zcode-plugin/plugin.json` 作为清单主位置（探测优先级最高），`.claude-plugin/plugin.json` 降为兼容镜像保持内容一致。清单不再显式声明 `skills`/`agents`/`mcpServers` 字段，改由标准路径自动发现，避免重复加载诊断。补充 `description_i18n.en` 英文兜底。
- **脚本占位符同步** (`scripts/inject-mcp-token.sh`、`.ps1`)：占位符常量由 `${ZAI_MCP_TOKEN}` 同步为 `${user_config.zai_api_token}`，与 `.mcp.json` 一致；并修复 macOS BSD sed 对 `${}` 转义报 `invalid repetition count` 的问题——替换实现由 sed 改为 bash 参数展开（`${line//find/replace}`），纯字面量替换、无需转义、对 token 中的 `/ & \` 特殊字符安全。
- **脚本文档** (`scripts/README.md`)：重写以反映 userConfig 为主路径、脚本/指令为兜底；补充斜杠指令与脚本的对照、平台差异、回滚方式。
- **插件版本号**：`.zcode-plugin/plugin.json`、`.claude-plugin/plugin.json`、`.claude-plugin/marketplace.json` 的 `version` 统一升至 `1.0.6`。

### 已知限制

- `zai_api_token` 未标记 `sensitive`。ZCode 当前对 sensitive 的 userConfig 值无法在 UI 填入且不持久化，故为保证可用性，token 以明文存于 `~/.zcode/cli/config.json`。待 ZCode 支持敏感值安全存储后可改为 sensitive。
- 前端 agent 的 `model:` 字段仍需通过 `/inject-agent-model` 注入真实值（agent model 依赖本机 provider 配置，无法用 userConfig 统一声明）。

## [1.0.5] - 2026-07-19

修复 marketplace 清单版本号与插件清单不同步的问题，无功能变更。

### 修复

- **marketplace 清单版本号对齐** (`.claude-plugin/marketplace.json`)：该文件的 `plugins[].version` 自 v1.0.3 起滞后于 `.claude-plugin/plugin.json` 的 `version`（marketplace 停留在 1.0.3，plugin 已到 1.0.4），导致 marketplace 展示的版本与实际插件版本不一致。本次将两者统一升至 1.0.5，并在此后每次发版同步更新。

### 变更

- **插件版本号**：`.claude-plugin/plugin.json` 与 `.claude-plugin/marketplace.json` 的 `version` 均升至 `1.0.5`，与本 CHANGELOG 对齐。

## [1.0.4] - 2026-07-19

新增 Windows（PowerShell）版安装后配置脚本，与既有 bash 脚本逻辑等价，并补充统一的使用说明文档。

### 新增

- **Windows PowerShell 脚本** (`scripts/`)：与 v1.0.3 的 bash 脚本一一对应的 `.ps1` 版本，供 Windows 11 用户使用。
  - `scripts/inject-mcp-token.ps1`：对应 `inject-mcp-token.sh`。读取 `$env:ZAI_MCP_TOKEN`，替换 `%USERPROFILE%\.zcode\cli\plugins\cache\annopick-plugin\annopick-plugin\<version>\.mcp.json` 中的 `${ZAI_MCP_TOKEN}` 占位符。用 .NET 字面量 `string.Replace`（非正则）替换，token 含 `/`、`&`、`\` 等特殊字符也安全；写回保持 UTF-8 无 BOM。
  - `scripts/inject-agent-model.ps1`：对应 `inject-agent-model.sh`。默认 Kimi K3，支持 `-Provider`/`-Model`/`-Version` 参数覆盖；从 `%USERPROFILE%\.zcode\v2\config.json` 校验 provider/model 真实存在；provider key 中的 `:` 自动 URL 编码为 `%3A`；已有 `model:` 行原地替换，没有则在 frontmatter 结束 `---` 前插入。
- **脚本使用说明** (`scripts/README.md`)：统一说明两个平台下的脚本用法、Windows 执行策略（`Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`）注意事项、路径对照（macOS `~/.zcode/...` vs Windows `%USERPROFILE%\.zcode\...`）、参数表与回滚方式。

### 修复

- **两个 bash 脚本版本探测的字典序问题**（`inject-mcp-token.sh`、`inject-agent-model.sh`）：原 `sort -V` 在 macOS 上对 `1.9.0` vs `1.10.0` 的排序符合版本语义；PowerShell 移植时若用 `Sort-Object -Property Name` 会退化为字典序选错版本，统一改用 `[version]` 类型排序。bash 版本经复核 `sort -V` 行为正确，无需改动。

### 变更

- **插件版本号**：`.claude-plugin/plugin.json` 的 `version` 由 `1.0.3` 升至 `1.0.4`，与本 CHANGELOG 对齐。

## [1.0.3] - 2026-07-18

新增插件安装后的配置注入脚本，并引入 agent 的 `model` 字段占位符，补齐"安装即需本地化配置"的链路。

### 新增

- **安装后配置脚本** (`scripts/`)：因 ZCode 当前不在 MCP 配置与 agent `model` 字段中展开环境变量/动态值，提供两个幂等脚本在安装后手动注入，支持自动探测最新已安装版本目录、写前备份、缺项报错退出。
  - `scripts/inject-mcp-token.sh`：读取系统环境变量 `ZAI_MCP_TOKEN`，替换插件安装目录下 `<version>/.mcp.json` 中 4 处 `${ZAI_MCP_TOKEN}` 占位符（1 处 stdio env、3 处 http headers）。对 token 中的 sed 特殊字符（`\`、`&`、`/`）做转义；占位符已不存在时视为成功跳过。
  - `scripts/inject-agent-model.sh`：将插件安装目录下两个前端 agent 文件 frontmatter 的 `model:` 字段写入 `custom:<provider>:<model-id>` 格式的真实值。默认 Kimi K3（`provider=623553b2-da8a-4b43-9320-90b1ed62a12b`、`model=k3`），支持 `--provider`/`--model`/`--version` 覆盖。写前从 `~/.zcode/v2/config.json` 校验 provider/model 真实存在；provider key 中的 `:` 自动 URL 编码为 `%3A`（与现网 `kimi-k3.md` 格式一致）；缺 `model:` 行时在 frontmatter 结束 `---` 前自动插入，有则原地替换。
- **agent `model` 字段占位符** (`agents/frontend-developer.md`、`agents/frontend-acceptance.md`)：两个 agent frontmatter 新增 `model: "custom:<provider>:<modelid>"` 占位符行。**该值为字面占位符，安装后需运行 `inject-agent-model.sh` 注入真实值后 agent 才能按指定模型运行**；不注入则 agent 的 model 配置无效。

### 使用说明（安装后必做）

```bash
export ZAI_MCP_TOKEN=<你的智谱 API Key>
bash scripts/inject-mcp-token.sh
bash scripts/inject-agent-model.sh   # 默认 Kimi K3；可加 --provider/--model 改用其他模型
```

### 变更

- **插件版本号**：`.claude-plugin/plugin.json` 的 `version` 由 `1.0.2` 升至 `1.0.3`，与本 CHANGELOG 对齐。

## [1.0.2] - 2026-07-18

前端智能体接入 WeKnora 知识库检索能力，并修正 v1.0.1 遗留的环境变量注入语法。

### 新增

- **智能体接入 `weknora` 技能** (`agents/frontend-developer.md`、`agents/frontend-acceptance.md`)：两个智能体均新增「知识库优先原则（WeKnora）」章节，作为贯穿性原则生效。
  - **优先查询**：涉及前端编码规范、组件/接口约定、架构决策、验收标准、业务规则等事实性问题时，优先通过 `weknora` 技能检索 WeKnora 知识库；知识库中的项目规范与智能体默认判断冲突时以知识库为准。
  - **非阻塞降级**：凭据缺失（`WEKNORA_BASE_URL`/`WEKNORA_API_KEY` 未配置）、无 `kb_id` 且无可匹配库、检索空、服务不可达四种情形立即降级为凭自身能力/案例描述继续工作，不卡住任务，并在结果中标注"未引用（降级原因）"。
  - 各自工作流相应步骤（开发者「项目结构探查」、验收「解析验证案例」）前置知识库检索引用；工具规范新增 `Skill（weknora）` 条目；结果回传/验收报告模板新增 `知识库引用` 字段。
  - 两个智能体 `description` 补充知识库优先说明，便于主智能体派遣时感知此能力。
  - 附带修正 `frontend-acceptance.md` 中 `description` 的 `截图取>证` 笔误。

### 修复

- **MCP 环境变量注入语法** (`.mcp.json`)：4 个 `zai-*` 服务的鉴权引用由 `${env:ZAI_MCP_TOKEN}` 修正为 `${ZAI_MCP_TOKEN}`，使运行时能正确解析并注入环境变量（v1.0.1 的 `${env:...}` 语法在当前运行时下不被识别）。

### 变更

- **插件版本号**：`.claude-plugin/plugin.json` 的 `version` 由 `1.0.1` 升至 `1.0.2`，与本 CHANGELOG 对齐。

## [1.0.1] - 2026-07-18

修复 MCP 服务凭据管理方式，避免占位符残留与误提交真实密钥的风险。

### 变更

- **MCP 凭据改为环境变量注入** (`.mcp.json`)：4 个 `zai-*` 服务（`zai-visual-understanding`、`zai-web-search`、`zai-web-page-reading-mcp`、`zai-open-source-repository-mcp`）的鉴权信息由硬编码占位符 `<Z_AI_API_KEY>` 统一改为环境变量引用 `${env:ZAI_MCP_TOKEN}`。
  - 部署/使用前需在运行环境中设置 `ZAI_MCP_TOKEN` 环境变量为真实的智谱 API Key。
  - 该改动同时消除了 v1.0.0 中"占位符需手动替换"的已知限制，并避免真实密钥被误提交进版本库。
- **插件版本号**：`.claude-plugin/plugin.json` 的 `version` 由 `1.0.0` 升至 `1.0.1`，与本 CHANGELOG 对齐。

## [1.0.0] - 2026-07-18

首个正式版本。确立 `annopick-plugin` 的插件清单、智能体、技能、MCP 服务与许可证基线。

### 新增

- **插件清单** (`.claude-plugin/plugin.json`)：声明插件元信息（`name`、`display_name`、`version`、`author`、`homepage`、`repository`、`license`），并注册 `skills`、`agents`、`mcpServers` 三类组件。
- **智能体**
  - `agents/frontend-acceptance.md`：前端 E2E 验收智能体，基于 Playwright MCP 进行自动化调试、功能验证、截图取证，并输出结构化验收报告。
  - `agents/frontend-developer.md`：前端开发智能体（支持子智能体派遣），专精 Vue3 + TypeScript + Element Plus，承担编码开发、前端详细设计文档、前端单元测试文档三类任务，并按约定协议回传结构化结果。
- **技能 `weknora`** (`skills/weknora/`)
  - `SKILL.md`：WeKnora REST API 技能。覆盖知识库/知识条目管理、文件·URL·Markdown 导入、单库混合检索与跨库检索、SSE 流式 RAG / Agent 问答、会话管理、解析状态机轮询等完整工作流；内含意图决策表、状态机说明与易踩坑提示。
  - `API_REFERENCE.md`：WeKnora 全量端点目录与字段级 schema，作为 SKILL.md 决策表覆盖不足时的精确参考。
- **MCP 服务** (`.mcp.json`)：声明 5 个 MCP server，供智能体与技能调用：
  - `playwright`（stdio，浏览器自动化，供验收智能体使用）
  - `zai-visual-understanding`（stdio，图像/视频/图表理解）
  - `zai-web-search`（http，联网搜索）
  - `zai-web-page-reading-mcp`（http，网页读取）
  - `zai-open-source-repository-mcp`（http，GitHub 仓库检索）
- **许可证** (`LICENSE`)：采用 MIT License，版权归属 `Annopick`。
- **变更日志** (`CHANGELOG.md`)：本文件。

### 已知限制

- `hooks/hooks.json` 当前为空文件，未注册任何 hook；如后续需要会话/工具事件钩子，需补充 `hooks` 配置并确保 `hooks.enabled: true`。
- 插件配置已写入文件，但需在 ZCode 客户端 **Settings → Plugin Management** 重新启用/重载本插件后，智能体与技能才会被加载（分别在 **Settings → Subagents** 与 **`/` 菜单** 出现）。

[1.1.0]: https://github.com/annopick/dev-plugin/releases/tag/v1.1.0
[1.0.6]: https://github.com/annopick/dev-plugin/releases/tag/v1.0.6
[1.0.5]: https://github.com/annopick/dev-plugin/releases/tag/v1.0.5
[1.0.4]: https://github.com/annopick/dev-plugin/releases/tag/v1.0.4
[1.0.3]: https://github.com/annopick/dev-plugin/releases/tag/v1.0.3
[1.0.2]: https://github.com/annopick/dev-plugin/releases/tag/v1.0.2
[1.0.1]: https://github.com/annopick/dev-plugin/releases/tag/v1.0.1
[1.0.0]: https://github.com/annopick/dev-plugin/releases/tag/v1.0.0
